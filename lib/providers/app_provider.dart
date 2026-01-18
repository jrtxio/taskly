import 'package:flutter/material.dart';
import '../interfaces/config_service_interface.dart';
import '../locator/service_locator.dart';

import '../models/app_error.dart';

class AppProvider with ChangeNotifier {
  // Public constructor for testing purposes
  AppProvider.test({required ConfigServiceInterface configService})
    : _configService = configService;

  // Regular constructor with service locator
  AppProvider() : _configService = sl<ConfigServiceInterface>();

  final ConfigServiceInterface _configService;
  String? _dbPath;
  String _language = 'zh';
  bool _isLoading = false;
  AppError? _error;

  // Getters
  String? get dbPath => _dbPath;
  String get language => _language;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  // Initialize app provider
  Future<void> init() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Initialize config service
      await _configService.init();

      // Load configs
      _dbPath = _configService.getLastDbPath();
      _language = _configService.getLanguage();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to initialize app: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error initializing app: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save database path
  Future<void> saveDbPath(String path) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _configService.saveLastDbPath(path);
      _dbPath = path;
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: 'Failed to save database path: ${e.toString()}',
          type: AppErrorType.config,
          originalError: e,
        ),
      );
      // ignore: avoid_print
      print('Error saving database path: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change language
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
      // ignore: avoid_print
      print('Error changing language: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set loading state
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
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
