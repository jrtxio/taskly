import 'package:flutter/material.dart';
import '../interfaces/config_service_interface.dart';
import '../locator/service_locator.dart';
import '../models/app_error.dart';

class AppProvider with ChangeNotifier {
  AppProvider.test({required ConfigServiceInterface configService})
      : _configService = configService;

  AppProvider() : _configService = sl<ConfigServiceInterface>();

  final ConfigServiceInterface _configService;
  String? _databasePath;
  String _language = 'zh';
  bool _isDarkMode = false;
  bool _isFirstLaunch = true;
  bool _isLoading = false;
  AppError? _error;

  String? get databasePath => _databasePath;
  String get language => _language;
  bool get isDarkMode => _isDarkMode;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> init() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _configService.init();
      _databasePath = _configService.getLastDbPath();
      _language = _configService.getLanguage();
      _isFirstLaunch = _databasePath == null;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to initialize app: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      print('Error initializing app: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDbPath(String path) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _configService.saveLastDbPath(path);
      _databasePath = path;
      _isFirstLaunch = false;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to save database path: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      print('Error saving database path: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDatabasePath(String path) {
    _databasePath = path;
    _isFirstLaunch = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _configService.saveLanguage(language);
      _language = language;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to change language: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      print('Error changing language: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(AppError error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
