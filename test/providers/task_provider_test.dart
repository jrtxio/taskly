import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/task_repository_interface.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/app_error.dart';

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
      case 'all':
        return getIncompleteTasks(limit: limit, offset: offset);
      case 'today':
        return getTodayTasks(limit: limit, offset: offset);
      case 'planned':
        return getPlannedTasks(limit: limit, offset: offset);
      case 'completed':
        return getCompletedTasks(limit: limit, offset: offset);
      case 'list':
        if (listId != null) {
          return getTasksByList(listId, limit: limit, offset: offset);
        }
        return [];
      case 'search':
        if (keyword != null &&
            keyword.isNotEmpty &&
            keyword.trim().isNotEmpty) {
          return searchTasks(keyword);
        }
        return [];
      default:
        return getIncompleteTasks(limit: limit, offset: offset);
    }
  }

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async {
    final Map<String, List<Task>> grouped = {};
    for (final task in tasks) {
      final key = task.listName ?? 'Unknown List';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(task);
    }
    return grouped;
  }
}

class MockDatabaseService implements DatabaseServiceInterface {
  bool _isConnected = false;

  @override
  Future<void> init() async {}

  @override
  void setDatabasePath(String path) {
    _isConnected = true;
  }

  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name, {String? icon, int? color}) async => 0;

  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async =>
      0;

  @override
  Future<int> deleteList(int id) async => 0;

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
  Future<void> close() async {}

  @override
  bool isConnected() => _isConnected;

  @override
  void resetConnection() {
    _isConnected = false;
  }

  void setConnected(bool connected) {
    _isConnected = connected;
  }
}

class FailingLoadTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async {
    throw Exception('Load failed');
  }

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
  Future<int> addTask(Task task) async {
    throw ArgumentError('Empty task text');
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
  }) async => [];

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
  Future<int> addTask(Task task) async => 0;

  @override
  Future<int> updateTask(Task task) async {
    throw ArgumentError('Empty task text');
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
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

class FailingToggleTaskRepository implements TaskRepositoryInterface {
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
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        expect(taskProvider.tasks, isEmpty);
        expect(taskProvider.currentView, 'all');
        expect(taskProvider.searchKeyword, '');
        expect(taskProvider.databasePath, isNull);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
        expect(taskProvider.hasError, isFalse);
        expect(taskProvider.hasMoreData, isTrue);
      });

      test('should have correct getters', () {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        expect(taskProvider.tasks, isList);
        expect(taskProvider.currentView, isA<String>());
        expect(taskProvider.searchKeyword, isA<String>());
        expect(taskProvider.databasePath, isNull);
        expect(taskProvider.repository, equals(mockTaskRepository));
        expect(taskProvider.isLoading, isA<bool>());
        expect(taskProvider.error, isNull);
        expect(taskProvider.hasError, isA<bool>());
        expect(taskProvider.hasMoreData, isA<bool>());
      });
    });

    group('loadAllTasks method', () {
      test('should load all incomplete tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();

        expect(taskProvider.currentView, 'all');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadAllTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('loadTodayTasks method', () {
      test('should load today tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadTodayTasks();

        expect(taskProvider.currentView, 'today');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadTodayTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadTodayTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('loadPlannedTasks method', () {
      test('should load planned tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadPlannedTasks();

        expect(taskProvider.currentView, 'planned');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadPlannedTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadPlannedTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('loadCompletedTasks method', () {
      test('should load completed tasks', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadCompletedTasks();

        expect(taskProvider.currentView, 'completed');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadCompletedTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadCompletedTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('loadTasksByList method', () {
      test('should load tasks by list', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadTasksByList(1);

        expect(taskProvider.currentView, 'list');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.loadTasksByList(1);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadTasksByList(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('searchTasks method', () {
      test('should search tasks with keyword', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.searchTasks('test');

        expect(taskProvider.currentView, 'search');
        expect(taskProvider.searchKeyword, 'test');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during search', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.searchTasks('test');

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when search fails', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.searchTasks('test');

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('addTask method', () {
      test('should add task successfully when connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set error when database is not connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set loading state during add', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when add fails', () async {
        final mockTaskRepository = FailingAddTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.addTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('updateTask method', () {
      test('should update task successfully when connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(task);

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set error when database is not connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set loading state during update', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        final task = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(task);

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set error when update fails', () async {
        final mockTaskRepository = FailingUpdateTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final task = Task(
          id: 1,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskProvider.updateTask(task);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('toggleTaskCompleted method', () {
      test('should toggle task successfully when connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.toggleTaskCompleted(1);

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set error when database is not connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.toggleTaskCompleted(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set loading state during toggle', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
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
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.toggleTaskCompleted(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('deleteTask method', () {
      test('should delete task successfully when connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.deleteTask(1);

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set error when database is not connected', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.deleteTask(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.validation);
        expect(taskProvider.isLoading, isFalse);
      });

      test('should set loading state during delete', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
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
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.deleteTask(1);

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
        expect(taskProvider.error!.type, AppErrorType.database);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('refreshTasks method', () {
      test('should reload tasks with current view', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();
        await taskProvider.refreshTasks();

        expect(taskProvider.currentView, 'all');
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should set loading state during refresh', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool wasLoading = false;
        taskProvider.addListener(() {
          if (taskProvider.isLoading) {
            wasLoading = true;
          }
        });

        await taskProvider.refreshTasks();

        expect(wasLoading, isTrue);
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('loadMoreTasks method', () {
      test('should load more tasks when hasMoreData is true', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();
        await taskProvider.loadMoreTasks();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.hasError, isFalse);
      });

      test('should not load more tasks when hasMoreData is false', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();
        await taskProvider.loadMoreTasks();
        await taskProvider.loadMoreTasks();

        expect(taskProvider.isLoading, isFalse);
      });

      test('should not load more tasks when isLoading is true', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        final loadFuture = taskProvider.loadAllTasks();
        await taskProvider.loadMoreTasks();

        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('updateDatabasePath method', () {
      test('should update database path', () {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        taskProvider.updateDatabasePath('/path/to/database.db');

        expect(taskProvider.databasePath, '/path/to/database.db');
      });

      test('should notify listeners when database path changes', () {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool notified = false;
        taskProvider.addListener(() {
          notified = true;
        });

        taskProvider.updateDatabasePath('/path/to/database.db');

        expect(notified, isTrue);
      });
    });

    group('clearTasks method', () {
      test('should clear all tasks and reset view', () {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        taskProvider.clearTasks();

        expect(taskProvider.tasks, isEmpty);
        expect(taskProvider.currentView, 'all');
        expect(taskProvider.searchKeyword, '');
      });

      test('should notify listeners when tasks are cleared', () {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        bool notified = false;
        taskProvider.addListener(() {
          notified = true;
        });

        taskProvider.clearTasks();

        expect(notified, isTrue);
      });
    });

    group('Error handling', () {
      test('should clear error on successful load', () async {
        final mockTaskRepository = MockTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();

        expect(taskProvider.hasError, isFalse);
        expect(taskProvider.error, isNull);
      });

      test('should set error after failed operation', () async {
        final mockTaskRepository = FailingLoadTaskRepository();
        final mockDatabaseService = MockDatabaseService();
        mockDatabaseService.setConnected(true);

        final taskProvider = TaskProvider.test(
          taskRepository: mockTaskRepository,
          databaseService: mockDatabaseService,
        );

        await taskProvider.loadAllTasks();

        expect(taskProvider.hasError, isTrue);
        expect(taskProvider.error, isNotNull);
      });
    });
  });
}
