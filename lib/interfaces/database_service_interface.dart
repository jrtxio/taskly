import '../models/task.dart';
import '../models/todo_list.dart';

abstract class DatabaseServiceInterface {
  // Initialize database
  Future<void> init();

  // Set custom database path
  void setDatabasePath(String path);
  
  // ------------------------
  // Lists Table Operations
  // ------------------------
  
  // Get all lists
  Future<List<TodoList>> getAllLists();
  
  // Get list by id
  Future<TodoList?> getListById(int id);
  
  // Add list
  Future<int> addList(String name);
  
  // Update list
  Future<int> updateList(int id, String name);
  
  // Delete list
  Future<int> deleteList(int id);
  
  // ------------------------
  // Tasks Table Operations
  // ------------------------
  
  // Get all tasks
  Future<List<Task>> getAllTasks();
  
  // Get tasks by list
  Future<List<Task>> getTasksByList(int listId);
  
  // Get today's tasks
  Future<List<Task>> getTodayTasks();
  
  // Get planned tasks (with due date and not completed)
  Future<List<Task>> getPlannedTasks();
  
  // Get all incomplete tasks
  Future<List<Task>> getIncompleteTasks();
  
  // Get all completed tasks
  Future<List<Task>> getCompletedTasks();
  
  // Add task
  Future<int> addTask(Task task);
  
  // Update task
  Future<int> updateTask(Task task);
  
  // Toggle task completed status
  Future<int> toggleTaskCompleted(int id);
  
  // Delete task
  Future<int> deleteTask(int id);
  
  // Search tasks by keyword
  Future<List<Task>> searchTasks(String keyword);
  
  // Close database
  Future<void> close();
}