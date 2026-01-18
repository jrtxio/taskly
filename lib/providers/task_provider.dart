import 'package:flutter/material.dart';
import '../interfaces/task_repository_interface.dart';
import '../locator/service_locator.dart';
import '../models/app_error.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  // Public constructor for testing purposes
  TaskProvider.test({required TaskRepositoryInterface taskRepository})
    : _taskRepository = taskRepository;

  // Regular constructor with service locator
  TaskProvider() : _taskRepository = sl<TaskRepositoryInterface>();

  final TaskRepositoryInterface _taskRepository;
  List<Task> _tasks = [];
  String _currentView = 'all'; // today, planned, all, completed, list, search
  String _searchKeyword = '';
  bool _isLoading = false;
  AppError? _error;

  // Getters
  List<Task> get tasks => _tasks;
  String get currentView => _currentView;
  String get searchKeyword => _searchKeyword;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  // Initialize tasks
  Future<void> loadTasks({
    String viewType = 'all',
    int? listId,
    String? keyword,
  }) async {
    _isLoading = true;
    _currentView = viewType;
    _searchKeyword = keyword ?? '';
    _clearError();
    notifyListeners();

    try {
      _tasks = await _taskRepository.getTasksByView(
        viewType,
        listId: listId,
        keyword: keyword,
      );
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to load tasks: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error loading tasks: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load tasks by list
  Future<void> loadTasksByList(int listId) async {
    await loadTasks(viewType: 'list', listId: listId);
  }

  // Load today's tasks
  Future<void> loadTodayTasks() async {
    await loadTasks(viewType: 'today');
  }

  // Load planned tasks
  Future<void> loadPlannedTasks() async {
    await loadTasks(viewType: 'planned');
  }

  // Load all incomplete tasks
  Future<void> loadAllTasks() async {
    await loadTasks(viewType: 'all');
  }

  // Load completed tasks
  Future<void> loadCompletedTasks() async {
    await loadTasks(viewType: 'completed');
  }

  // Search tasks
  Future<void> searchTasks(String keyword) async {
    await loadTasks(viewType: 'search', keyword: keyword);
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _taskRepository.addTask(task);
      await loadTasks(viewType: _currentView, keyword: _searchKeyword);
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to add task: ${e.toString()}',
          type: e is ArgumentError
              ? AppErrorType.validation
              : AppErrorType.database,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error adding task: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _taskRepository.updateTask(task);
      await loadTasks(viewType: _currentView, keyword: _searchKeyword);
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to update task: ${e.toString()}',
          type: e is ArgumentError
              ? AppErrorType.validation
              : AppErrorType.database,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error updating task: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompleted(int id) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _taskRepository.toggleTaskCompleted(id);
      await loadTasks(viewType: _currentView, keyword: _searchKeyword);
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to toggle task status: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error toggling task status: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(int id) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _taskRepository.deleteTask(id);
      await loadTasks(viewType: _currentView, keyword: _searchKeyword);
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to delete task: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error deleting task: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await loadTasks(viewType: _currentView, keyword: _searchKeyword);
  }

  // Private methods
  void _setError(AppError error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
