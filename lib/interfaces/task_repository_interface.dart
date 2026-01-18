import '../models/task.dart';

abstract class TaskRepositoryInterface {
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
  
  // Add a new task
  Future<int> addTask(Task task);
  
  // Update an existing task
  Future<int> updateTask(Task task);
  
  // Toggle task completion status
  Future<int> toggleTaskCompleted(int id);
  
  // Delete a task
  Future<int> deleteTask(int id);
  
  // Search tasks by keyword
  Future<List<Task>> searchTasks(String keyword);
  
  // Get tasks by view type
  Future<List<Task>> getTasksByView(String viewType, {int? listId, String? keyword});
  
  // Group tasks by list
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks);
}