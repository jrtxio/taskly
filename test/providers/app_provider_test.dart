import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/providers/app_provider.dart';
import 'package:taskly/models/app_error.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/locator/service_locator.dart';

class MockConfigService implements ConfigServiceInterface {
  String? _lastDbPath;
  String _language = 'en';
  int? _lastSelectedListId;

  @override
  Future<void> init() async {}

  @override
  String? getLastDbPath() => _lastDbPath;

  @override
  Future<bool> saveLastDbPath(String path) async {
    _lastDbPath = path;
    return true;
  }

  @override
  int? getLastSelectedListId() => _lastSelectedListId;

  @override
  Future<bool> saveLastSelectedListId(int listId) async {
    _lastSelectedListId = listId;
    return true;
  }

  @override
  String getLanguage() => _language;

  @override
  Future<bool> saveLanguage(String language) async {
    _language = language;
    return true;
  }

  @override
  Future<bool> clear() async {
    _lastDbPath = null;
    _language = 'en';
    _lastSelectedListId = null;
    return true;
  }
}

class FailingInitConfigService implements ConfigServiceInterface {
  @override
  Future<void> init() async {
    throw Exception('Init failed');
  }

  @override
  String? getLastDbPath() => null;

  @override
  Future<bool> saveLastDbPath(String path) async => true;

  @override
  int? getLastSelectedListId() => null;

  @override
  Future<bool> saveLastSelectedListId(int listId) async => true;

  @override
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

class FailingSaveDbPathConfigService implements ConfigServiceInterface {
  @override
  Future<void> init() async {}

  @override
  String? getLastDbPath() => null;

  @override
  Future<bool> saveLastDbPath(String path) async {
    throw Exception('Save failed');
  }

  @override
  int? getLastSelectedListId() => null;

  @override
  Future<bool> saveLastSelectedListId(int listId) async => true;

  @override
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

class FailingChangeLanguageConfigService implements ConfigServiceInterface {
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
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async {
    throw Exception('Save failed');
  }

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
  Future<int> addList(String name, {String? icon, int? color}) async => 0;

  @override
  Future<int> updateList(int id, String name, {String? icon, int? color}) async => 0;

  @override
  Future<int> deleteList(int id) async => 0;

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(int listId, {int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getIncompleteTasks({int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0}) async => [];

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
  bool isConnected() => false;

  @override
  void resetConnection() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sl.reset();
  });

  group('AppProvider Tests', () {
    group('Initialization', () {
      test('should initialize with default values', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        expect(appProvider.databasePath, isNull);
        expect(appProvider.language, 'zh');
        expect(appProvider.isLoading, isFalse);
        expect(appProvider.error, isNull);
        expect(appProvider.hasError, isFalse);
      });

      test('should have correct getters', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        expect(appProvider.databasePath, isNull);
        expect(appProvider.language, isA<String>());
        expect(appProvider.isLoading, isA<bool>());
        expect(appProvider.error, isNull);
        expect(appProvider.hasError, isA<bool>());
      });
    });

    group('init method', () {
      test('should load config values when they exist', () async {
        final mockConfigService = MockConfigService();
        mockConfigService._lastDbPath = '/path/to/database.db';
        mockConfigService._language = 'en';

        final appProvider = AppProvider.test(configService: mockConfigService);
        await appProvider.init();

        expect(appProvider.language, 'en');
        expect(appProvider.isLoading, isFalse);
        expect(appProvider.hasError, isFalse);
      });

      test('should treat as first launch when no database path exists', () async {
        final mockConfigService = MockConfigService();

        final appProvider = AppProvider.test(configService: mockConfigService);
        await appProvider.init();

        expect(appProvider.databasePath, isNull);
        expect(appProvider.isFirstLaunch, isTrue);
        expect(appProvider.isLoading, isFalse);
      });

      test('should set loading state during initialization', () async {
        final mockConfigService = MockConfigService();

        final appProvider = AppProvider.test(configService: mockConfigService);

        bool wasLoading = false;
        appProvider.addListener(() {
          if (appProvider.isLoading) {
            wasLoading = true;
          }
        });

        await appProvider.init();

        expect(wasLoading, isTrue);
        expect(appProvider.isLoading, isFalse);
      });

      test('should set error when initialization fails', () async {
        final mockConfigService = FailingInitConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);
        await appProvider.init();

        expect(appProvider.hasError, isTrue);
        expect(appProvider.error, isNotNull);
        expect(appProvider.error!.type, AppErrorType.config);
        expect(appProvider.isLoading, isFalse);
      });
    });

