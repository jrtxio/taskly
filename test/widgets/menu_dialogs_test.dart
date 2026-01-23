import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskly/widgets/menu_dialogs.dart';
import 'package:taskly/providers/app_provider.dart';
import 'package:taskly/interfaces/config_service_interface.dart';

void main() {
  group('AppMenuBar Widget Tests', () {
    late AppProvider mockAppProvider;

    setUp(() {
      mockAppProvider = AppProvider.test(
        configService: MockConfigService(),
      );
    });

    testWidgets('should display all menu buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      expect(find.text('文件'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('帮助'), findsOneWidget);
    });

    testWidgets('should display correct language label for Chinese', (WidgetTester tester) async {
      mockAppProvider.setLanguage('zh');
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      expect(find.text('简体中文'), findsOneWidget);
    });

    testWidgets('should display correct language label for English', (WidgetTester tester) async {
      mockAppProvider.setLanguage('en');
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('should show language dialog when language menu item is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      expect(find.text('选择语言'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('简体中文'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('should change language when language option is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(mockAppProvider.language, 'en');
      expect(find.text('选择语言'), findsNothing);
    });

    testWidgets('should show about dialog when about menu item is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('帮助'));
      await tester.pumpAndSettle();

      expect(find.text('关于 Taskly'), findsOneWidget);
      expect(find.text('Taskly'), findsOneWidget);
      expect(find.textContaining('0.0.1'), findsOneWidget);
    });

    testWidgets('should have correct height and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const Scaffold(
              body: AppMenuBar(),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppMenuBar),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.minHeight, 48);
      expect(container.constraints?.maxHeight, 48);
    });
  });
}

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
  String getLanguage() => 'zh';

  @override
  Future<bool> saveLanguage(String language) async => true;

  @override
  Future<bool> clear() async => true;
}
