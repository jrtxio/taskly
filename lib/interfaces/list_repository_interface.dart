import '../models/todo_list.dart';

abstract class ListRepositoryInterface {
  // Get all lists
  Future<List<TodoList>> getAllLists();
  
  // Get list by id
  Future<TodoList?> getListById(int id);
  
  // Add a new list
  Future<int> addList(String name);
  
  // Update an existing list
  Future<int> updateList(int id, String name);
  
  // Delete a list
  Future<int> deleteList(int id);
  
  // Get default list (first list)
  Future<TodoList?> getDefaultList();
}