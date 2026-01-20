import '../interfaces/database_service_interface.dart';
import '../interfaces/list_repository_interface.dart';
import '../models/todo_list.dart';
import '../utils/validation_helper.dart';

class ListRepository implements ListRepositoryInterface {
  final DatabaseServiceInterface _databaseService;

  // Constructor with dependency injection
  ListRepository(this._databaseService);

  // Get all lists
  @override
  Future<List<TodoList>> getAllLists() async {
    return await _databaseService.getAllLists();
  }

  // Get list by id
  @override
  Future<TodoList?> getListById(int id) async {
    return await _databaseService.getListById(id);
  }

  // Add a new list
  @override
  Future<int> addList(String name, {String? icon, int? color}) async {
    final error = ValidationHelper.validateListName(name);
    if (error != null) {
      throw ArgumentError(error.message);
    }
    return await _databaseService.addList(
      name.trim(),
      icon: icon,
      color: color,
    );
  }

  // Update an existing list
  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async {
    final error = ValidationHelper.validateListName(name);
    if (error != null) {
      throw ArgumentError(error.message);
    }
    print('DEBUG: ListRepository.updateList - id: $id, name: $name, icon: $icon, color: $color, clearIcon: $clearIcon, clearColor: $clearColor');
    final result = await _databaseService.updateList(
      id,
      name.trim(),
      icon: icon,
      color: color,
      clearIcon: clearIcon,
      clearColor: clearColor,
    );
    print('DEBUG: ListRepository.updateList - database update result: $result');
    return result;
  }

  // Update list icon
  @override
  Future<int> updateListIcon(int id, String icon) async {
    final list = await getListById(id);
    if (list == null) {
      throw ArgumentError('List not found');
    }
    return await _databaseService.updateList(
      id,
      list.name,
      icon: icon,
      color: list.color?.value,
    );
  }

  // Update list color
  @override
  Future<int> updateListColor(int id, int color) async {
    final list = await getListById(id);
    if (list == null) {
      throw ArgumentError('List not found');
    }
    return await _databaseService.updateList(
      id,
      list.name,
      icon: list.icon,
      color: color,
    );
  }

  // Delete a list
  @override
  Future<int> deleteList(int id) async {
    return await _databaseService.deleteList(id);
  }

  // Get default list (first list)
  @override
  Future<TodoList?> getDefaultList() async {
    final lists = await getAllLists();
    return lists.isNotEmpty ? lists.first : null;
  }
}
