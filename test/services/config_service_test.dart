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

    test('should handle empty string for db path', () async {
      // Save empty string
      const emptyPath = '';
      await configService.saveLastDbPath(emptyPath);
      
      // Retrieve db path
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, emptyPath);
    });

    test('should handle very long db path', () async {
      // Create a very long path
      const base = '/a';
      final longPath = base * 1000;
      
      await configService.saveLastDbPath(longPath);
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, longPath);
    });

    test('should handle special characters in db path', () async {
      // Save path with special characters
      const specialPath = '/path/with spaces & special!@#%.db';
      await configService.saveLastDbPath(specialPath);
      
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, specialPath);
    });

    test('should handle unicode characters in db path', () async {
      // Save path with unicode characters
      const unicodePath = '/路径/数据库/文件.db';
      await configService.saveLastDbPath(unicodePath);
      
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, unicodePath);
    });

    test('should handle invalid language codes', () async {
      // Save invalid language
      const invalidLanguage = 'invalid_lang';
      await configService.saveLanguage(invalidLanguage);
      
      final retrievedLanguage = configService.getLanguage();
      expect(retrievedLanguage, invalidLanguage);
    });

    test('should handle empty language', () async {
      // Save empty language
      const emptyLanguage = '';
      await configService.saveLanguage(emptyLanguage);
      
      final retrievedLanguage = configService.getLanguage();
      expect(retrievedLanguage, emptyLanguage);
    });

    test('should handle negative list id', () async {
      // Save negative list id
      const negativeId = -1;
      await configService.saveLastSelectedListId(negativeId);
      
      final retrievedListId = configService.getLastSelectedListId();
      expect(retrievedListId, negativeId);
    });

    test('should handle very large list id', () async {
      // Save very large list id
      const largeId = 999999999;
      await configService.saveLastSelectedListId(largeId);
      
      final retrievedListId = configService.getLastSelectedListId();
      expect(retrievedListId, largeId);
    });

    test('should handle zero list id', () async {
      // Save zero list id
      const zeroId = 0;
      await configService.saveLastSelectedListId(zeroId);
      
      final retrievedListId = configService.getLastSelectedListId();
      expect(retrievedListId, zeroId);
    });

    test('should handle multiple save operations', () async {
      // Save multiple db paths in sequence
      await configService.saveLastDbPath('/path1.db');
      await configService.saveLastDbPath('/path2.db');
      await configService.saveLastDbPath('/path3.db');
      
      // Only last value should be stored
      final retrievedPath = configService.getLastDbPath();
      expect(retrievedPath, '/path3.db');
    });

    test('should handle null-like values', () async {
      // Language has default value 'zh', let's test it
      expect(configService.getLanguage(), 'zh');
      
      // Get values without saving
      expect(configService.getLastDbPath(), null);
      expect(configService.getLastSelectedListId(), null);
    });

    test('should handle rapid save and read operations', () async {
      // Perform rapid save and read operations
      for (int i = 0; i < 100; i++) {
        await configService.saveLastDbPath('/path$i.db');
        final retrievedPath = configService.getLastDbPath();
        expect(retrievedPath, '/path$i.db');
      }
    });

    test('should preserve values after multiple operations', () async {
      // Save all configs
      await configService.saveLastDbPath('/final/path.db');
      await configService.saveLanguage('zh');
      await configService.saveLastSelectedListId(100);
      
      // Perform other operations
      await configService.saveLastDbPath('/temp/path.db');
      await configService.saveLastDbPath('/final/path.db');
      
      // Verify original values are preserved
      expect(configService.getLastDbPath(), '/final/path.db');
      expect(configService.getLanguage(), 'zh');
      expect(configService.getLastSelectedListId(), 100);
    });

    test('should handle clear and re-save', () async {
      // Save configs
      await configService.saveLastDbPath('/path.db');
      await configService.saveLanguage('en');
      await configService.saveLastSelectedListId(50);
      
      // Clear
      await configService.clear();
      
      // Re-save
      await configService.saveLastDbPath('/new/path.db');
      await configService.saveLanguage('zh');
      await configService.saveLastSelectedListId(75);
      
      // Verify new values
      expect(configService.getLastDbPath(), '/new/path.db');
      expect(configService.getLanguage(), 'zh');
      expect(configService.getLastSelectedListId(), 75);
    });
  });
}