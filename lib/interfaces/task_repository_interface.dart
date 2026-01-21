import '../models/task.dart';

abstract class TaskRepositoryInterface {
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

  // Get today's tasks including completed
  Future<List<Task>> getTodayTasksIncludingCompleted({int limit = 50, int offset = 0});

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
  Future<List<Task>> getTasksByView(String viewType, {int? listId, String? keyword, int limit = 50, int offset = 0, bool showCompleted = false});
  
  // Group tasks by list
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks);
}