import 'package:taskly/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/task_dialogs.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/todo_list.dart';
import '../test_helpers.dart';

void main() {
  group('TaskInputDialog Widget Tests', () {
    final testLists = [
      TodoList(id: 1, name: 'Work'),
      TodoList(id: 2, name: 'Personal'),
    ];

    final selectedList = testLists.first;

    late Task? addedTask;

    testWidgets('should show database disconnected message when not connected',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => TaskInputDialog(
                        lists: testLists,
                        selectedList: selectedList,
                        onAdd: (task) {},
                        isDatabaseConnected: false,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('无法添加任务'), findsOneWidget);
        expect(find.text('数据库未连接，请先创建或打开数据库文件'), findsOneWidget);
      },
    );

    testWidgets('should display dialog with title when connected', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {},
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('添加新任务'), findsOneWidget);
    });

    testWidgets('should display all form fields', skip: true, (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {},
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('任务描述:'), findsOneWidget);
      expect(find.text('截止日期 (可选):'), findsOneWidget);
      expect(find.text('任务列表:'), findsOneWidget);
      expect(
        find.text('支持智能日期格式: +1d (明天), @10am (上午10点), +1w (下周)'),
        findsOneWidget,
      );
    });

    testWidgets('should pre-select the selected list', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {},
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should show validation error when text is empty', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {},
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.text('请输入任务描述'), findsOneWidget);
    });

    testWidgets('should call onAdd with valid task', skip: true, (
      WidgetTester tester,
    ) async {
      addedTask = null;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {
                        addedTask = task;
                      },
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Task');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(addedTask, isNotNull);
      expect(addedTask?.text, 'Test Task');
      expect(addedTask?.listId, 1);
    });

    testWidgets('should show error when onAdd fails', skip: true, (
      WidgetTester tester,
    ) async {
      addedTask = null;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskInputDialog(
                      lists: testLists,
                      selectedList: selectedList,
                      onAdd: (task) {
                        throw Exception('Add failed');
                      },
                      isDatabaseConnected: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Task');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.textContaining('添加任务失败'), findsOneWidget);
    });
  });

  group('EditTaskDialog Widget Tests', () {
    final testLists = [
      TodoList(id: 1, name: 'Work'),
      TodoList(id: 2, name: 'Personal'),
    ];

    final testTask = Task(
      id: 1,
      listId: 1,
      text: 'Original Task',
      dueDate: '2024-12-31',
      completed: false,
      createdAt: '2024-01-01T00:00:00Z',
    );

    late Task? updatedTask;

    testWidgets('should display dialog with title', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('编辑任务'), findsOneWidget);
    });

    testWidgets('should pre-fill task data', skip: true, (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, 'Original Task');

      final dateField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(dateField.controller?.text, '2024-12-31');
    });

    testWidgets('should pre-select the correct list', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should call onUpdate with updated task', skip: true, (
      WidgetTester tester,
    ) async {
      updatedTask = null;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {
                        updatedTask = task;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Task');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(updatedTask, isNotNull);
      expect(updatedTask?.text, 'Updated Task');
      expect(updatedTask?.id, 1);
      expect(updatedTask?.dueDate, '2024-12-31');
    });

    testWidgets('should allow changing list', skip: true, (WidgetTester tester) async {
      updatedTask = null;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {
                        updatedTask = task;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Task');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(updatedTask?.listId, 2);
    });

    testWidgets('should show error when onUpdate fails', skip: true, (
      WidgetTester tester,
    ) async {
      updatedTask = null;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {
                        throw Exception('Update failed');
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Task');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.textContaining('更新任务失败'), findsOneWidget);
    });

    testWidgets('should show validation error when text is empty', skip: true, (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTaskDialog(
                      task: testTask,
                      lists: testLists,
                      onUpdate: (task) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.text('请输入任务描述'), findsOneWidget);
    });
  });
}
