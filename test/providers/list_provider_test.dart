import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/interfaces/list_repository_interface.dart';
import 'package:taskly/providers/list_provider.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/models/app_error.dart';

// Mock implementations for testing
class MockListRepository implements ListRepositoryInterface {
  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name) async => 1;

  @override
  Future<int> updateList(int id, String name) async => 1;

  @override
  Future<int> deleteList(int id) async => 1;

  @override
  Future<TodoList?> getDefaultList() async => null;
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
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

void main() {
  group('ListProvider Tests', () {
    test('should initialize with empty lists and no selected list', () {
      // Create mock implementations
      final mockListRepository = MockListRepository();
      final mockConfigService = MockConfigService();

      // Create ListProvider with mocked dependencies
      final listProvider = ListProvider.test(
        listRepository: mockListRepository,
        configService: mockConfigService,
      );

      // Assert
      expect(listProvider.lists, isEmpty);
      expect(listProvider.selectedList, isNull);
      expect(listProvider.isLoading, isFalse);
      expect(listProvider.error, isNull);
      expect(listProvider.hasError, isFalse);
    });

    test('should have correct getters', () {
      // Create mock implementations
      final mockListRepository = MockListRepository();
      final mockConfigService = MockConfigService();

      // Create ListProvider with mocked dependencies
      final listProvider = ListProvider.test(
        listRepository: mockListRepository,
        configService: mockConfigService,
      );

      // Assert
      expect(listProvider.lists, isList);
      expect(listProvider.selectedList, isNull);
      expect(listProvider.isLoading, isA<bool>());
      expect(listProvider.error, isNull);
      expect(listProvider.hasError, isA<bool>());
    });
  });
}
