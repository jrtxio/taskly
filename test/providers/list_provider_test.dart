import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/interfaces/list_repository_interface.dart';
import 'package:taskly/providers/list_provider.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/app_error.dart';

class MockListRepository implements ListRepositoryInterface {
  final List<TodoList> _lists = [];
  int _nextId = 1;

  @override
  Future<List<TodoList>> getAllLists() async => _lists;

  @override
  Future<TodoList?> getListById(int id) async {
    for (final list in _lists) {
      if (list.id == id) {
        return list;
      }
    }
    return null;
  }

  @override
  Future<int> addList(String name) async {
    final list = TodoList(id: _nextId++, name: name);
    _lists.add(list);
    return list.id;
  }

  @override
  Future<int> updateList(int id, String name) async {
    for (int i = 0; i < _lists.length; i++) {
      if (_lists[i].id == id) {
        _lists[i] = TodoList(id: id, name: name);
        return 1;
      }
    }
    return 0;
  }

  @override
  Future<int> deleteList(int id) async {
    final initialLength = _lists.length;
    _lists.removeWhere((list) => list.id == id);
    return initialLength - _lists.length;
  }

  @override
  Future<TodoList?> getDefaultList() async {
    return _lists.isNotEmpty ? _lists.first : null;
  }
}

class FailingLoadListRepository implements ListRepositoryInterface {
  @override
  Future<List<TodoList>> getAllLists() async {
    throw Exception('Load failed');
  }

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name) async => 0;

  @override
  Future<int> updateList(int id, String name) async => 0;

  @override
  Future<int> deleteList(int id) async => 0;

  @override
  Future<TodoList?> getDefaultList() async => null;
}

class FailingAddListRepository implements ListRepositoryInterface {
  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name) async {
    throw ArgumentError('Empty name');
  }

  @override
  Future<int> updateList(int id, String name) async => 0;

  @override
  Future<int> deleteList(int id) async => 0;

  @override
  Future<TodoList?> getDefaultList() async => null;
}

class FailingUpdateListRepository implements ListRepositoryInterface {
  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name) async => 0;

  @override
  Future<int> updateList(int id, String name) async {
    throw ArgumentError('Empty name');
  }

  @override
  Future<int> deleteList(int id) async => 0;

  @override
  Future<TodoList?> getDefaultList() async => null;
}

class FailingDeleteListRepository implements ListRepositoryInterface {
  final List<TodoList> _lists = [];

  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name) async => 0;

  @override
  Future<int> updateList(int id, String name) async => 0;

  @override
  Future<int> deleteList(int id) async {
    throw Exception('Delete failed');
  }

  @override
  Future<TodoList?> getDefaultList() async => null;
}

class MockConfigService implements ConfigServiceInterface {
  int? _lastSelectedListId;

  @override
  Future<void> init() async {}

  @override
  String? getLastDbPath() => null;

  @override
  Future<bool> saveLastDbPath(String path) async => true;

  @override
  int? getLastSelectedListId() => _lastSelectedListId;

  @override
  Future<bool> saveLastSelectedListId(int listId) async {
    _lastSelectedListId = listId;
    return true;
  }

