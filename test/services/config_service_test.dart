import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/services/config_service.dart';
import 'package:taskly/utils/path_utils.dart';
import 'dart:io';

void main() {
  late ConfigService configService;
  late String configFilePath;

  setUp(() async {
    // Create a new config service instance for each test
    configService = ConfigService();
    await configService.init();
    configFilePath = PathUtils.getConfigFilePath();
  });

  tearDown(() async {
    // Clear the config file after each test
    final file = File(configFilePath);
    if (file.existsSync()) {
      await configService.clear();
    }
  });

  group('ConfigService Tests', () {
    test('should initialize and create config directory', () async {
      // Verify the config directory exists
      final configDir = PathUtils.getDefaultAppDir();
      expect(configDir.existsSync(), true);
    });

    test('should save and retrieve last db path', () async {
      // Save a db path
      const testPath = '/test/path/database.db';
      await configService.saveLastDbPath(testPath);
      
      // Retrieve the db path
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, testPath);
    });

    test('should save and retrieve language', () async {
      // Save a language
      const testLanguage = 'en';
      await configService.saveLanguage(testLanguage);
      
      // Retrieve the language
      final retrievedLanguage = configService.getLanguage();
      expect(retrievedLanguage, testLanguage);
    });

    test('should save and retrieve last selected list id', () async {
      // Save a list id
      const testListId = 42;
      await configService.saveLastSelectedListId(testListId);
      
      // Retrieve the list id
      final retrievedListId = configService.getLastSelectedListId();
      expect(retrievedListId, testListId);
    });

    test('should clear all configs', () async {
      // Save some configs
      await configService.saveLastDbPath('/test/path/database.db');
      await configService.saveLanguage('en');
      await configService.saveLastSelectedListId(42);
      
      // Clear all configs
      await configService.clear();
      
      // Verify configs are cleared
      final file = File(configFilePath);
      expect(file.existsSync(), false);
      
      // Verify retrieved values are default or null
      expect(configService.getLastDbPath(), null);
      // Language has a default value of 'zh'
      expect(configService.getLanguage(), 'zh');
      expect(configService.getLastSelectedListId(), null);
    });
  });
}