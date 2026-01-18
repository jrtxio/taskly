import '../interfaces/database_service_interface.dart';
import '../interfaces/list_repository_interface.dart';
import '../models/todo_list.dart';

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
  Future<int> addList(String name) async {
    // Validate list name
    if (name.trim().isEmpty) {
      throw ArgumentError('List name cannot be empty');
    }
    return await _databaseService.addList(name.trim());
  }

  // Update an existing list
  @override
  Future<int> updateList(int id, String name) async {
    // Validate list name
    if (name.trim().isEmpty) {
      throw ArgumentError('List name cannot be empty');
    }
    return await _databaseService.updateList(id, name.trim());
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
