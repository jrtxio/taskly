import 'dart:io';
import 'package:path/path.dart' as p;
import 'app_logger.dart';

class PathUtils {
  // Get user home directory
  static Directory getUserHomeDirectory() {
    String homePath;

    if (Platform.isWindows) {
      homePath = Platform.environment['USERPROFILE']!;
    } else {
      homePath = Platform.environment['HOME']!;
    }

    return Directory(homePath);
  }

  // Get application default directory (.taskly in home)
  static Directory getDefaultAppDir() {
    final homeDir = getUserHomeDirectory();
    final appDir = Directory(p.join(homeDir.path, '.taskly'));

    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }

    return appDir;
  }

  // Get default database file path
  static String getDefaultDbPath() {
    final appDir = getDefaultAppDir();
    return p.join(appDir.path, 'tasks.db');
  }

  // Get default application directory path (for folder selection UI)
  static String getDefaultAppDirPath() {
    return getDefaultAppDir().path;
  }

  // Get configuration file path
  static String getConfigFilePath() {
    final appDir = getDefaultAppDir();
    return p.join(appDir.path, 'config.ini');
  }

  // Ensure directory exists, create if not
  static bool ensureDirectoryExists(String dirPath) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return true;
    } catch (e) {
      logger.e('Error ensuring directory exists', error: e);
      return false;
    }
  }

  // Check if file exists safely
  static bool safeFileExists(String path) {
    try {
      final file = File(path);
      return file.existsSync();
    } catch (e) {
      logger.e('Error checking file existence', error: e);
      return false;
    }
  }

  // Check if database path is valid and accessible
  static bool isValidDatabasePath(String path) {
    try {
      final file = File(path);
      // Ensure parent directory exists or can be created
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }
      // Check if we can write to the directory
      final testFile = File('${parentDir.path}/.taskly_test');
      testFile.createSync();
      testFile.deleteSync();
      return true;
    } catch (e) {
      logger.e('Error validating database path', error: e);
      return false;
    }
  }

  // Get absolute path
  static String getAbsolutePath(String path) {
    final file = File(path);
    return file.absolute.path;
  }
}
