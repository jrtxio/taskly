import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/task_repository_interface.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/app_error.dart';
import 'package:taskly/models/todo_list.dart';

class MockTaskRepository implements TaskRepositoryInterface {
  final List<Task> _tasks = [];
  int _nextId = 1;

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return _tasks.where((task) => task.listId == listId).toList();
  }

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async {
    final now = DateTime.now();
    final todayString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.startsWith(todayString) &&
              !task.completed,
        )
        .toList();
  }

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async {
    return _tasks
        .where((task) => task.dueDate != null && !task.completed)
        .toList();
  }

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async {
    return _tasks.where((task) => !task.completed).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0}) async {
    return _tasks.where((task) => task.completed).toList();
  }

  @override
  Future<int> getTaskCountByList(int listId) async {
    return _tasks.where((task) => task.listId == listId).length;
  }

  @override
  Future<int> getIncompleteTaskCount() async {
    return _tasks.where((task) => !task.completed).length;
  }

  @override
  Future<int> getCompletedTaskCount() async {
    return _tasks.where((task) => task.completed).length;
  }

  @override
  Future<Task?> getTaskById(int id) async {
    for (final task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  @override
  Future<int> addTask(Task task) async {
    final newTask = task.copyWith(id: _nextId++);
    _tasks.add(newTask);
    return newTask.id;
  }

  @override
  Future<int> updateTask(Task task) async {
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == task.id) {
        _tasks[i] = task;
        return 1;
      }
    }
    return 0;
  }

  @override
  Future<int> toggleTaskCompleted(int id) async {
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == id) {
        _tasks[i] = _tasks[i].copyWith(completed: !_tasks[i].completed);
        return 1;
      }
    }
    return 0;
  }

  @override
  Future<int> deleteTask(int id) async {
    final initialLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    return initialLength - _tasks.length;
  }

  @override
  Future<List<Task>> searchTasks(String keyword) async {
    final lowerKeyword = keyword.toLowerCase();
    return _tasks
        .where((task) => task.text.toLowerCase().contains(lowerKeyword))
        .toList();
  }

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async {
    switch (viewType) {
      case 'today':
        return await getTodayTasks();
      case 'planned':
        return await getPlannedTasks();
      case 'all':
        return await getIncompleteTasks();
      case 'completed':
        return await getCompletedTasks();
      case 'list':
        if (listId != null) {
          return await getTasksByList(listId);
        }
        return [];
      case 'search':
        if (keyword != null) {
          return await searchTasks(keyword);
        }
        return [];
      default:
        return await getIncompleteTasks();
    }
  }

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async {
    final Map<String, List<Task>> groups = {};

    for (final task in tasks) {
      final listName = task.listName ?? 'Unknown List';
      if (!groups.containsKey(listName)) {
        groups[listName] = [];
      }
      groups[listName]!.add(task);
    }

    return groups;
  }
}

class FailingLoadTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async {
    throw Exception('Load failed');
  }

  @override
  Future<List<Task>> getCompletedTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getTaskCountByList(int listId) async => 0;

  @override
  Future<int> getIncompleteTaskCount() async => 0;

  @override
  Future<int> getCompletedTaskCount() async => 0;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async => 0;

  @override
  Future<int> updateTask(Task task) async => 0;

  @override
  Future<int> toggleTaskCompleted(int id) async => 0;

  @override
  Future<int> deleteTask(int id) async => 0;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async {
    throw Exception('Load failed');
  }

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

class FailingAddTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getTaskCountByList(int listId) async => 0;

  @override
  Future<int> getIncompleteTaskCount() async => 0;

  @override
  Future<int> getCompletedTaskCount() async => 0;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async {
    throw ArgumentError('Empty text');
  }

  @override
  Future<int> updateTask(Task task) async => 0;

  @override
  Future<int> toggleTaskCompleted(int id) async => 0;

  @override
  Future<int> deleteTask(int id) async => 0;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async => throw Exception('Load failed');

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

class FailingUpdateTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getTaskCountByList(int listId) async => 0;

  @override
  Future<int> getIncompleteTaskCount() async => 0;

  @override
  Future<int> getCompletedTaskCount() async => 0;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async => 0;

  @override
  Future<int> updateTask(Task task) async {
    throw ArgumentError('Empty text');
  }

  @override
  Future<int> toggleTaskCompleted(int id) async => 0;

  @override
  Future<int> deleteTask(int id) async => 0;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async => throw Exception('Load failed');

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

class FailingToggleTaskRepository implements TaskRepositoryInterface {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getTaskCountByList(int listId) async => 0;

  @override
  Future<int> getIncompleteTaskCount() async => 0;

