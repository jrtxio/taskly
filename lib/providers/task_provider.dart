import 'package:flutter/material.dart';
import '../interfaces/task_repository_interface.dart';
import '../interfaces/database_service_interface.dart';
import '../locator/service_locator.dart';
import '../models/app_error.dart';
import '../models/task.dart';
import '../utils/app_logger.dart';

class TaskProvider with ChangeNotifier {
  TaskProvider.test({
    required TaskRepositoryInterface taskRepository,
    DatabaseServiceInterface? databaseService,
  }) : _taskRepository = taskRepository,
       _databaseService = databaseService ?? sl<DatabaseServiceInterface>();

  TaskProvider()
    : _taskRepository = sl<TaskRepositoryInterface>(),
      _databaseService = sl<DatabaseServiceInterface>();

  final TaskRepositoryInterface _taskRepository;
  final DatabaseServiceInterface _databaseService;
  List<Task> _tasks = [];
  String _currentView = 'all';
  String _searchKeyword = '';
  String? _databasePath;
  bool _isLoading = false;
  AppError? _error;
  int _currentPage = 0;
  static const int _pageSize = 50;
  bool _hasMoreData = true;
  int? _currentListId;

  List<Task> get tasks => _tasks;
  String get currentView => _currentView;
  String get searchKeyword => _searchKeyword;
  String? get databasePath => _databasePath;
  TaskRepositoryInterface get repository => _taskRepository;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;
  bool get hasMoreData => _hasMoreData;
  int? get currentListId => _currentListId;

  Future<void> loadTasks({
    String viewType = 'all',
    int? listId,
    String? keyword,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!_hasMoreData || _isLoading) return;
      _isLoading = true;
      _currentPage++;
    } else {
      _isLoading = true;
      _currentPage = 0;
      _currentView = viewType;
      _searchKeyword = keyword ?? '';
      _clearError();
    }
    notifyListeners();

    try {
      final offset = _currentPage * _pageSize;
      final newTasks = await _taskRepository.getTasksByView(
        viewType,
        listId: listId,
        keyword: keyword,
        limit: _pageSize,
        offset: offset,
      );

      if (loadMore) {
        _tasks.addAll(newTasks);
      } else {
        _tasks = newTasks;
      }

      _hasMoreData = newTasks.length == _pageSize;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to load tasks: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error loading tasks', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksByList(int listId) async {
    _currentListId = listId;
    await loadTasks(viewType: 'list', listId: listId);
  }

  Future<void> loadTodayTasks() async {
    await loadTasks(viewType: 'today');
  }

  Future<void> loadPlannedTasks() async {
    await loadTasks(viewType: 'planned');
  }

  Future<void> loadAllTasks() async {
    await loadTasks(viewType: 'all');
  }

  Future<void> loadCompletedTasks() async {
    await loadTasks(viewType: 'completed');
  }

  Future<void> searchTasks(String keyword) async {
    await loadTasks(viewType: 'search', keyword: keyword);
  }

  Future<void> addTask(Task task) async {
    if (!_databaseService.isConnected()) {
      _setError(
        AppError(message: '数据库未连接，请先创建或打开数据库文件', type: AppErrorType.validation),
      );
      notifyListeners();
      return;
    }

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
      logger.e('Error adding task', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    if (!_databaseService.isConnected()) {
      _setError(
        AppError(message: '数据库未连接，请先创建或打开数据库文件', type: AppErrorType.validation),
      );
      notifyListeners();
      return;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _taskRepository.updateTask(task);
      await loadTasks(
        viewType: _currentView,
        listId: _currentListId,
        keyword: _searchKeyword,
      );
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
      logger.e('Error updating task', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompleted(int id) async {
    if (!_databaseService.isConnected()) {
      _setError(
        AppError(message: '数据库未连接，请先创建或打开数据库文件', type: AppErrorType.validation),
      );
      notifyListeners();
      return;
    }

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
      logger.e('Error toggling task status', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    if (!_databaseService.isConnected()) {
      _setError(
        AppError(message: '数据库未连接，请先创建或打开数据库文件', type: AppErrorType.validation),
      );
      notifyListeners();
      return;
    }

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
      logger.e('Error deleting task', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTasks() async {
    await loadTasks(viewType: _currentView, keyword: _searchKeyword);
  }

  Future<void> loadMoreTasks() async {
    await loadTasks(
      viewType: _currentView,
      keyword: _searchKeyword,
      loadMore: true,
    );
  }

  void updateDatabasePath(String? path) {
    _databasePath = path;
    notifyListeners();
  }

  // Clear all tasks
  void clearTasks() {
    _tasks = [];
    _currentView = 'all';
    _searchKeyword = '';
    notifyListeners();
  }

  void _setError(AppError error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
