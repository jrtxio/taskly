using System.Data.Common;
using System.Globalization;
using System.Text;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Logging;
using Taskly.Models;

namespace Taskly.Data;

/// <summary>
/// SQLite 数据库服务，对应原 Flutter 版 DatabaseService。
/// 完全兼容原版 .db 文件：
/// - 表结构、列名、迁移版本号(4)、索引、默认「工作」列表一致
/// - 所有查询的 WHERE/ORDER BY 原样移植
/// - _ensureColumnsExist 兜底机制保留
/// 使用 Microsoft.Data.Sqlite（无 ORM，直接 SQL），保证与原 schema 完全一致。
/// </summary>
public sealed class SQLiteDatabase : IDisposable
{
    /// <summary>数据库迁移版本号，与原版一致。</summary>
    private const int DatabaseVersion = 4;

    private const string TableLists = "lists";
    private const string TableTasks = "tasks";

    private SqliteConnection? _connection;
    private string? _customDatabasePath;
    private readonly ILogger<SQLiteDatabase>? _logger;

    public SQLiteDatabase(ILogger<SQLiteDatabase>? logger = null)
    {
        _logger = logger;
    }

    /// <summary>当前数据库是否已连接。</summary>
    public bool IsConnected => _connection is not null;

    /// <summary>设置自定义数据库路径并重置连接（对应原版 setDatabasePath）。</summary>
    public void SetDatabasePath(string path)
    {
        _customDatabasePath = path;
        Close();
    }

    /// <summary>获取当前数据库路径。</summary>
    public string GetDatabasePath() => _customDatabasePath ?? PathUtils.GetDefaultDbPath();

    /// <summary>打开/初始化数据库连接（对应原版 database getter + _initDatabase）。</summary>
    public async Task EnsureConnectedAsync()
    {
        if (_connection is not null)
        {
            return;
        }

        var dbPath = GetDatabasePath();
        var dir = Path.GetDirectoryName(dbPath);
        if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        var connectionString = new SqliteConnectionStringBuilder
        {
            DataSource = dbPath,
            Mode = SqliteOpenMode.ReadWriteCreate,
        }.ToString();

        _connection = new SqliteConnection(connectionString);
        await _connection.OpenAsync();

        // 启用 WAL 模式：提升并发读写性能，并显著降低数据库文件被放到
        // 云盘/iCloud 等同步目录时损坏的风险（WAL 对中途同步更健壮）。
        // WAL 是持久化设置，写一次即永久生效；每次连接重复设置无害且廉价。
        await using (var pragmaCmd = _connection.CreateCommand())
        {
            pragmaCmd.CommandText = "PRAGMA journal_mode=WAL;";
            await pragmaCmd.ExecuteNonQueryAsync();
        }

        await CreateOrUpgradeAsync(_connection);
        await EnsureColumnsExistAsync(_connection);
    }

    /// <summary>首次创建表（对应原版 _onCreate，version 4 全新安装）。</summary>
    private async Task CreateAllAsync(SqliteConnection db, SqliteTransaction? transaction = null)
    {
        await ExecuteAsync(db, $"""
            CREATE TABLE {TableLists} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                icon TEXT,
                color INTEGER,
                created_at TEXT NOT NULL
            )
            """, null, transaction);

        await ExecuteAsync(db, $"""
            CREATE TABLE {TableTasks} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                list_id INTEGER,
                text TEXT NOT NULL,
                due_date TEXT,
                due_time TEXT,
                completed INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                notes TEXT,
                FOREIGN KEY (list_id) REFERENCES {TableLists} (id)
            )
            """, null, transaction);

        await CreateIndexesAsync(db, transaction);

        // 插入默认「工作」列表（带默认 icon/color）
        await ExecuteAsync(db,
            $"INSERT INTO {TableLists} (name, icon, color, created_at) VALUES (@name, @icon, @color, @createdAt)",
            new Dictionary<string, object?>
            {
                ["name"] = "工作",
                ["icon"] = Models.TodoList.DefaultIcon,
                ["color"] = Models.TodoList.DefaultColor,
                ["createdAt"] = DateTime.Now.ToString("o", CultureInfo.InvariantCulture),
            }, transaction);
    }

