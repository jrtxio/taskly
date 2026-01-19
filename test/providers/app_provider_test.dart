import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/providers/app_provider.dart';
import 'package:taskly/models/app_error.dart';

// Mock implementation for testing
class MockConfigService implements ConfigServiceInterface {
  @override
  Future<void> init() async {}

  @override
  String? getLastDbPath() => null;

  @override
  Future<bool> saveLastDbPath(String path) async => true;

  @override
  int? getLastSelectedListId() => null;

  @override
  Future<bool> saveLastSelectedListId(int listId) async => true;

  @override
  String getLanguage() => 'en';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}

void main() {
  group('AppProvider Tests', () {
    test('should initialize with default values', () {
      final mockConfigService = MockConfigService();
      final appProvider = AppProvider.test(configService: mockConfigService);

      expect(appProvider.databasePath, isNull);
      expect(appProvider.language, 'zh');
      expect(appProvider.isLoading, isFalse);
      expect(appProvider.error, isNull);
      expect(appProvider.hasError, isFalse);
    });

    test('should have correct getters', () {
      final mockConfigService = MockConfigService();
      final appProvider = AppProvider.test(configService: mockConfigService);

      expect(appProvider.databasePath, isNull);
      expect(appProvider.language, isA<String>());
      expect(appProvider.isLoading, isA<bool>());
      expect(appProvider.error, isNull);
      expect(appProvider.hasError, isA<bool>());
    });
  });
}
