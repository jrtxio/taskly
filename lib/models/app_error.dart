/// Custom application error class
enum AppErrorType {
  /// Network-related errors
  network,
  
  /// Database-related errors
  database,
  
  /// Configuration-related errors
  config,
  
  /// Validation errors
  validation,
  
  /// Unknown errors
  unknown,
}

class AppError {
  final String message;
  final AppErrorType type;
  final Object? originalError;

  const AppError({
    required this.message,
    this.type = AppErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, originalError: $originalError)';
  }
}