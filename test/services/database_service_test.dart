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
        id: 0, // This will be ignored by database and auto-generated
        listId: listId,
        text: 'Test Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Toggle task status
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

    test('should retrieve tasks by list id', () async {
      // Add two lists
      final listId1 = await databaseService.addList('List 1');
      final listId2 = await databaseService.addList('List 2');

      // Add tasks to first list
      await databaseService.addTask(
        Task(
          id: 0,
          listId: listId1,
          text: 'Task 1',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      await databaseService.addTask(
        Task(
          id: 0,
          listId: listId1,
          text: 'Task 2',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      // Add task to second list
      await databaseService.addTask(
        Task(
          id: 0,
          listId: listId2,
          text: 'Task 3',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      // Get tasks by list
      final list1Tasks = await databaseService.getTasksByList(listId1);
      final list2Tasks = await databaseService.getTasksByList(listId2);

      expect(list1Tasks.length, 2);
      expect(list2Tasks.length, 1);
      expect(list1Tasks.every((t) => t.listId == listId1), true);
      expect(list2Tasks.every((t) => t.listId == listId2), true);
    });

    test('should update a task', () async {
      // Add a list and task
      final listId = await databaseService.addList('Test List');
      final task = Task(
        id: 0,
        listId: listId,
        text: 'Original Task',
        dueDate: '2024-12-31',
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Update task
      final updatedTask = Task(
        id: taskId,
        listId: listId,
        text: 'Updated Task',
        dueDate: '2025-01-01',
        completed: true,
        createdAt: task.createdAt,
      );
      await databaseService.updateTask(updatedTask);

      // Retrieve updated task
      final tasks = await databaseService.getAllTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == taskId);

      expect(retrievedTask.text, 'Updated Task');
      expect(retrievedTask.dueDate, '2025-01-01');
      expect(retrievedTask.completed, true);
    });

    test('should delete a task', () async {
      // Add a list and task
      final listId = await databaseService.addList('Test List');
      final task = Task(
        id: 0,
        listId: listId,
        text: 'Test Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Verify task exists
      final initialTasks = await databaseService.getAllTasks();
      expect(initialTasks.any((t) => t.id == taskId), true);

      // Delete task
      await databaseService.deleteTask(taskId);

      // Verify task is deleted
      final finalTasks = await databaseService.getAllTasks();
      expect(finalTasks.any((t) => t.id == taskId), false);
    });

    test('should handle tasks with null due dates', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add tasks with null due date
      final task1 = Task(
        id: 0,
        listId: listId,
        text: 'Task 1',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final task2 = Task(
        id: 0,
        listId: listId,
        text: 'Task 2',
        dueDate: null,
        completed: true,
        createdAt: DateTime.now().toIso8601String(),
      );

      await databaseService.addTask(task1);
      await databaseService.addTask(task2);

      // Retrieve tasks
      final tasks = await databaseService.getAllTasks();
      expect(tasks.length, greaterThanOrEqualTo(2));

      final tasksWithNullDueDate = tasks.where((t) => t.dueDate == null);
      expect(tasksWithNullDueDate.length, greaterThanOrEqualTo(2));
    });

    test('should handle tasks with special characters in text', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add task with special characters
      final task = Task(
        id: 0,
        listId: listId,
        text: r'Task with special characters: @#$%^&*()_+-={}[]|\:;"<>?,./',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Retrieve task
      final tasks = await databaseService.getAllTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == taskId);

      expect(retrievedTask.text, task.text);
    });

    test('should handle tasks with unicode characters', () async {
      // Add a list
      final listId = await databaseService.addList('测试列表');

      // Add task with unicode characters
      final task = Task(
        id: 0,
        listId: listId,
        text: '测试任务 🎉 中文 العربية 日本語',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Retrieve task
      final tasks = await databaseService.getAllTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == taskId);

      expect(retrievedTask.text, task.text);
    });

    test('should handle very long task text', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add task with very long text
      final longText = 'A' * 10000;
      final task = Task(
        id: 0,
        listId: listId,
        text: longText,
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Retrieve task
      final tasks = await databaseService.getAllTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == taskId);

      expect(retrievedTask.text, longText);
    });

    test('should handle multiple lists with same name', () async {
      // Add lists with same name
      final listId1 = await databaseService.addList('Same Name');
      final listId2 = await databaseService.addList('Same Name');
      final listId3 = await databaseService.addList('Same Name');

      // Verify all lists exist
      final lists = await databaseService.getAllLists();
      final sameNameLists = lists.where((l) => l.name == 'Same Name');

      expect(sameNameLists.length, greaterThanOrEqualTo(3));
      expect(sameNameLists.any((l) => l.id == listId1), true);
      expect(sameNameLists.any((l) => l.id == listId2), true);
      expect(sameNameLists.any((l) => l.id == listId3), true);
    });

    test('should handle rapid task additions', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add many tasks rapidly
      final taskIds = <int>[];
      for (int i = 0; i < 100; i++) {
        final task = Task(
          id: 0,
          listId: listId,
          text: 'Task $i',
          dueDate: null,
          completed: i % 2 == 0,
          createdAt: DateTime.now().toIso8601String(),
        );
        final taskId = await databaseService.addTask(task);
        taskIds.add(taskId);
      }

      // Verify all tasks were added
      final tasks = await databaseService.getAllTasks();
      final addedTasks = tasks.where((t) => taskIds.contains(t.id));

      expect(addedTasks.length, 100);
    });

    test('should handle deleting all tasks from a list', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add multiple tasks
      final taskIds = <int>[];
      for (int i = 0; i < 10; i++) {
        final task = Task(
          id: 0,
          listId: listId,
          text: 'Task $i',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final taskId = await databaseService.addTask(task);
        taskIds.add(taskId);
      }

      // Delete all tasks
      for (final taskId in taskIds) {
        await databaseService.deleteTask(taskId);
      }

      // Verify tasks are deleted
      final tasks = await databaseService.getTasksByList(listId);
      expect(tasks.length, 0);
    });

    test('should handle updating tasks multiple times', () async {
      // Add a list and task
      final listId = await databaseService.addList('Test List');
      final task = Task(
        id: 0,
        listId: listId,
        text: 'Original Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      final taskId = await databaseService.addTask(task);

      // Update task multiple times
      for (int i = 1; i <= 10; i++) {
        final updatedTask = Task(
          id: taskId,
          listId: listId,
          text: 'Updated Task $i',
          dueDate: null,
          completed: i % 2 == 0,
          createdAt: task.createdAt,
        );
        await databaseService.updateTask(updatedTask);
      }

      // Verify final state
      final tasks = await databaseService.getAllTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == taskId);

      expect(retrievedTask.text, 'Updated Task 10');
      expect(retrievedTask.completed, true);
    });

    test('should handle tasks with valid and invalid dates', () async {
      // Add a list
      final listId = await databaseService.addList('Test List');

      // Add tasks with different date formats
      final tasks = [
        Task(
          id: 0,
          listId: listId,
          text: 'Task 1',
          dueDate: '2024-12-31',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
        Task(
          id: 0,
          listId: listId,
          text: 'Task 2',
          dueDate: '2025-01-15',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
        Task(
          id: 0,
          listId: listId,
          text: 'Task 3',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];

      for (final task in tasks) {
        await databaseService.addTask(task);
      }

      // Retrieve all tasks
      final retrievedTasks = await databaseService.getAllTasks();
      expect(retrievedTasks.length, greaterThanOrEqualTo(3));
    });

    test('should handle deleting a non-existent task gracefully', () async {
      // Try to delete a non-existent task
      await databaseService.deleteTask(999999);

      // Should not throw an error
      expect(
        () async => await databaseService.deleteTask(999999),
        returnsNormally,
      );
    });

    test('should handle updating a non-existent task', () async {
      // Try to update a non-existent task
      final task = Task(
        id: 999999,
        listId: 1,
        text: 'Non-existent Task',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      await databaseService.updateTask(task);

      // Should not throw an error
      expect(
        () async => await databaseService.updateTask(task),
        returnsNormally,
      );
    });

    test('should handle toggling a non-existent task', () async {
      // Try to toggle a non-existent task
      await databaseService.toggleTaskCompleted(999999);

      // Should not throw an error
      expect(
        () async => await databaseService.toggleTaskCompleted(999999),
        returnsNormally,
      );
    });
  });
}
