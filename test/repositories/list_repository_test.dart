import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/repositories/list_repository.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/task.dart';

class MockDatabaseService implements DatabaseServiceInterface {
  final List<TodoList> _lists = [];
  int _nextId = 1;

  @override
  Future<void> init() async {}

  @override
  void setDatabasePath(String path) {}

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
  bool isConnected() => false;

  @override
  void resetConnection() {}
}

void main() {
  group('ListRepository Tests', () {
    late ListRepository listRepository;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      listRepository = ListRepository(mockDatabaseService);
    });

    group('getAllLists', () {
      test('should return empty list when no lists exist', () async {
        final lists = await listRepository.getAllLists();
        expect(lists, isEmpty);
      });

      test('should return all lists when lists exist', () async {
        await listRepository.addList('Work');
        await listRepository.addList('Personal');

        final lists = await listRepository.getAllLists();
        expect(lists.length, 2);
        expect(lists[0].name, 'Work');
        expect(lists[1].name, 'Personal');
      });
    });

    group('getListById', () {
      test('should return null when list does not exist', () async {
        final list = await listRepository.getListById(999);
        expect(list, isNull);
      });

      test('should return list when list exists', () async {
        final listId = await listRepository.addList('Work');

        final list = await listRepository.getListById(listId);
        expect(list, isNotNull);
        expect(list!.id, listId);
        expect(list.name, 'Work');
      });
    });

    group('addList', () {
      test('should add list successfully with valid name', () async {
        final listId = await listRepository.addList('Work');
        expect(listId, greaterThan(0));

        final lists = await listRepository.getAllLists();
        expect(lists.length, 1);
        expect(lists[0].id, listId);
        expect(lists[0].name, 'Work');
      });

      test('should trim whitespace from list name', () async {
        final listId = await listRepository.addList('  Work  ');

        final lists = await listRepository.getAllLists();
        expect(lists[0].name, 'Work');
      });

      test('should throw ArgumentError when list name is empty', () async {
        expect(() => listRepository.addList(''), throwsA(isA<ArgumentError>()));
      });

      test(
        'should throw ArgumentError when list name contains only whitespace',
        () async {
          expect(
            () => listRepository.addList('   '),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('updateList', () {
      test('should update list successfully with valid name', () async {
        final listId = await listRepository.addList('Work');

        final result = await listRepository.updateList(listId, 'Personal');
        expect(result, 1);

        final list = await listRepository.getListById(listId);
        expect(list!.name, 'Personal');
      });

      test('should trim whitespace from updated list name', () async {
        final listId = await listRepository.addList('Work');

        await listRepository.updateList(listId, '  Personal  ');

        final list = await listRepository.getListById(listId);
        expect(list!.name, 'Personal');
      });

      test(
        'should throw ArgumentError when updated list name is empty',
        () async {
          final listId = await listRepository.addList('Work');

          expect(
            () => listRepository.updateList(listId, ''),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError when updated list name contains only whitespace',
        () async {
          final listId = await listRepository.addList('Work');

          expect(
            () => listRepository.updateList(listId, '   '),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('should return 0 when updating non-existent list', () async {
        final result = await listRepository.updateList(999, 'New Name');
        expect(result, 0);
      });
    });

    group('deleteList', () {
      test('should delete list successfully', () async {
        final listId = await listRepository.addList('Work');

        final result = await listRepository.deleteList(listId);
        expect(result, 1);

        final lists = await listRepository.getAllLists();
        expect(lists.length, 0);
      });

      test('should return 0 when deleting non-existent list', () async {
        final result = await listRepository.deleteList(999);
        expect(result, 0);
      });
    });

    group('getDefaultList', () {
      test('should return null when no lists exist', () async {
        final defaultList = await listRepository.getDefaultList();
        expect(defaultList, isNull);
      });

      test('should return first list when lists exist', () async {
        await listRepository.addList('Work');
        await listRepository.addList('Personal');

        final defaultList = await listRepository.getDefaultList();
        expect(defaultList, isNotNull);
        expect(defaultList!.name, 'Work');
      });
    });
  });
}
