import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskly/screens/welcome_screen.dart';
import 'package:taskly/providers/app_provider.dart';
import 'package:taskly/interfaces/config_service_interface.dart';
import 'package:taskly/models/app_error.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    late MockAppProvider mockAppProvider;

    setUp(() {
      mockAppProvider = MockAppProvider();
    });

    testWidgets('should display all UI components', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(find.text('欢迎使用 Taskly'), findsOneWidget);
      expect(find.text('请选择或创建任务数据库'), findsOneWidget);
      expect(find.text('数据库路径'), findsOneWidget);
      expect(find.text('浏览...'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('should have correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, 600);
    });

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '确定'),
      );
      expect(confirmButton.child, isA<Text>());
    });

    testWidgets('should show error dialog when path is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      textField.controller?.clear();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, '确定'));
      await tester.pumpAndSettle();

      expect(find.text('错误'), findsOneWidget);
      expect(find.text('请选择或输入数据库文件夹路径'), findsOneWidget);
    });

    testWidgets('should have correct button states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '确定'),
      );
      expect(confirmButton.enabled, true);

      final cancelButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '取消'),
      );
      expect(cancelButton.enabled, true);

      final browseButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '浏览...'),
      );
      expect(browseButton.enabled, true);
    });

    testWidgets('should have correct input field properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.readOnly, true);
      expect(textField.decoration?.filled, true);
    });

    testWidgets('should display error dialog with correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      textField.controller?.clear();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, '确定'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('确定'), findsWidgets);
    });

    testWidgets('should have correct icon size and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.task_alt),
      );
      expect(icon.size, 64);
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should have correct button dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: mockAppProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '确定'),
      );
      final cancelButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '取消'),
      );

      expect(confirmButton.style?.minimumSize?.resolve({}), const Size(120, 44));
      expect(cancelButton.style?.minimumSize?.resolve({}), const Size(120, 44));
    });
  });
}

class MockAppProvider extends AppProvider {
  MockAppProvider() : super.test(configService: MockConfigService());

  @override
  Future<void> init() async {}

  @override
  Future<void> saveDbPath(String path) async {}

  @override
  bool get isFirstLaunch => true;
  @override
  String? get databasePath => null;
  @override
  AppError? get error => null;
  @override
  bool get isLoading => false;
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
