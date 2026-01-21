import 'dart:io';
import 'package:flutter/material.dart';
import '../interfaces/config_service_interface.dart';
import '../interfaces/database_service_interface.dart';
import '../locator/service_locator.dart';
import '../models/app_error.dart';
import '../utils/app_logger.dart';
import '../utils/path_utils.dart';

class AppProvider with ChangeNotifier {
  AppProvider.test({required ConfigServiceInterface configService})
    : _configService = configService;

  AppProvider() : _configService = sl<ConfigServiceInterface>();

  ConfigServiceInterface _configService;
  String? _databasePath;
  String _language = 'zh';
  bool _isDarkMode = false;
  bool _isFirstLaunch = true;
  bool _isLoading = false;
  AppError? _error;
  bool _isSidebarVisible = true;

  String? get databasePath => _databasePath;
  String get language => _language;
  bool get isDarkMode => _isDarkMode;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;
  bool get isSidebarVisible => _isSidebarVisible;

  Future<void> init() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      if (_configService == null) {
        _configService = sl<ConfigServiceInterface>();
      }

      await _configService!.init();
      _databasePath = _configService!.getLastDbPath();
      _language = _configService!.getLanguage();
      _isFirstLaunch = _databasePath == null;

      // Set database path to database service if path exists
      if (_databasePath != null) {
        try {
          // Check if database file exists
          final dbFile = File(_databasePath!);
          if (!dbFile.existsSync()) {
            // If database file doesn't exist, treat as first launch
            _isFirstLaunch = true;
            _databasePath = null;
          } else {
            final dbService = sl<DatabaseServiceInterface>();
            dbService.setDatabasePath(_databasePath!);
            // Reinitialize database service with new path
            await dbService.init();
          }
        } catch (dbError, stackTrace) {
          logger.e(
            'Database initialization failed',
            error: dbError,
            stackTrace: stackTrace,
          );
          // If database initialization fails, treat as first launch
          _isFirstLaunch = true;
          _databasePath = null;
        }
      }
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to initialize app: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      logger.e('Error initializing app', error: e, stackTrace: stackTrace);
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
      await _configService!.saveLastDbPath(path);
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
      logger.e('Error saving database path', error: e, stackTrace: stackTrace);
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
      await _configService!.saveLanguage(language);
      _language = language;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to change language: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      logger.e('Error changing language', error: e, stackTrace: stackTrace);
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

  // Toggle sidebar visibility
  void toggleSidebar() {
    _isSidebarVisible = !_isSidebarVisible;
    notifyListeners();
  }

  // Set sidebar visibility
  void setSidebarVisible(bool visible) {
    _isSidebarVisible = visible;
    notifyListeners();
  }

  // Check if database is connected
  bool get isDatabaseConnected {
    try {
      final dbService = sl<DatabaseServiceInterface>();
      return dbService.isConnected();
    } catch (e) {
      return false;
    }
  }

  // Open new database
  Future<void> openNewDatabase(String path) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Validate database path
      if (!PathUtils.isValidDatabasePath(path)) {
        throw Exception('Invalid database path or insufficient permissions');
      }

      // Ensure .db extension
      final dbPath = path.endsWith('.db') ? path : '$path.db';

      // Close existing database if connected
      await closeDatabase();

      // Reset database service connection
      final dbService = sl<DatabaseServiceInterface>();
      dbService.setDatabasePath(dbPath);
      dbService.resetConnection();

      // Initialize new database
      await dbService.init();

      // Save to config
      await _configService!.saveLastDbPath(dbPath);
      _databasePath = dbPath;
      _isFirstLaunch = false;

      logger.i('Successfully opened new database: $dbPath');
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to open new database: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      logger.e('Error opening new database', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open existing database
  Future<void> openExistingDatabase(String path) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Check if file exists
      if (!PathUtils.safeFileExists(path)) {
        throw Exception('Database file does not exist: $path');
      }

      // Close existing database if connected
      await closeDatabase();

      // Set new path and reset connection
      final dbService = sl<DatabaseServiceInterface>();
      dbService.setDatabasePath(path);
      dbService.resetConnection();

      // Initialize database
      await dbService.init();

      // Save to config
      await _configService!.saveLastDbPath(path);
      _databasePath = path;
      _isFirstLaunch = false;

      logger.i('Successfully opened existing database: $path');
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to open database: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      logger.e('Error opening database', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Close database
  Future<void> closeDatabase() async {
    try {
      final dbService = sl<DatabaseServiceInterface>();
      if (dbService.isConnected()) {
        await dbService.close();
        logger.i('Database closed successfully');
      }
      _databasePath = null;
      _isFirstLaunch = true;
      notifyListeners();
    } catch (e, stackTrace) {
      logger.e('Error closing database', error: e, stackTrace: stackTrace);
      _setError(
        AppError(
          message: 'Failed to close database: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
    }
  }
}
