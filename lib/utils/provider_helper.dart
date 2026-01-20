import '../models/app_error.dart';

mixin ProviderHelper<T> {
  List<T> _items = [];
  bool _isLoading = false;
  AppError? _error;

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  void _setError(AppError error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  Future<void> executeWithErrorHandling(
    Future<void> Function() operation,
    String errorMessage,
    AppErrorType errorType,
  ) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      await operation();
    } catch (e, stackTrace) {
      _setError(
        AppError(
          message: errorMessage,
          type: errorType is AppErrorType ? errorType : AppErrorType.database,
          originalError: e,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void notifyListeners();
}
