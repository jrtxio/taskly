using Microsoft.Extensions.DependencyInjection;
using Taskly.Data;
using Taskly.Repositories;
using Taskly.Services;

namespace Taskly.Cli;

/// <summary>单次 CLI 执行的作用域：解析后的选项 + 已打开的数据库连接与各仓库。
/// 每条子命令 action 开头通过 <see cref="CreateAsync"/> 建立一个上下文，结束时释放。</summary>
public sealed class CliContext : IDisposable
{
    public IServiceProvider Services { get; }
    public bool Json { get; }
    public bool Quiet { get; }

    public SQLiteDatabase Db { get; }
    public ConfigService Config { get; }
    public ITaskRepository Tasks { get; }
    public IListRepository Lists { get; }
    public DateParser DateParser { get; }

    private CliContext(IServiceProvider services, bool json, bool quiet)
    {
        Services = services;
        Json = json;
        Quiet = quiet;
        Db = services.GetRequiredService<SQLiteDatabase>();
        Config = services.GetRequiredService<ConfigService>();
        Tasks = services.GetRequiredService<ITaskRepository>();
        Lists = services.GetRequiredService<IListRepository>();
        DateParser = services.GetRequiredService<DateParser>();
    }

    /// <summary>建立上下文：解析 db 路径、加载配置、打开数据库连接。</summary>
    public static async Task<CliContext> CreateAsync(IServiceProvider services, string? dbPath, bool json, bool quiet)
    {
        var config = services.GetRequiredService<ConfigService>();
        await config.LoadAsync();

        // 优先级：命令行 --db > 配置上次路径 > 默认 ~/.taskly/tasks.db
        var path = dbPath;
        if (string.IsNullOrEmpty(path))
        {
            path = config.LastDbPath;
        }
        if (string.IsNullOrEmpty(path))
        {
            path = PathUtils.GetDefaultDatabasePath();
        }

        var db = services.GetRequiredService<SQLiteDatabase>();
        db.SetDatabasePath(path);
        try
        {
            await db.EnsureConnectedAsync();
        }
        catch (Exception ex)
        {
            throw new CliException(
                $"Cannot open database: {path} ({ex.Message})",
                CliExitCode.DatabaseError,
                ex);
        }

        return new CliContext(services, json, quiet);
    }

    public void Dispose() => Db.Dispose();
}
