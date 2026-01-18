import '../interfaces/database_service_interface.dart';
import '../interfaces/task_repository_interface.dart';
import '../models/task.dart';

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
  Future<List<Task>> getTasksByList(int listId) async {
    return await _databaseService.getTasksByList(listId);
  }

  // Get today's tasks
  @override
  Future<List<Task>> getTodayTasks() async {
    return await _databaseService.getTodayTasks();
  }

  // Get planned tasks (with due date and not completed)
  @override
  Future<List<Task>> getPlannedTasks() async {
    return await _databaseService.getPlannedTasks();
  }

  // Get all incomplete tasks
  @override
  Future<List<Task>> getIncompleteTasks() async {
    return await _databaseService.getIncompleteTasks();
  }

  // Get all completed tasks
  @override
  Future<List<Task>> getCompletedTasks() async {
    return await _databaseService.getCompletedTasks();
  }

  // Add a new task
  @override
  Future<int> addTask(Task task) async {
    // Validate task text
    if (task.text.trim().isEmpty) {
      throw ArgumentError('Task text cannot be empty');
    }
    return await _databaseService.addTask(task);
  }

  // Update an existing task
  @override
  Future<int> updateTask(Task task) async {
    // Validate task text
    if (task.text.trim().isEmpty) {
      throw ArgumentError('Task text cannot be empty');
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
  }) async {
    switch (viewType) {
      case 'today':
        return await getTodayTasks();
      case 'planned':
        return await getPlannedTasks();
      case 'all':
        return await getIncompleteTasks();
      case 'completed':
        return await getCompletedTasks();
      case 'list':
        if (listId != null) {
          return await getTasksByList(listId);
        }
        return [];
      case 'search':
        if (keyword != null) {
          return await searchTasks(keyword);
        }
        return [];
      default:
        return await getIncompleteTasks();
    }
  }

  // Group tasks by list
  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async {
    final Map<String, List<Task>> groups = {};

    for (final task in tasks) {
      final listName = task.listName ?? 'Unknown List';
      if (!groups.containsKey(listName)) {
        groups[listName] = [];
      }
      groups[listName]!.add(task);
    }

    return groups;
  }
}