  @override
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

void main() {
  group('ListProvider Tests', () {
    group('Initialization', () {
      test('should initialize with empty lists and no selected list', () {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        expect(listProvider.lists, isEmpty);
        expect(listProvider.selectedList, isNull);
        expect(listProvider.isLoading, isFalse);
        expect(listProvider.error, isNull);
        expect(listProvider.hasError, isFalse);
      });

      test('should have correct getters', () {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        expect(listProvider.lists, isList);
        expect(listProvider.selectedList, isNull);
        expect(listProvider.isLoading, isA<bool>());
        expect(listProvider.error, isNull);
        expect(listProvider.hasError, isA<bool>());
      });
    });

    group('loadLists method', () {
      test('should load lists successfully', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.addAll([
          TodoList(id: 1, name: 'Work'),
          TodoList(id: 2, name: 'Personal'),
        ]);
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.loadLists();

        expect(listProvider.lists.length, 2);
        expect(listProvider.lists[0].name, 'Work');
        expect(listProvider.lists[1].name, 'Personal');
        expect(listProvider.isLoading, isFalse);
        expect(listProvider.hasError, isFalse);
      });

      test('should select first list when no saved selection exists', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.loadLists();

        expect(listProvider.selectedList, isNotNull);
        expect(listProvider.selectedList!.id, 1);
        expect(listProvider.selectedList!.name, 'Work');
      });

      test('should select saved list when it exists', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.addAll([
          TodoList(id: 1, name: 'Work'),
          TodoList(id: 2, name: 'Personal'),
        ]);
        final mockConfigService = MockConfigService();
        mockConfigService._lastSelectedListId = 2;

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.loadLists();

        expect(listProvider.selectedList, isNotNull);
        expect(listProvider.selectedList!.id, 2);
        expect(listProvider.selectedList!.name, 'Personal');
      });

      test('should set loading state during load', () async {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        bool wasLoading = false;
        listProvider.addListener(() {
          if (listProvider.isLoading) {
            wasLoading = true;
          }
        });

        await listProvider.loadLists();

        expect(wasLoading, isTrue);
        expect(listProvider.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        final mockListRepository = FailingLoadListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.loadLists();

        expect(listProvider.hasError, isTrue);
        expect(listProvider.error, isNotNull);
        expect(listProvider.error!.type, AppErrorType.database);
        expect(listProvider.isLoading, isFalse);
      });
    });

    group('selectList method', () {
      test('should select list and save to config', () async {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        final list = TodoList(id: 1, name: 'Work');
        listProvider.selectList(list);

        expect(listProvider.selectedList, list);
        expect(mockConfigService._lastSelectedListId, 1);
      });

      test('should notify listeners when list is selected', () {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        bool notified = false;
        listProvider.addListener(() {
          notified = true;
        });

        final list = TodoList(id: 1, name: 'Work');
        listProvider.selectList(list);

        expect(notified, isTrue);
      });
    });

    group('addList method', () {
      test('should add list successfully', () async {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.addList('New List');

        expect(mockListRepository._lists.length, 1);
        expect(mockListRepository._lists[0].name, 'New List');
        expect(listProvider.isLoading, isFalse);
        expect(listProvider.hasError, isFalse);
      });

      test('should set loading state during add', () async {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        bool wasLoading = false;
        listProvider.addListener(() {
          if (listProvider.isLoading) {
            wasLoading = true;
          }
        });

        await listProvider.addList('New List');

        expect(wasLoading, isTrue);
        expect(listProvider.isLoading, isFalse);
      });

      test('should set error when add fails', () async {
        final mockListRepository = FailingAddListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.addList('');

        expect(listProvider.hasError, isTrue);
        expect(listProvider.error, isNotNull);
        expect(listProvider.error!.type, AppErrorType.validation);
      });
    });

    group('updateList method', () {
      test('should update list successfully', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.updateList(1, 'Updated Work');

        expect(mockListRepository._lists[0].name, 'Updated Work');
        expect(listProvider.isLoading, isFalse);
        expect(listProvider.hasError, isFalse);
      });

      test('should set loading state during update', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        bool wasLoading = false;
        listProvider.addListener(() {
          if (listProvider.isLoading) {
            wasLoading = true;
          }
        });

        await listProvider.updateList(1, 'Updated Work');

        expect(wasLoading, isTrue);
        expect(listProvider.isLoading, isFalse);
      });

      test('should set error when update fails', () async {
        final mockListRepository = FailingUpdateListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.updateList(1, '');

        expect(listProvider.hasError, isTrue);
        expect(listProvider.error, isNotNull);
        expect(listProvider.error!.type, AppErrorType.validation);
      });
    });

    group('deleteList method', () {
      test('should delete list successfully', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.addAll([
          TodoList(id: 1, name: 'Work'),
          TodoList(id: 2, name: 'Personal'),
        ]);
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.deleteList(1);

        expect(mockListRepository._lists.length, 1);
        expect(mockListRepository._lists[0].name, 'Personal');
        expect(listProvider.isLoading, isFalse);
        expect(listProvider.hasError, isFalse);
      });

      test('should clear selected list when deleting selected list', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        listProvider.selectList(TodoList(id: 1, name: 'Work'));
        await listProvider.deleteList(1);

        expect(listProvider.selectedList, isNull);
      });

      test('should set loading state during delete', () async {
        final mockListRepository = MockListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        bool wasLoading = false;
        listProvider.addListener(() {
          if (listProvider.isLoading) {
            wasLoading = true;
          }
        });

        await listProvider.deleteList(1);

        expect(wasLoading, isTrue);
        expect(listProvider.isLoading, isFalse);
      });

      test('should set error when delete fails', () async {
        final mockListRepository = FailingDeleteListRepository();
        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        await listProvider.deleteList(1);

        expect(listProvider.hasError, isTrue);
        expect(listProvider.error, isNotNull);
        expect(listProvider.error!.type, AppErrorType.database);
      });
    });

    group('refreshLists method', () {
      test('should reload lists', () async {
        final mockListRepository = MockListRepository();
        final mockConfigService = MockConfigService();

        final listProvider = ListProvider.test(
          listRepository: mockListRepository,
          configService: mockConfigService,
        );

        mockListRepository._lists.add(TodoList(id: 1, name: 'Work'));
        await listProvider.refreshLists();

        expect(listProvider.lists.length, 1);
      });
    });
  });
}
