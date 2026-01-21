import '../interfaces/database_service_interface.dart';
import '../interfaces/task_repository_interface.dart';
import '../models/task.dart';
import '../utils/validation_helper.dart';

class TaskRepository implements TaskRepositoryInterface {
  final DatabaseServiceInterface _databaseService;

  // Constructor with dependency injection
  TaskRepository(this._databaseService);

  // Get all tasks
  @override
  Future<List<Task>> getAllTasks() async {
    return await _databaseService.getAllTasks();
  }

  // Get tasks by list
  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _databaseService.getTasksByList(
      listId,
      limit: limit,
      offset: offset,
    );
  }

  // Get today's tasks
  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async {
    return await _databaseService.getTodayTasks(limit: limit, offset: offset);
  }

  // Get planned tasks (with due date and not completed)
  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async {
    return await _databaseService.getPlannedTasks(limit: limit, offset: offset);
  }

  // Get all incomplete tasks
  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _databaseService.getIncompleteTasks(
      limit: limit,
      offset: offset,
    );
  }

  // Get all completed tasks
  @override
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0}) async {
    return await _databaseService.getCompletedTasks(
      limit: limit,
      offset: offset,
    );
  }

  // Get total task count by list
  @override
  Future<int> getTaskCountByList(int listId) async {
    return await _databaseService.getTaskCountByList(listId);
  }

  // Get total incomplete task count
  @override
  Future<int> getIncompleteTaskCount() async {
    return await _databaseService.getIncompleteTaskCount();
  }

  // Get total completed task count
  @override
  Future<int> getCompletedTaskCount() async {
    return await _databaseService.getCompletedTaskCount();
  }

  // Get total today task count
  @override
  Future<int> getTodayTaskCount() async {
    return await _databaseService.getTodayTaskCount();
  }

  // Get total planned task count
  @override
  Future<int> getPlannedTaskCount() async {
    return await _databaseService.getPlannedTaskCount();
  }

  // Add a new task
  @override
  Future<int> addTask(Task task) async {
    final error = ValidationHelper.validateTaskText(task.text);
    if (error != null) {
      throw ArgumentError(error.message);
    }
    return await _databaseService.addTask(task);
  }

  // Update an existing task
  @override
  Future<int> updateTask(Task task) async {
    final error = ValidationHelper.validateTaskText(task.text);
    if (error != null) {
      throw ArgumentError(error.message);
    }
    return await _databaseService.updateTask(task);
  }

  // Toggle task completion status
  @override
  Future<int> toggleTaskCompleted(int id) async {
    return await _databaseService.toggleTaskCompleted(id);
  }

  // Delete a task
  @override
  Future<int> deleteTask(int id) async {
    return await _databaseService.deleteTask(id);
  }

  // Search tasks by keyword
  @override
  Future<List<Task>> searchTasks(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }
    return await _databaseService.searchTasks(keyword.trim());
  }

  // Get tasks by view type
  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
    int limit = 50,
    int offset = 0,
  }) async {
    switch (viewType) {
      case 'today':
        return await getTodayTasks(limit: limit, offset: offset);
      case 'planned':
        return await getPlannedTasks(limit: limit, offset: offset);
      case 'all':
        return await getIncompleteTasks(limit: limit, offset: offset);
      case 'completed':
        return await getCompletedTasks(limit: limit, offset: offset);
      case 'list':
        if (listId != null) {
          return await getTasksByList(listId, limit: limit, offset: offset);
        }
        return [];
      case 'search':
        if (keyword != null) {
          return await searchTasks(keyword);
        }
        return [];
      default:
        return await getIncompleteTasks(limit: limit, offset: offset);
    }
  }

  // Group tasks by list
  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async {
    final Map<String, List<Task>> groups = {};

    for (final task in tasks) {
      final key = 'list_${task.listId}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(task);
    }

    return groups;
  }
}
