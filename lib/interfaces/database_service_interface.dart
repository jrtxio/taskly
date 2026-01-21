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
  Future<int> addList(String name, {String? icon, int? color});
  
  // Update list
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  });
  
  // Delete list
  Future<int> deleteList(int id);
  
  // ------------------------
  // Tasks Table Operations
  // ------------------------
  
  // Get all tasks
  Future<List<Task>> getAllTasks();

  // Get tasks by list with pagination
  Future<List<Task>> getTasksByList(int listId, {int limit = 50, int offset = 0});

  // Get completed tasks by list with pagination
  Future<List<Task>> getCompletedTasksByList(int listId, {int limit = 50, int offset = 0});

  // Get tasks by list including completed tasks
  Future<List<Task>> getTasksByListIncludingCompleted(int listId, {int limit = 50, int offset = 0});

  // Get all tasks including completed
  Future<List<Task>> getAllTasksIncludingCompleted({int limit = 50, int offset = 0});

  // Get today's tasks with pagination
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0});

  // Get planned tasks (with due date and not completed) with pagination
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0});

  // Get planned tasks including completed
  Future<List<Task>> getPlannedTasksIncludingCompleted({int limit = 50, int offset = 0});

  // Get all incomplete tasks with pagination
  Future<List<Task>> getIncompleteTasks({int limit = 50, int offset = 0});

  // Get all completed tasks with pagination
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0});

  // Get total task count by list
  Future<int> getTaskCountByList(int listId);

  // Get total incomplete task count
  Future<int> getIncompleteTaskCount();

  // Get total completed task count
  Future<int> getCompletedTaskCount();

  // Get total today task count
  Future<int> getTodayTaskCount();

  // Get total planned task count
  Future<int> getPlannedTaskCount();
  
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

  // Check if database is connected
  bool isConnected();

  // Reset database connection
  void resetConnection();
}