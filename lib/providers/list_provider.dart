import 'package:flutter/material.dart';
import '../interfaces/config_service_interface.dart';
import '../interfaces/list_repository_interface.dart';
import '../interfaces/database_service_interface.dart';
import '../locator/service_locator.dart';
import '../models/app_error.dart';
import '../models/todo_list.dart';
import '../utils/app_logger.dart';

class ListProvider with ChangeNotifier {
  // Public constructor for testing purposes
  ListProvider.test({
    required ListRepositoryInterface listRepository,
    required ConfigServiceInterface configService,
    DatabaseServiceInterface? databaseService,
  }) : _listRepository = listRepository,
       _configService = configService,
       _databaseService = databaseService ?? sl<DatabaseServiceInterface>();

  // Regular constructor with service locator
  ListProvider()
    : _listRepository = sl<ListRepositoryInterface>(),
      _configService = sl<ConfigServiceInterface>(),
      _databaseService = sl<DatabaseServiceInterface>();

  final ListRepositoryInterface _listRepository;
  final ConfigServiceInterface _configService;
  final DatabaseServiceInterface _databaseService;
  List<TodoList> _lists = [];
  TodoList? _selectedList;
  bool _isLoading = false;
  AppError? _error;

  // Getters
  List<TodoList> get lists => _lists;
  TodoList? get selectedList => _selectedList;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  // Initialize lists
  Future<void> loadLists() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _lists = await _listRepository.getAllLists();

      // Try to load last selected list from config
      if (_lists.isNotEmpty) {
        final lastSelectedId = _configService.getLastSelectedListId();
        if (lastSelectedId != null) {
          final savedList = _lists.firstWhere(
            (list) => list.id == lastSelectedId,
            orElse: () => _lists.first,
          );
          _selectedList = savedList;
        } else {
          // Select first list if none is selected and no saved selection
          _selectedList = _lists.first;
        }
      }
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to load lists: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error loading lists', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a list
  void selectList(TodoList list) {
    _selectedList = list;
    // Save selected list ID to config
    _configService.saveLastSelectedListId(list.id).catchError((e, stackTrace) {
      logger.e('Error saving selected list', error: e, stackTrace: stackTrace);
      return false;
    });
    notifyListeners();
  }

  // Add a new list
  Future<void> addList(String name, {String? icon, Color? color}) async {
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
      await _listRepository.addList(
        name,
        icon: icon,
        color: color?.value,
      );
      await loadLists();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to add list: ${e.toString()}',
          type: e is ArgumentError
              ? AppErrorType.validation
              : AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error adding list', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing list
  Future<void> updateList(
    int id,
    String name, {
    String? icon,
    Color? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async {
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
      print('DEBUG: ListProvider.updateList - id: $id, name: $name, icon: $icon, color: $color, clearIcon: $clearIcon, clearColor: $clearColor');
      await _listRepository.updateList(
        id,
        name,
        icon: icon,
        color: color?.value,
        clearIcon: clearIcon,
        clearColor: clearColor,
      );
      print('DEBUG: ListProvider.updateList - repository update completed, calling loadLists');
      await loadLists();
      print('DEBUG: ListProvider.updateList - loadLists completed, current lists: ${_lists.map((l) => "id=${l.id}, name=${l.name}, icon=${l.icon}, color=${l.color}").toList()}');
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to update list: ${e.toString()}',
          type: e is ArgumentError
              ? AppErrorType.validation
              : AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error updating list', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rename a list (alias for updateList with just name)
  Future<void> renameList(int id, String name) async {
    await updateList(id, name);
  }

  // Update list icon
  Future<void> updateListIcon(int id, String icon) async {
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
      await _listRepository.updateListIcon(id, icon);
      await loadLists();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to update list icon: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error updating list icon', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update list color
  Future<void> updateListColor(int id, Color color) async {
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
      await _listRepository.updateListColor(id, color.value);
      await loadLists();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to update list color: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error updating list color', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a list
  Future<void> deleteList(int id) async {
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
      await _listRepository.deleteList(id);
      // If the deleted list was selected, select the first list
      if (_selectedList?.id == id) {
        _selectedList = null;
      }
      await loadLists();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to delete list: ${e.toString()}',
          type: AppErrorType.database,
          originalError: e,
        ),
      );
      logger.e('Error deleting list', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh lists
  Future<void> refreshLists() async {
    await loadLists();
  }

  // Clear all lists
  void clearLists() {
    _lists = [];
    _selectedList = null;
    notifyListeners();
  }

  // Private methods
  void _setError(AppError error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