  @override
  Future<int> getCompletedTaskCount() async => 0;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async => 0;

  @override
  Future<int> updateTask(Task task) async => 0;

  @override
  Future<int> toggleTaskCompleted(int id) async {
    throw Exception('Toggle failed');
  }

  @override
  Future<int> deleteTask(int id) async => 0;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

class FailingDeleteTaskRepository implements TaskRepositoryInterface {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasks({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getTaskCountByList(int listId) async => 0;

  @override
  Future<int> getIncompleteTaskCount() async => 0;

  @override
  Future<int> getCompletedTaskCount() async => 0;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async => 0;

  @override
  Future<int> updateTask(Task task) async => 0;

  @override
  Future<int> toggleTaskCompleted(int id) async => 0;

  @override
  Future<int> deleteTask(int id) async {
    throw Exception('Delete failed');
  }

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

void main() {
  group('TaskProvider Tests', () {
    group('Initialization', () {
      test('should initialize with default values', () {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        expect(taskProvider.tasks, isEmpty);
        expect(taskProvider.currentView, 'all');
        expect(taskProvider.searchKeyword, '');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
        expect(taskProvider.hasError, isFalse);
      });

      test('should have correct getters', () {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        expect(taskProvider.tasks, isList);
        expect(taskProvider.currentView, isA<String>());
        expect(taskProvider.searchKeyword, isA<String>());
        expect(taskProvider.isLoading, isA<bool>());
        expect(taskProvider.error, isNull);
        expect(taskProvider.hasError, isA<bool>());
      });
    });

    group('loadTasks method', () {
      test('should load all tasks by default', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.addAll([
          Task(
            id: 1,
            listId: 1,
            text: 'Task 1',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
          Task(
            id: 2,
            listId: 1,
            text: 'Task 2',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        ]);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadTasks();

        expect(taskProvider.tasks.length, 2);
        expect(taskProvider.currentView, 'all');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should load tasks by list', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task 1',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadTasksByList(1);

        expect(taskProvider.tasks.length, 1);
        expect(taskProvider.currentView, 'list');
      });

      test('should load today tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task 1',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadTodayTasks();

        expect(taskProvider.currentView, 'today');
      });

      test('should load planned tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task 1',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadPlannedTasks();

        expect(taskProvider.currentView, 'planned');
      });

      test('should load all tasks', () async {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadAllTasks();

        expect(taskProvider.currentView, 'all');
      });

      test('should load completed tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task 1',
            completed: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.loadCompletedTasks();

        expect(taskProvider.currentView, 'completed');
      });

      test('should search tasks', () async {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.searchTasks('test');

        expect(taskProvider.currentView, 'search');
        expect(taskProvider.searchKeyword, 'test');
      });
    });

    group('addTask method', () {
      test('should add task successfully', () async {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(mockTaskRepository._tasks.length, 1);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during add', () async {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.addTask(task);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when add fails', () async {
        final mockTaskRepository = FailingAddTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: '',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
      });
    });

    group('updateTask method', () {
      test('should update task successfully', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final updatedTask = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(updatedTask);

        expect(mockTaskRepository._tasks[0].text, 'Updated Task');
        expect(mockTaskRepository._tasks[0].completed, true);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during update', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final updatedTask = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.updateTask(updatedTask);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when update fails', () async {
        final mockTaskRepository = FailingUpdateTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        final task = Task(
          id: 1,
          listId: 1,
          text: '',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
      });
    });

    group('toggleTaskCompleted method', () {
      test('should toggle task completed successfully', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.toggleTaskCompleted(1);

        expect(mockTaskRepository._tasks[0].completed, true);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during toggle', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.toggleTaskCompleted(1);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when toggle fails', () async {
        final mockTaskRepository = FailingToggleTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.toggleTaskCompleted(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
      });
    });

    group('deleteTask method', () {
      test('should delete task successfully', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.deleteTask(1);

        expect(mockTaskRepository._tasks.length, 0);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during delete', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.deleteTask(1);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when delete fails', () async {
        final mockTaskRepository = FailingDeleteTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.deleteTask(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
      });
    });

    group('refreshTasks method', () {
      test('should reload tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        mockTaskRepository._tasks.add(
          Task(
            id: 1,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        await taskProvider.refreshTasks();

        expect(taskProvider.tasks.length, 1);
      });
    });

    group('updateDatabasePath method', () {
      test('should update database path', () {
        final mockTaskRepository = MockTaskRepository();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
        );

        taskProvider.updateDatabasePath('/new/path/database.db');

        expect(taskProvider.databasePath, '/new/path/database.db');
      });
    });
  });
}
