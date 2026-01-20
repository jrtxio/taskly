import 'dart:io';
import '../interfaces/config_service_interface.dart';
import '../utils/path_utils.dart';
import '../utils/app_logger.dart';

class ConfigService implements ConfigServiceInterface {
  // Initialize config service (no async needed for file-based config)
  @override
  Future<void> init() async {
    // Ensure config directory exists
    PathUtils.ensureDirectoryExists(PathUtils.getDefaultAppDir().path);
  }

  // Keys for config items - using exact same names as racket version for compatibility
  static const String _lastDbPathKey = 'last-db-path';
  static const String _languageKey = 'language';
  static const String _lastSelectedListIdKey = 'last-selected-list-id';

  // Read all configs from file
  Map<String, String> _readConfigs() {
    final configPath = PathUtils.getConfigFilePath();
    final file = File(configPath);

    if (!file.existsSync()) {
      return {};
    }

    final Map<String, String> configs = {};

    try {
      final lines = file.readAsLinesSync();

      for (final line in lines) {
        final trimmedLine = line.trim();

        // Skip empty lines and comments (support both ; and #)
        if (trimmedLine.isEmpty ||
            trimmedLine.startsWith(';') ||
            trimmedLine.startsWith('#')) {
          continue;
        }

        // Parse key-value pair, supporting both = and : as separators
        final parts = trimmedLine.split(RegExp(r'[=:]'));
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          configs[key] = value;
        }
      }
    } catch (e) {
      logger.e('Error reading config file', error: e);
    }

    return configs;
  }

  // Save all configs to file
  bool _saveConfigs(Map<String, String> configs) {
    final configPath = PathUtils.getConfigFilePath();
    final file = File(configPath);

    try {
      final content = configs.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('\n');

      file.writeAsStringSync(content);
      return true;
    } catch (e) {
      logger.e('Error saving config file', error: e);
      return false;
    }
  }

  // Get last used database path
  @override
  String? getLastDbPath() {
    final configs = _readConfigs();
    // Support both new format (last-db-path) and old format (last_db_path) for backward compatibility
    return configs[_lastDbPathKey] ?? configs['last_db_path'];
  }

  // Save last used database path
  @override
  Future<bool> saveLastDbPath(String path) async {
    final configs = _readConfigs();
    configs[_lastDbPathKey] = path;
    // Remove old format if exists
    configs.remove('last_db_path');
    return _saveConfigs(configs);
  }

  // Get last selected list ID
  @override
  int? getLastSelectedListId() {
    final configs = _readConfigs();
    final value = configs[_lastSelectedListIdKey];
    return value != null ? int.tryParse(value) : null;
  }

  // Save last selected list ID
  @override
  Future<bool> saveLastSelectedListId(int listId) async {
    final configs = _readConfigs();
    configs[_lastSelectedListIdKey] = listId.toString();
    return _saveConfigs(configs);
  }

  // Get application language
  @override
  String getLanguage() {
    final configs = _readConfigs();
    return configs[_languageKey] ?? 'zh'; // Default to Chinese
  }

  // Save application language
  @override
  Future<bool> saveLanguage(String language) async {
    final configs = _readConfigs();
    configs[_languageKey] = language;
    return _saveConfigs(configs);
  }

  // Clear all configs (for testing purposes)
  @override
  Future<bool> clear() async {
    final configPath = PathUtils.getConfigFilePath();
    final file = File(configPath);

    try {
      if (file.existsSync()) {
        file.deleteSync();
      }
      return true;
    } catch (e) {
      logger.e('Error clearing configs', error: e);
      return false;
    }
  }
}
