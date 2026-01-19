import 'package:sqflite/sqflite.dart';
import '../interfaces/database_service_interface.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../utils/path_utils.dart';

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
  static const int _databaseVersion = 1;

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
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables when database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create lists table
    await db.execute('''
      CREATE TABLE $_tableLists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
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
        completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (list_id) REFERENCES $_tableLists (id)
      )
    ''');

    // Insert default lists
    await db.insert(_tableLists, {
      'name': '工作',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert(_tableLists, {
      'name': '生活',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert(_tableLists, {
      'name': '学习',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Upgrade database when version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
  }

  // ------------------------
  // Lists Table Operations
  // ------------------------

  // Get all lists
  @override
  Future<List<TodoList>> getAllLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableLists);
    return List.generate(maps.length, (i) => TodoList.fromMap(maps[i]));
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
  Future<int> addList(String name) async {
    final db = await database;
    return await db.insert(_tableLists, {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Update list
  @override
  Future<int> updateList(int id, String name) async {
    final db = await database;
    return await db.update(
      _tableLists,
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
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
  Future<List<Task>> getTasksByList(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.list_id = ?
    ''',
      [listId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get today's tasks
  @override
  Future<List<Task>> getTodayTasks() async {
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
    ''',
      [todayString],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get planned tasks (with due date and not completed)
  @override
  Future<List<Task>> getPlannedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.due_date IS NOT NULL AND t.completed = 0
      ORDER BY t.due_date ASC
    ''');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all incomplete tasks
  @override
  Future<List<Task>> getIncompleteTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.completed = 0
    ''');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all completed tasks
  @override
  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, l.name as list_name 
      FROM $_tableTasks t 
      LEFT JOIN $_tableLists l ON t.list_id = l.id
      WHERE t.completed = 1
    ''');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
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
}