    /// <summary>创建索引（对应原版 v2 迁移 + onCreate 中的索引）。</summary>
    private async Task CreateIndexesAsync(SqliteConnection db, SqliteTransaction? transaction = null)
    {
        await ExecuteAsync(db, $"CREATE INDEX IF NOT EXISTS idx_tasks_list_id ON {TableTasks}(list_id)", null, transaction);
        await ExecuteAsync(db, $"CREATE INDEX IF NOT EXISTS idx_tasks_completed ON {TableTasks}(completed)", null, transaction);
        await ExecuteAsync(db, $"CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON {TableTasks}(due_date)", null, transaction);
    }

    /// <summary>建表或迁移（对应原版 openDatabase 的 onCreate/onUpgrade 回调）。</summary>
    private async Task CreateOrUpgradeAsync(SqliteConnection db)
    {
        var oldVersion = await GetUserVersionAsync(db);

        // 建表/迁移用显式事务，确保 DDL/INSERT 原子提交。
        await using (var transaction = db.BeginTransaction())
        {
            try
            {
                if (oldVersion == 0)
                {
                    // 全新数据库：直接建最新结构
                    await CreateAllAsync(db, transaction);
                }
                else
                {
                    // 旧版本数据库：逐级迁移
                    if (oldVersion < 2)
                    {
                        await CreateIndexesAsync(db, transaction);
                    }

                    if (oldVersion < 3)
                    {
                        await EnsureColumnAsync(db, TableLists, "icon", "TEXT", transaction);
                        await EnsureColumnAsync(db, TableLists, "color", "INTEGER", transaction);
                    }

                    if (oldVersion < 4)
                    {
                        await EnsureColumnAsync(db, TableTasks, "due_time", "TEXT", transaction);
                        await EnsureColumnAsync(db, TableTasks, "notes", "TEXT", transaction);
                    }
                }

                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        // user_version 是 schema pragma，必须在事务外设置（在事务内设置不生效）。
        await using (var verCmd = db.CreateCommand())
        {
            verCmd.CommandText = $"PRAGMA user_version = {DatabaseVersion}";
            await verCmd.ExecuteNonQueryAsync();
        }
    }

    /// <summary>兜底：确保 lists 表有 icon/color 列（对应原版 _ensureColumnsExist）。</summary>
    private async Task EnsureColumnsExistAsync(SqliteConnection db)
    {
        try
        {
            await EnsureColumnAsync(db, TableLists, "icon", "TEXT");
            await EnsureColumnAsync(db, TableLists, "color", "INTEGER");
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Error ensuring columns exist");
        }
    }

    /// <summary>检查并按需添加列（用 PRAGMA table_info 检测，幂等）。</summary>
    private async Task EnsureColumnAsync(SqliteConnection db, string table, string column, string type, SqliteTransaction? transaction = null)
    {
        var columns = await QueryAsync(db, $"PRAGMA table_info({table})", null);
        var hasColumn = columns.Any(r => r.TryGetValue("name", out var v) && v?.ToString() == column);
        if (!hasColumn)
        {
            await ExecuteAsync(db, $"ALTER TABLE {table} ADD COLUMN {column} {type}", null, transaction);
            _logger?.LogInformation("Added {Column} column to {Table} table", column, table);
        }
    }

    private static async Task<int> GetUserVersionAsync(SqliteConnection db)
    {
        await using var cmd = db.CreateCommand();
        cmd.CommandText = "PRAGMA user_version";
        var result = await cmd.ExecuteScalarAsync();
        return result is long l ? (int)l : 0;
    }

    // ------------------------
    // Lists 操作
    // ------------------------

    public async Task<List<TodoList>> GetAllListsAsync()
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!, $"SELECT * FROM {TableLists}", null);
        return rows.Select(TodoListFromRow).ToList();
    }

