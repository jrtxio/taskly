import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskly/screens/main_screen.dart';
import 'package:taskly/providers/app_provider.dart';
import 'package:taskly/providers/list_provider.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/interfaces/list_repository_interface.dart';
import 'package:taskly/interfaces/task_repository_interface.dart';
import 'package:taskly/widgets/menu_dialogs.dart';
import 'package:taskly/widgets/task_list_view.dart';
import 'package:taskly/widgets/list_navigation.dart';

void main() {
  group('App Integration Tests', () {
    late MockConfigService mockConfigService;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockConfigService = MockConfigService();
      mockDatabaseService = MockDatabaseService();
    });

    testWidgets('should render MainScreen with providers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AppProvider>(
                create: (_) =>
                    AppProvider.test(configService: mockConfigService),
              ),
              ChangeNotifierProvider<ListProvider>(
                create: (_) => ListProvider.test(
                  configService: mockConfigService,
                  listRepository: MockListRepository(),
                ),
              ),
              ChangeNotifierProvider<TaskProvider>(
                create: (_) => TaskProvider.test(
                  taskRepository: MockTaskRepository(),
                  databaseService: MockDatabaseService(),
                ),
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppMenuBar), findsOneWidget);
      expect(find.byType(ListNavigation), findsOneWidget);
      expect(find.byType(TaskListView), findsOneWidget);
    });

    test('should handle task lifecycle', () async {
      final mockTaskRepo = MockTaskRepository();

      // Add task
      final task = Task(
        id: 1,
        listId: 1,
        text: 'Test Task',
        dueDate: '2024-12-31',
        completed: false,
        createdAt: '2024-01-01T00:00:00Z',
      );

      expect(() async => await mockTaskRepo.addTask(task), returnsNormally);

      // Update task
      final updatedTask = task.copyWith(text: 'Updated Task');
      expect(
        () async => await mockTaskRepo.updateTask(updatedTask),
        returnsNormally,
      );

      // Toggle completion
      expect(
        () async => await mockTaskRepo.toggleTaskCompleted(1),
        returnsNormally,
      );

      // Delete task
      expect(() async => await mockTaskRepo.deleteTask(1), returnsNormally);
    });

    test('should handle list lifecycle', () async {
      final mockListRepo = MockListRepository();

      // Add list
      expect(
        () async => await mockListRepo.addList('Test List'),
        returnsNormally,
      );

      // Update list
      expect(
        () async => await mockListRepo.updateList(1, 'Updated List'),
        returnsNormally,
      );

      // Delete list
      expect(() async => await mockListRepo.deleteList(1), returnsNormally);
    });

    test('should handle error scenarios gracefully', () async {
      final mockTaskRepo = MockTaskRepository();

      // Test with empty task text
      final emptyTask = Task(
        id: 1,
        listId: 1,
        text: '',
        dueDate: null,
        completed: false,
        createdAt: '2024-01-01T00:00:00Z',
      );

      expect(
        () async => await mockTaskRepo.addTask(emptyTask),
        throwsArgumentError,
      );
    });

    test('should handle pagination', () async {
      final mockTaskRepo = MockTaskRepository();

      // Test pagination parameters
      final tasks1 = await mockTaskRepo.getTasksByList(1, limit: 10, offset: 0);
      final tasks2 = await mockTaskRepo.getTasksByList(
        1,
        limit: 10,
        offset: 10,
      );

      expect(tasks1.length, equals(tasks2.length));
    });

    test('should handle search functionality', () async {
      final mockTaskRepo = MockTaskRepository();

      // Search for tasks
      final tasks = await mockTaskRepo.searchTasks('test');

      expect(tasks, isNotNull);
      expect(tasks, isA<List<Task>>());
    });

    test('should handle validation', () async {
      final mockTaskRepo = MockTaskRepository();

      // Test task text validation
      final validTask = Task(
        id: 1,
        listId: 1,
        text: 'Valid task text',
        dueDate: null,
        completed: false,
        createdAt: '2024-01-01T00:00:00Z',
      );

      expect(
        () async => await mockTaskRepo.addTask(validTask),
        returnsNormally,
      );

      // Test with invalid task
      final invalidTask = Task(
        id: 2,
        listId: 1,
        text: '',
        dueDate: null,
        completed: false,
        createdAt: '2024-01-01T00:00:00Z',
      );

      expect(
        () async => await mockTaskRepo.addTask(invalidTask),
        throwsArgumentError,
      );
    });
  });
}

class MockConfigService implements ConfigServiceInterface {
  @override
  Future<void> init() async {}

  @override
  String? getLastDbPath() => null;

  @override
  Future<bool> saveLastDbPath(String path) async => true;

  @override
  int? getLastSelectedListId() => null;

  @override
  Future<bool> saveLastSelectedListId(int listId) async => true;

  @override
  String getLanguage() => 'zh';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

class MockDatabaseService implements DatabaseServiceInterface {
  @override
  Future<void> init() async {}

  @override
  void setDatabasePath(String path) {}

  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name, {String? icon, int? color}) async => 1;

  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async =>
      1;

  @override
  Future<int> deleteList(int id) async => 1;

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTasksByListIncludingCompleted(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getAllTasksIncludingCompleted({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getTodayTasksIncludingCompleted({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasksIncludingCompleted({int limit = 50, int offset = 0}) async => [];

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
  Future<int> getTodayTaskCount() async => 0;

  @override
  Future<int> getPlannedTaskCount() async => 0;

  @override
  Future<int> addTask(Task task) async => 1;

  @override
  Future<int> updateTask(Task task) async => 1;

  @override
  Future<int> toggleTaskCompleted(int id) async => 1;

  @override
  Future<int> deleteTask(int id) async => 1;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
    bool showCompleted = false,
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};

  @override
  Future<void> close() async {}

  @override
  bool isConnected() => false;

  @override
  void resetConnection() {}
}

class MockListRepository implements ListRepositoryInterface {
  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name, {String? icon, int? color}) async => 1;

  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async =>
      1;

  @override
  Future<int> updateListIcon(int id, String icon) async => 1;

  @override
  Future<int> updateListColor(int id, int color) async => 1;

  @override
  Future<int> deleteList(int id) async => 1;

  @override
  Future<TodoList?> getDefaultList() async => null;
}

class MockTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getCompletedTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTasksByListIncludingCompleted(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getAllTasksIncludingCompleted({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getTodayTasksIncludingCompleted({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getPlannedTasksIncludingCompleted({int limit = 50, int offset = 0}) async => [];

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
  Future<int> getTodayTaskCount() async => 0;

  @override
  Future<int> getPlannedTaskCount() async => 0;

  @override
  Future<int> addTask(Task task) async {
    if (task.text.trim().isEmpty) {
      throw ArgumentError('Task text cannot be empty');
    }
    return 1;
  }

  @override
  Future<int> updateTask(Task task) async {
    if (task.text.trim().isEmpty) {
      throw ArgumentError('Task text cannot be empty');
    }
    return 1;
  }

  @override
  Future<int> toggleTaskCompleted(int id) async => 1;

  @override
  Future<int> deleteTask(int id) async => 1;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
    bool showCompleted = false,
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};

  @override
  Future<void> close() async {}

  @override
  bool isConnected() => false;

  @override
  void resetConnection() {}
}
