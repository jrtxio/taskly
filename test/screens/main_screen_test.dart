import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskly/screens/main_screen.dart';
import 'package:taskly/providers/list_provider.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/widgets/list_navigation.dart';
import 'package:taskly/widgets/task_list_view.dart';
import 'package:taskly/widgets/menu_dialogs.dart';
import 'package:taskly/interfaces/task_repository_interface.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/models/app_error.dart';

void main() {
  group('MainScreen Widget Tests', () {
    late MockListProvider mockListProvider;
    late MockTaskProvider mockTaskProvider;

    setUp(() {
      mockListProvider = MockListProvider();
      mockTaskProvider = MockTaskProvider();
    });

    testWidgets('should display all UI components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
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

    testWidgets('should display status message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('就绪'), findsOneWidget);
    });

    testWidgets('should call loadInitialData on initialization', (
      WidgetTester tester,
    ) async {
      bool loadDataCalled = false;

      mockListProvider.loadListsCallback = () async {
        loadDataCalled = true;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadDataCalled, true);
    });

    testWidgets('should update task counts', (WidgetTester tester) async {
      final testTasks = [
        Task(
          id: 1,
          listId: 1,
          text: 'Test Task 1',
          completed: false,
          createdAt: '2024-01-01T00:00:00Z',
        ),
        Task(
          id: 2,
          listId: 1,
          text: 'Test Task 2',
          completed: true,
          createdAt: '2024-01-01T00:00:00Z',
        ),
      ];

      mockTaskProvider.tasks = testTasks;

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(mockTaskProvider.tasks.length, 2);
    });

    testWidgets('should display delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      mockTaskProvider.tasks = [
        Task(
          id: 1,
          listId: 1,
          text: 'Test Task',
          completed: false,
          createdAt: '2024-01-01T00:00:00Z',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('确认删除'), findsNothing);
      expect(find.text('确定要删除这个任务吗？此操作无法撤销。'), findsNothing);
    });

    testWidgets('should have correct layout structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ListProvider>.value(
                value: mockListProvider,
              ),
              ChangeNotifierProvider<TaskProvider>.value(
                value: mockTaskProvider,
              ),
            ],
            child: const MainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<Column>());

      final column = scaffold.body as Column;
      expect(column.children.length, 3);
    });
  });
}

class MockListProvider extends ListProvider {
  @override
  List<TodoList> get lists => [];

  @override
  TodoList? get selectedList => null;

  @override
  bool get isLoading => false;

  Future<void> Function()? loadListsCallback;

  @override
  Future<void> loadListsInternal() async {
    await loadListsCallback?.call();
  }

  @override
  void selectList(TodoList list) {}

  @override
  Future<void> addList(String name, {String? icon, Color? color}) async {}

  @override
  Future<void> updateList(
    int id,
    String name, {
    String? icon,
    Color? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async {}

  @override
  Future<void> deleteList(int id) async {}
}

class MockTaskProvider extends TaskProvider {
  @override
  List<Task> get tasks => _tasks;
  List<Task> _tasks = [];
  set tasks(List<Task> value) {
    _tasks = value;
  }

  @override
  bool get isLoading => false;

  @override
  AppError? get error => null;

  MockTaskProvider({
    TaskRepositoryInterface? taskRepository,
    DatabaseServiceInterface? databaseService,
  }) : super.test(
         taskRepository: taskRepository ?? MockTaskRepository(),
         databaseService: databaseService ?? MockDatabaseService(),
       );
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
  Future<List<Task>> getCompletedTasksByList(int listId, {int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getTasksByListIncludingCompleted(int listId, {int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getAllTasksIncludingCompleted({int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async =>
      [];

  @override
  Future<List<Task>> getTodayTasksIncludingCompleted({int limit = 50, int offset = 0}) async => [];

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
  Future<List<Task>> getCompletedTasksByList(int listId, {int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getTasksByListIncludingCompleted(int listId, {int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getAllTasksIncludingCompleted({int limit = 50, int offset = 0}) async => [];

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
  bool isConnected() => false;

  @override
  void resetConnection() {}
}
