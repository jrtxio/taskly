import '../models/todo_list.dart';

abstract class ListRepositoryInterface {
  // Get all lists
  Future<List<TodoList>> getAllLists();
  
  // Get list by id
  Future<TodoList?> getListById(int id);
  
  // Add a new list
  Future<int> addList(String name, {String? icon, int? color});
  
  // Update an existing list
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  });
  
  // Update list icon
  Future<int> updateListIcon(int id, String icon);
  
  // Update list color
  Future<int> updateListColor(int id, int color);
  
  // Delete a list
  Future<int> deleteList(int id);
  
  // Get default list (first list)
  Future<TodoList?> getDefaultList();
}