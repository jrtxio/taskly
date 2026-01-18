import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:taskly/services/database_service.dart';
import 'package:taskly/models/task.dart';

void main() {
  late DatabaseService databaseService;
  late Database database;

  // Setup sqflite for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create a new database service instance for each test
    databaseService = DatabaseService();
    await databaseService.init();
    database = await databaseService.database;
  });

  tearDown(() async {
    // Close the database connection after each test
    await database.close();
  });

  group('DatabaseService Tests', () {
    test('should create database and tables', () async {
      // Verify tables exist
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('lists', 'tasks')",
      );
      expect(tables.length, 2);
    });

    test('should add and retrieve a list', () async {
      // Get initial list count (includes default lists)
      final initialLists = await databaseService.getAllLists();
      final initialCount = initialLists.length;

      // Add a list
      final listId = await databaseService.addList('Test List');
      expect(listId, isNotNull);

      // Retrieve all lists
      final lists = await databaseService.getAllLists();
      expect(lists.length, initialCount + 1);

      // Find the added list
      final testList = lists.firstWhere((list) => list.name == 'Test List');
      expect(testList, isNotNull);
    });

    test('should update a list', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Update the list
      await databaseService.updateList(listId, 'Updated List');

      // Retrieve the list
      final list = await databaseService.getListById(listId);
      expect(list?.name, 'Updated List');
    });

    test('should delete a list', () async {
      // Get initial list count (includes default lists)
      final initialLists = await databaseService.getAllLists();
      final initialCount = initialLists.length;

      // Add a list
      final listId = await databaseService.addList('Test List');

      // Delete the list
      await databaseService.deleteList(listId);

      // Retrieve all lists
      final lists = await databaseService.getAllLists();
      expect(lists.length, initialCount);
    });

    test('should add and retrieve a task', () async {
      // Add a list first
      final listId = await databaseService.addList('Test List');

      // Add a task without specifying id (it will be auto-generated)
      final task = Task(
        id: 0, // This will be ignored by the database and auto-generated
        listId: listId,
        text: 'Test Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      final taskId = await databaseService.addTask(task);
      expect(taskId, isNotNull);
      expect(taskId, isNot(0)); // Should be auto-generated, not 0

      // Retrieve all tasks
      final tasks = await databaseService.getAllTasks();
      final addedTask = tasks.firstWhere((t) => t.id == taskId);
      expect(addedTask.text, 'Test Task');
      expect(addedTask.completed, false);
    });

    test('should toggle task completed status', () async {
      // Add a list and task
      final listId = await databaseService.addList('Test List');
      final task = Task(
        id: 0, // This will be ignored by the database and auto-generated
        listId: listId,
        text: 'Test Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Toggle the task status
      await databaseService.toggleTaskCompleted(taskId);

      // Retrieve all tasks
      final tasks = await databaseService.getAllTasks();
      final updatedTask = tasks.firstWhere((t) => t.id == taskId);
      expect(updatedTask.completed, true);

      // Toggle again
      await databaseService.toggleTaskCompleted(taskId);
      final finalTasks = await databaseService.getAllTasks();
      final finalTask = finalTasks.firstWhere((t) => t.id == taskId);
      expect(finalTask.completed, false);
    });
  });
}