    group('saveDbPath method', () {
      test('should save database path successfully', () async {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        await appProvider.saveDbPath('/new/path/database.db');

        expect(appProvider.databasePath, '/new/path/database.db');
        expect(appProvider.isFirstLaunch, isFalse);
        expect(appProvider.isLoading, isFalse);
        expect(appProvider.hasError, isFalse);
      });

      test('should set loading state during save', () async {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool wasLoading = false;
        appProvider.addListener(() {
          if (appProvider.isLoading) {
            wasLoading = true;
          }
        });

        await appProvider.saveDbPath('/new/path/database.db');

        expect(wasLoading, isTrue);
        expect(appProvider.isLoading, isFalse);
      });

      test('should set error when save fails', () async {
        final mockConfigService = FailingSaveDbPathConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        await appProvider.saveDbPath('/new/path/database.db');

        expect(appProvider.hasError, isTrue);
        expect(appProvider.error, isNotNull);
        expect(appProvider.error!.type, AppErrorType.config);
      });
    });

    group('setDatabasePath method', () {
      test('should set database path synchronously', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setDatabasePath('/path/to/database.db');

        expect(appProvider.databasePath, '/path/to/database.db');
        expect(appProvider.isFirstLaunch, isFalse);
      });

      test('should notify listeners when database path changes', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool notified = false;
        appProvider.addListener(() {
          notified = true;
        });

        appProvider.setDatabasePath('/path/to/database.db');

        expect(notified, isTrue);
      });
    });

    group('changeLanguage method', () {
      test('should change language successfully', () async {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        await appProvider.changeLanguage('en');

        expect(appProvider.language, 'en');
        expect(appProvider.isLoading, isFalse);
        expect(appProvider.hasError, isFalse);
      });

      test('should set loading state during language change', () async {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool wasLoading = false;
        appProvider.addListener(() {
          if (appProvider.isLoading) {
            wasLoading = true;
          }
        });

        await appProvider.changeLanguage('en');

        expect(wasLoading, isTrue);
        expect(appProvider.isLoading, isFalse);
      });

      test('should set error when language change fails', () async {
        final mockConfigService = FailingChangeLanguageConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        await appProvider.changeLanguage('en');

        expect(appProvider.hasError, isTrue);
        expect(appProvider.error, isNotNull);
        expect(appProvider.error!.type, AppErrorType.config);
      });
    });

    group('setLanguage method', () {
      test('should set language synchronously', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setLanguage('en');

        expect(appProvider.language, 'en');
      });

      test('should notify listeners when language changes', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool notified = false;
        appProvider.addListener(() {
          notified = true;
        });

        appProvider.setLanguage('en');

        expect(notified, isTrue);
      });
    });

    group('setDarkMode method', () {
      test('should set dark mode to true', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setDarkMode(true);

        expect(appProvider.isDarkMode, isTrue);
      });

      test('should set dark mode to false', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setDarkMode(false);

        expect(appProvider.isDarkMode, isFalse);
      });

      test('should notify listeners when dark mode changes', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool notified = false;
        appProvider.addListener(() {
          notified = true;
        });

        appProvider.setDarkMode(true);

        expect(notified, isTrue);
      });
    });

    group('toggleDarkMode method', () {
      test('should toggle dark mode from false to true', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        expect(appProvider.isDarkMode, isFalse);

        appProvider.toggleDarkMode();

        expect(appProvider.isDarkMode, isTrue);
      });

      test('should toggle dark mode from true to false', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setDarkMode(true);
        appProvider.toggleDarkMode();

        expect(appProvider.isDarkMode, isFalse);
      });

      test('should notify listeners when dark mode toggles', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool notified = false;
        appProvider.addListener(() {
          notified = true;
        });

        appProvider.toggleDarkMode();

        expect(notified, isTrue);
      });
    });

    group('setLoading method', () {
      test('should set loading to true', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setLoading(true);

        expect(appProvider.isLoading, isTrue);
      });

      test('should set loading to false', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        appProvider.setLoading(true);
        appProvider.setLoading(false);

        expect(appProvider.isLoading, isFalse);
      });

      test('should notify listeners when loading state changes', () {
        final mockConfigService = MockConfigService();
        final appProvider = AppProvider.test(configService: mockConfigService);

        bool notified = false;
        appProvider.addListener(() {
          notified = true;
        });

        appProvider.setLoading(true);

        expect(notified, isTrue);
      });
    });
  });
}
