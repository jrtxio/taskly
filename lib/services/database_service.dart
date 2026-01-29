import 'package:sqflite/sqflite.dart';
import '../interfaces/database_service_interface.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../utils/path_utils.dart';
import '../utils/app_logger.dart';

class DatabaseService implements DatabaseServiceInterface {
  Database? _database;
  String? _customDatabasePath;

  // Initialize database service
  @override
  Future<void> init() async {
    // Just get's database to initialize it
    await database;
  }

  // Set custom database path
  @override
  void setDatabasePath(String path) {
    _customDatabasePath = path;
    _database = null; // Reset database connection
  }

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Database version
  static const int _databaseVersion = 4;

  // Table names
  static const String _tableLists = 'lists';
  static const String _tableTasks = 'tasks';

  // Create database file path
  Future<String> getDatabasePath() async {
    // Use custom path if set, otherwise use default path
    return _customDatabasePath ?? PathUtils.getDefaultDbPath();
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasePath();
    final db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Ensure icon and color columns exist (for databases that might be in inconsistent state)
    await _ensureColumnsExist(db);

    return db;
  }

  // Ensure icon and color columns exist in lists table
  Future<void> _ensureColumnsExist(Database db) async {
    try {
      // Check if icon column exists by querying table info
      final result = await db.rawQuery("PRAGMA table_info($_tableLists)");

      print(
        'DEBUG: _ensureColumnsExist - table structure: ${result.map((r) => "${r['name']}: ${r['type']}").toList()}',
      );

      final hasIconColumn = result.any((row) => row['name'] == 'icon');
      final hasColorColumn = result.any((row) => row['name'] == 'color');

      print(
        'DEBUG: _ensureColumnsExist - hasIconColumn: $hasIconColumn, hasColorColumn: $hasColorColumn',
      );

      // Add missing columns
      if (!hasIconColumn) {
        await db.execute('ALTER TABLE $_tableLists ADD COLUMN icon TEXT');
        logger.i('Added icon column to $_tableLists table');
        print('DEBUG: _ensureColumnsExist - Added icon column');
      }

      if (!hasColorColumn) {
        await db.execute('ALTER TABLE $_tableLists ADD COLUMN color INTEGER');
        logger.i('Added color column to $_tableLists table');
        print('DEBUG: _ensureColumnsExist - Added color column');
      }
    } catch (e, stackTrace) {
      logger.e(
        'Error ensuring columns exist',
        error: e,
        stackTrace: stackTrace,
      );
      print('DEBUG: _ensureColumnsExist - Error: $e');
    }
  }

  // Create tables when database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create lists table
    await db.execute('''
      CREATE TABLE $_tableLists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE $_tableTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER,
        text TEXT NOT NULL,
        due_date TEXT,
        due_time TEXT,
        completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (list_id) REFERENCES $_tableLists (id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_tasks_list_id ON $_tableTasks(list_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_tasks_completed ON $_tableTasks(completed)
    ''');
    await db.execute('''
      CREATE INDEX idx_tasks_due_date ON $_tableTasks(due_date)
    ''');

