import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/reminder_task_item.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/l10n/app_localizations.dart';

void main() {
  group('ReminderTaskItem Tests', () {
    final task = Task(
      id: 1,
      listId: 1,
      text: 'Test Task',
      completed: false,
      createdAt: '2023-01-01',
    );

    Widget createWidget(ReminderTaskItem item) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: item,
        ),
      );
    }

    testWidgets('Tapping title should switch to edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(
        ReminderTaskItem(
          task: task,
          isSelected: false,
          onToggle: () {},
          onUpdate: (t) {},
          onDelete: () {},
          onShowDetail: () {},
          onSelect: () {},
          onMoveToList: (id) {},
        ),
      ));

      // Initial state: Text widget, no TextField
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Tap to edit
      await tester.tap(find.text('Test Task'));
      await tester.pump();
      // Pump for postFrameCallback if needed, frame is scheduled
      await tester.pump();

      // Should show TextField
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget); // TextField also displays text
    });
  });
}