    public async Task<TodoList?> GetListByIdAsync(int id)
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!,
            $"SELECT * FROM {TableLists} WHERE id = @id",
            new Dictionary<string, object?> { ["id"] = id });
        return rows.Count > 0 ? TodoListFromRow(rows[0]) : null;
    }

    /// <summary>按名称查询列表（大小写敏感，精确匹配）。不存在返回 null。</summary>
    public async Task<TodoList?> GetListByNameAsync(string name)
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!,
            $"SELECT * FROM {TableLists} WHERE name = @name LIMIT 1",
            new Dictionary<string, object?> { ["name"] = name });
        return rows.Count > 0 ? TodoListFromRow(rows[0]) : null;
    }

    public async Task<int> AddListAsync(string name, string? icon = null, int? color = null)
    {
        await EnsureConnectedAsync();
        // 填充默认值：模仿 macOS Reminders，未选 icon/color 时使用默认值
        icon ??= Models.TodoList.DefaultIcon;
        color ??= Models.TodoList.DefaultColor;

        var createdAt = DateTime.Now.ToString("o", CultureInfo.InvariantCulture);
        var sb = new StringBuilder();
        sb.Append("INSERT INTO ").Append(TableLists).Append(" (name, created_at");
        if (icon is not null) sb.Append(", icon");
        if (color is not null) sb.Append(", color");
        sb.Append(") VALUES (@name, @createdAt");
        if (icon is not null) sb.Append(", @icon");
        if (color is not null) sb.Append(", @color");
        sb.Append(')');

        var p = new Dictionary<string, object?> { ["name"] = name, ["createdAt"] = createdAt };
        if (icon is not null) p["icon"] = icon;
        if (color is not null) p["color"] = color;

        return await InsertAndReturnIdAsync(_connection!, sb.ToString(), p);
    }

    public async Task<int> UpdateListAsync(
        int id,
        string name,
        string? icon = null,
        int? color = null,
        bool clearIcon = false,
        bool clearColor = false)
    {
        await EnsureConnectedAsync();
        var sb = new StringBuilder();
        sb.Append("UPDATE ").Append(TableLists).Append(" SET name = @name");

        if (clearIcon)
        {
            sb.Append(", icon = NULL");
        }
        else if (icon is not null)
        {
            sb.Append(", icon = @icon");
        }

        if (clearColor)
        {
            sb.Append(", color = NULL");
        }
        else if (color is not null)
        {
            sb.Append(", color = @color");
        }

        sb.Append(" WHERE id = @id");

        var p = new Dictionary<string, object?> { ["name"] = name, ["id"] = id };
        if (!clearIcon && icon is not null) p["icon"] = icon;
        if (!clearColor && color is not null) p["color"] = color;

        return await ExecuteAsync(_connection!, sb.ToString(), p);
    }

    public async Task<int> DeleteListAsync(int id)
    {
        await EnsureConnectedAsync();
        // 先删该列表下所有任务，再删列表（与原版一致）
        await ExecuteAsync(_connection!,
            $"DELETE FROM {TableTasks} WHERE list_id = @id",
            new Dictionary<string, object?> { ["id"] = id });
        return await ExecuteAsync(_connection!,
            $"DELETE FROM {TableLists} WHERE id = @id",
            new Dictionary<string, object?> { ["id"] = id });
    }

    // ------------------------
    // Tasks 查询（WHERE/ORDER BY 原样移植）
    // ------------------------

    private const string TaskSelectBase = $"""
        SELECT t.*, l.name AS list_name
        FROM {TableTasks} t
        LEFT JOIN {TableLists} l ON t.list_id = l.id
        """;

    public async Task<List<TaskItem>> GetAllTasksAsync()
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!, $"{TaskSelectBase}", null);
        return rows.Select(TaskFromRow).ToList();
    }

    /// <summary>按列表查询未完成任务（ORDER BY id DESC）。</summary>
    public async Task<List<TaskItem>> GetTasksByListAsync(int listId, int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.list_id = @listId AND t.completed = 0 ORDER BY t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["listId"] = listId, ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetCompletedTasksByListAsync(int listId, int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.list_id = @listId AND t.completed = 1 LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["listId"] = listId, ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetTasksByListIncludingCompletedAsync(int listId, int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.list_id = @listId ORDER BY t.completed ASC, t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["listId"] = listId, ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetAllTasksIncludingCompletedAsync(int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} ORDER BY t.completed ASC, t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetTodayTasksAsync(int limit = 1000, int offset = 0)
    {
        var today = DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        return await QueryTasksAsync(
            $"{TaskSelectBase} WHERE date(t.due_date) = @today AND t.completed = 0 ORDER BY t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["today"] = today, ["limit"] = limit, ["offset"] = offset });
    }

    public async Task<List<TaskItem>> GetTodayTasksIncludingCompletedAsync(int limit = 1000, int offset = 0)
    {
        var today = DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        return await QueryTasksAsync(
            $"{TaskSelectBase} WHERE date(t.due_date) = @today ORDER BY t.completed ASC, t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["today"] = today, ["limit"] = limit, ["offset"] = offset });
    }

    public async Task<List<TaskItem>> GetPlannedTasksAsync(int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.due_date IS NOT NULL AND t.completed = 0 ORDER BY t.due_date ASC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetPlannedTasksIncludingCompletedAsync(int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.due_date IS NOT NULL ORDER BY t.completed ASC, t.due_date ASC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetIncompleteTasksAsync(int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.completed = 0 ORDER BY t.id DESC LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> GetCompletedTasksAsync(int limit = 1000, int offset = 0) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.completed = 1 LIMIT @limit OFFSET @offset",
            new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset });

    public async Task<List<TaskItem>> SearchTasksAsync(string keyword) =>
        await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.text LIKE @keyword",
            new Dictionary<string, object?> { ["keyword"] = $"%{keyword}%" });

    /// <summary>按 id 查询单个任务（含 list_name）。任务不存在返回 null。</summary>
    public async Task<TaskItem?> GetTaskByIdAsync(int id)
    {
        await EnsureConnectedAsync();
        var rows = await QueryTasksAsync(
            $"{TaskSelectBase} WHERE t.id = @id",
            new Dictionary<string, object?> { ["id"] = id });
        return rows.Count > 0 ? rows[0] : null;
    }

    // ------------------------
    // Tasks 计数查询
    // ------------------------

    public async Task<int> GetTaskCountByListAsync(int listId)
    {
        await EnsureConnectedAsync();
        return await CountAsync(_connection!,
            $"SELECT COUNT(*) FROM {TableTasks} WHERE list_id = @listId AND completed = 0",
            new Dictionary<string, object?> { ["listId"] = listId });
    }

    public async Task<int> GetIncompleteTaskCountAsync()
    {
        await EnsureConnectedAsync();
        return await CountAsync(_connection!, $"SELECT COUNT(*) FROM {TableTasks} WHERE completed = 0", null);
    }

    public async Task<int> GetCompletedTaskCountAsync()
    {
        await EnsureConnectedAsync();
        return await CountAsync(_connection!, $"SELECT COUNT(*) FROM {TableTasks} WHERE completed = 1", null);
    }

    public async Task<int> GetTodayTaskCountAsync()
    {
        await EnsureConnectedAsync();
        var today = DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        return await CountAsync(_connection!,
            $"SELECT COUNT(*) FROM {TableTasks} WHERE date(due_date) = @today AND completed = 0",
            new Dictionary<string, object?> { ["today"] = today });
    }

    public async Task<int> GetPlannedTaskCountAsync()
    {
        await EnsureConnectedAsync();
        return await CountAsync(_connection!,
            $"SELECT COUNT(*) FROM {TableTasks} WHERE due_date IS NOT NULL AND completed = 0", null);
    }

    // ------------------------
    // Tasks 写操作
    // ------------------------

    public async Task<int> AddTaskAsync(TaskItem task)
    {
        await EnsureConnectedAsync();
        var sb = new StringBuilder();
        sb.Append("INSERT INTO ").Append(TableTasks)
          .Append(" (list_id, text, due_date, due_time, completed, created_at, notes) VALUES (");
        sb.Append("@listId, @text, @dueDate, @dueTime, @completed, @createdAt, @notes)");
        var p = new Dictionary<string, object?>
        {
            ["listId"] = task.ListId,
            ["text"] = task.Text,
            ["dueDate"] = (object?)task.DueDate ?? DBNull.Value,
            ["dueTime"] = (object?)task.DueTime ?? DBNull.Value,
            ["completed"] = task.Completed ? 1 : 0,
            ["createdAt"] = task.CreatedAt,
            ["notes"] = (object?)task.Notes ?? DBNull.Value,
        };
        return await InsertAndReturnIdAsync(_connection!, sb.ToString(), p);
    }

    public async Task<int> UpdateTaskAsync(TaskItem task)
    {
        await EnsureConnectedAsync();
        var sql = $"""
            UPDATE {TableTasks}
            SET list_id = @listId, text = @text, due_date = @dueDate, due_time = @dueTime,
                completed = @completed, notes = @notes
            WHERE id = @id
            """;
        var p = new Dictionary<string, object?>
        {
            ["listId"] = task.ListId,
            ["text"] = task.Text,
            ["dueDate"] = (object?)task.DueDate ?? DBNull.Value,
            ["dueTime"] = (object?)task.DueTime ?? DBNull.Value,
            ["completed"] = task.Completed ? 1 : 0,
            ["notes"] = (object?)task.Notes ?? DBNull.Value,
            ["id"] = task.Id,
        };
        return await ExecuteAsync(_connection!, sql, p);
    }

    /// <summary>切换任务完成状态（对应原版 toggleTaskCompleted，先读后翻转）。</summary>
    public async Task<int> ToggleTaskCompletedAsync(int id)
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!,
            $"SELECT completed FROM {TableTasks} WHERE id = @id",
            new Dictionary<string, object?> { ["id"] = id });
        if (rows.Count == 0)
        {
            return 0;
        }

        var current = Convert.ToInt32(rows[0]["completed"], CultureInfo.InvariantCulture);
        var newValue = current == 1 ? 0 : 1;
        return await ExecuteAsync(_connection!,
            $"UPDATE {TableTasks} SET completed = @value WHERE id = @id",
            new Dictionary<string, object?> { ["value"] = newValue, ["id"] = id });
    }

    /// <summary>幂等地设置任务完成状态（与 Toggle 的翻转语义不同）。
    /// completed=true 置 1，false 置 0。返回受影响行数（0 表示任务不存在）。</summary>
    public async Task<int> SetTaskCompletedAsync(int id, bool completed)
    {
        await EnsureConnectedAsync();
        return await ExecuteAsync(_connection!,
            $"UPDATE {TableTasks} SET completed = @value WHERE id = @id",
            new Dictionary<string, object?>
            {
                ["value"] = completed ? 1 : 0,
                ["id"] = id,
            });
    }

    public async Task<int> DeleteTaskAsync(int id)
    {
        await EnsureConnectedAsync();
        return await ExecuteAsync(_connection!,
            $"DELETE FROM {TableTasks} WHERE id = @id",
            new Dictionary<string, object?> { ["id"] = id });
    }

    // ------------------------
    // 连接管理
    // ------------------------

    public async Task CloseAsync()
    {
        if (_connection is not null)
        {
            await _connection.CloseAsync();
            await _connection.DisposeAsync();
            _connection = null;
        }
    }

    public void Close() => CloseAsync().GetAwaiter().GetResult();

    public void ResetConnection()
    {
        _connection?.Close();
        _connection?.Dispose();
        _connection = null;
    }

    public void Dispose()
    {
        _connection?.Dispose();
        _connection = null;
    }

    // ------------------------
    // 内部辅助方法
    // ------------------------

    private async Task<List<TaskItem>> QueryTasksAsync(string sql, Dictionary<string, object?>? parameters)
    {
        await EnsureConnectedAsync();
        var rows = await QueryAsync(_connection!, sql, parameters);
        return rows.Select(TaskFromRow).ToList();
    }

    private async Task<int> ExecuteAsync(SqliteConnection db, string sql, Dictionary<string, object?>? parameters = null, SqliteTransaction? transaction = null)
    {
        await using var cmd = db.CreateCommand();
        cmd.CommandText = sql;
        if (transaction is not null)
        {
            cmd.Transaction = transaction;
        }

        AddParameters(cmd, parameters);
        return await cmd.ExecuteNonQueryAsync();
    }

    private async Task<int> CountAsync(SqliteConnection db, string sql, Dictionary<string, object?>? parameters)
    {
        await using var cmd = db.CreateCommand();
        cmd.CommandText = sql;
        AddParameters(cmd, parameters);
        var result = await cmd.ExecuteScalarAsync();
        return result is long l ? (int)l : 0;
    }

    private async Task<int> InsertAndReturnIdAsync(SqliteConnection db, string sql, Dictionary<string, object?> parameters)
    {
        await ExecuteAsync(db, sql, parameters);
        await using var cmd = db.CreateCommand();
        cmd.CommandText = "SELECT last_insert_rowid()";
        var result = await cmd.ExecuteScalarAsync();
        return result is long l ? (int)l : 0;
    }

    private static async Task<List<Dictionary<string, object?>>> QueryAsync(
        SqliteConnection db, string sql, Dictionary<string, object?>? parameters)
    {
        await using var cmd = db.CreateCommand();
        cmd.CommandText = sql;
        AddParameters(cmd, parameters);

        var results = new List<Dictionary<string, object?>>();
        await using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            var row = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
            for (var i = 0; i < reader.FieldCount; i++)
            {
                var name = reader.GetName(i);
                row[name] = reader.IsDBNull(i) ? null : reader.GetValue(i);
            }

            results.Add(row);
        }

        return results;
    }

    private static void AddParameters(SqliteCommand cmd, Dictionary<string, object?>? parameters)
    {
        if (parameters is null)
        {
            return;
        }

        foreach (var kv in parameters)
        {
            cmd.Parameters.AddWithValue(kv.Key, kv.Value ?? DBNull.Value);
        }
    }

    private static TodoList TodoListFromRow(Dictionary<string, object?> row)
    {
        var id = Convert.ToInt32(row["id"], CultureInfo.InvariantCulture);
        var name = Convert.ToString(row["name"], CultureInfo.InvariantCulture)!;
        string? icon = row.TryGetValue("icon", out var iv) && iv is not null ? Convert.ToString(iv, CultureInfo.InvariantCulture) : null;
        int? color = null;
        if (row.TryGetValue("color", out var cv) && cv is not null && cv != DBNull.Value)
        {
            color = Convert.ToInt32(cv, CultureInfo.InvariantCulture);
        }

        return new TodoList(id, name, icon, color);
    }

    private static TaskItem TaskFromRow(Dictionary<string, object?> row)
    {
        var id = Convert.ToInt32(row["id"], CultureInfo.InvariantCulture);
        var listId = Convert.ToInt32(row["list_id"], CultureInfo.InvariantCulture);
        var text = Convert.ToString(row["text"], CultureInfo.InvariantCulture)!;
        var createdAt = Convert.ToString(row["created_at"], CultureInfo.InvariantCulture)!;

        string? GetOpt(string key) =>
            row.TryGetValue(key, out var v) && v is not null && v != DBNull.Value
                ? Convert.ToString(v, CultureInfo.InvariantCulture)
                : null;

        var dueDate = GetOpt("due_date");
        var dueTime = GetOpt("due_time");
        var notes = GetOpt("notes");
        var listName = GetOpt("list_name");
        var completed = row.TryGetValue("completed", out var cv) && cv is not null &&
                        Convert.ToInt32(cv, CultureInfo.InvariantCulture) == 1;

        return new TaskItem(id, listId, text, createdAt, dueDate, dueTime, completed, notes, listName);
    }
}