    // Insert default list
    await db.insert(_tableLists, {
      'name': '工作',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Upgrade database when version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Version 2: Add indexes for better query performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tasks_list_id ON $_tableTasks(list_id)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tasks_completed ON $_tableTasks(completed)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON $_tableTasks(due_date)
      ''');
    }

    if (oldVersion < 3 && newVersion >= 3) {
      // Version 3: Add icon and color columns to lists table
      await db.execute('ALTER TABLE $_tableLists ADD COLUMN icon TEXT');
      await db.execute('ALTER TABLE $_tableLists ADD COLUMN color INTEGER');
    }

    if (oldVersion < 4 && newVersion >= 4) {
      // Version 4: Add due_time and notes columns to tasks table
      await db.execute('ALTER TABLE $_tableTasks ADD COLUMN due_time TEXT');
      await db.execute('ALTER TABLE $_tableTasks ADD COLUMN notes TEXT');
    }

    // Future migrations can be added here
    // Example:
    // if (oldVersion < 4 && newVersion >= 4) {
    //   // Add new columns or tables for version 4
    // }
  }

  // ------------------------
  // Lists Table Operations
  // ------------------------

  // Get all lists
  @override
  Future<List<TodoList>> getAllLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableLists);
    print('DEBUG: getAllLists - raw data: $maps');
    final lists = List.generate(maps.length, (i) => TodoList.fromMap(maps[i]));
    print(
      'DEBUG: getAllLists - parsed lists: ${lists.map((l) => "id=${l.id}, name=${l.name}, icon=${l.icon}, color=${l.color}").toList()}',
    );
    return lists;
  }

  // Get list by id
  @override
  Future<TodoList?> getListById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableLists,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return TodoList.fromMap(maps.first);
    }
    return null;
  }

  // Add list
  @override
  Future<int> addList(String name, {String? icon, int? color}) async {
    final db = await database;
    final Map<String, Object?> data = {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    };
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;
    return await db.insert(_tableLists, data);
  }

  // Update list
  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async {
    final db = await database;
    final Map<String, Object?> data = {'name': name};

    if (clearIcon) {
      data['icon'] = null;
    } else if (icon != null) {
      data['icon'] = icon;
    }

    if (clearColor) {
      data['color'] = null;
    } else if (color != null) {
      data['color'] = color;
    }

    print(
      'DEBUG: DatabaseService.updateList - id: $id, data: $data, clearIcon: $clearIcon, clearColor: $clearColor',
    );
    final result = await db.update(
      _tableLists,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    print('DEBUG: DatabaseService.updateList - update result: $result');

    // Verify the update by reading back the list
    final verify = await db.query(
      _tableLists,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (verify.isNotEmpty) {
      print(
        'DEBUG: DatabaseService.updateList - verified data: ${verify.first}',
      );
    }

    return result;
  }

  // Delete list
  @override
  Future<int> deleteList(int id) async {
    final db = await database;
    // First delete all tasks in this list
    await db.delete(_tableTasks, where: 'list_id = ?', whereArgs: [id]);
    // Then delete the list
    return await db.delete(_tableLists, where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------
  // Tasks Table Operations
  // ------------------------

  // Get all tasks
  @override
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
    ''');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by list
  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.list_id = ? AND t.completed = 0
      ORDER BY t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [listId, limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get completed tasks by list
  @override
  Future<List<Task>> getCompletedTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.list_id = ? AND t.completed = 1
      LIMIT ? OFFSET ?
    ''',
      [listId, limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by list including completed tasks
  @override
  Future<List<Task>> getTasksByListIncludingCompleted(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.list_id = ?
      ORDER BY t.completed ASC, t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [listId, limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all tasks including completed
  @override
  Future<List<Task>> getAllTasksIncludingCompleted({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      ORDER BY t.completed ASC, t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get today's tasks
  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async {
    final db = await database;
    final today = DateTime.now().toLocal();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE date(t.due_date) = ? AND t.completed = 0
      ORDER BY t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [todayString, limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get today's tasks including completed
  @override
  Future<List<Task>> getTodayTasksIncludingCompleted({int limit = 50, int offset = 0}) async {
    final db = await database;
    final today = DateTime.now().toLocal();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE date(t.due_date) = ?
      ORDER BY t.completed ASC, t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [todayString, limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get planned tasks (with due date and not completed)
  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.due_date IS NOT NULL AND t.completed = 0
      ORDER BY t.due_date ASC
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get planned tasks including completed
  @override
  Future<List<Task>> getPlannedTasksIncludingCompleted({int limit = 50, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.due_date IS NOT NULL
      ORDER BY t.completed ASC, t.due_date ASC
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all incomplete tasks
  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.completed = 0
      ORDER BY t.id DESC
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all completed tasks
  @override
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name
      FROM $_tableTasks t
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.completed = 1
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get total task count by list
  @override
  Future<int> getTaskCountByList(int listId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableTasks WHERE list_id = ?',
      [listId],
    );
    return result.first['count'] as int;
  }

  // Get total incomplete task count
  @override
  Future<int> getIncompleteTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableTasks WHERE completed = 0',
    );
    return result.first['count'] as int;
  }

  // Get total completed task count
  @override
  Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableTasks WHERE completed = 1',
    );
    return result.first['count'] as int;
  }

  // Get total today task count
  @override
  Future<int> getTodayTaskCount() async {
    final db = await database;
    final today = DateTime.now().toLocal();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM $_tableTasks
      WHERE date(due_date) = ? AND completed = 0
    ''',
      [todayString],
    );
    return result.first['count'] as int;
  }

  // Get total planned task count
  @override
  Future<int> getPlannedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM $_tableTasks
      WHERE due_date IS NOT NULL AND completed = 0
    ''');
    return result.first['count'] as int;
  }

  // Add task
  @override
  Future<int> addTask(Task task) async {
    final db = await database;
    return await db.insert(_tableTasks, task.toMap());
  }

  // Update task
  @override
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      _tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Toggle task completed status
  @override
  Future<int> toggleTaskCompleted(int id) async {
    final db = await database;
    // First get the current completed status
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTasks,
      columns: ['completed'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final currentCompleted = maps.first['completed'] as int;
      // Toggle the status
      return await db.update(
        _tableTasks,
        {'completed': currentCompleted == 1 ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }

  // Delete task
  @override
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(_tableTasks, where: 'id = ?', whereArgs: [id]);
  }

  // Search tasks by keyword
  @override
  Future<List<Task>> searchTasks(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.text LIKE ?
    ''',
      ['%$keyword%'],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Close database
  @override
  Future<void> close() async {
    final db = await database;
    if (db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  // Check if database is connected
  @override
  bool isConnected() {
    return _database != null && _database!.isOpen;
  }

  // Reset database connection
  @override
  void resetConnection() {
    _database = null;
    _customDatabasePath = null;
  }
}
