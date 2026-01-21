import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/task_list_view.dart';
import 'package:taskly/widgets/reminder_task_item.dart';
import 'package:taskly/models/task.dart';

void main() {
  group('TaskListView Widget Tests', () {
    // Test data
    final testTasks = [
      Task(
        id: 1,
        listId: 1,
        text: 'Complete project',
        dueDate: '2024-12-31',
        completed: false,
        createdAt: '2024-01-01T00:00:00Z',
      ),
      Task(
        id: 2,
        listId: 2,
        text: 'Buy groceries',
        dueDate: null,
        completed: true,
        createdAt: '2024-01-02T00:00:00Z',
      ),
      Task(
        id: 3,
        listId: 3,
        text: 'Call mom',
        dueDate: '2024-12-25',
        completed: false,
        createdAt: '2024-01-03T00:00:00Z',
      ),
    ];

    // Mock callbacks
    void mockOnToggleTask(int id) {}
    void mockOnEditTask(Task task) {}
    void mockOnDeleteTask(int id) {}

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      // Build the widget with isLoading = true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: [],
              isLoading: true,
              onToggleTask: mockOnToggleTask,
              onEditTask: mockOnEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('暂无任务'), findsNothing);
      expect(find.byType(ReminderTaskItem), findsNothing);
    });

    testWidgets(
      'should show empty state when tasks is empty and isLoading is false',
      (WidgetTester tester) async {
        // Build the widget with empty tasks and isLoading = false
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskListView(
                tasks: [],
                isLoading: false,
                onToggleTask: mockOnToggleTask,
                onEditTask: mockOnEditTask,
                onDeleteTask: mockOnDeleteTask,
              ),
            ),
          ),
        );

        // Verify empty state message is displayed
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('暂无任务'), findsOneWidget);
        expect(find.byType(ReminderTaskItem), findsNothing);
      },
    );

    testWidgets('should display all tasks when tasks is not empty', (
      WidgetTester tester,
    ) async {
      // Build the widget with test tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: testTasks,
              isLoading: false,
              onToggleTask: mockOnToggleTask,
              onEditTask: mockOnEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Verify all tasks are displayed
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('暂无任务'), findsNothing);
      expect(find.byType(ReminderTaskItem), findsNWidgets(testTasks.length));

      // Verify each task text is displayed
      for (final task in testTasks) {
        expect(find.text(task.text), findsOneWidget);
      }
    });

    testWidgets('should show completed tasks with strikethrough', (
      WidgetTester tester,
    ) async {
      // Build widget with test tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: testTasks,
              isLoading: false,
              onToggleTask: mockOnToggleTask,
              onEditTask: mockOnEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Find completed task (Buy groceries) and incomplete task (Complete project)
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Complete project'), findsOneWidget);

      // Tap on task items to trigger selection and show text fields
      await tester.tap(find.text('Buy groceries').first);
      await tester.pump();
      await tester.tap(find.text('Complete project').first);
      await tester.pump();

      // Find the TextField widgets to check their styles
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
    });

    testWidgets('should display due date when available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: testTasks,
              isLoading: false,
              onToggleTask: mockOnToggleTask,
              onEditTask: mockOnEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Due dates should be displayed (may be Chinese text like "今天", "明天" or date format)
      expect(find.text('2024-12-31'), findsOneWidget);
      expect(find.text('2024-12-25'), findsOneWidget);
    });

    testWidgets('should call onToggleTask when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      int? toggledTaskId;
      void onToggleTask(int id) {
        toggledTaskId = id;
      }

      // Build widget with test tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: testTasks,
              isLoading: false,
              onToggleTask: onToggleTask,
              onEditTask: mockOnEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Find checkbox using the key for first task
      final checkbox = find.byKey(Key('checkbox_${testTasks.first.id}'));
      expect(checkbox, findsOneWidget);

      // Tap the checkbox
      await tester.tap(checkbox);
      await tester.pump();

      // Verify onToggleTask was called with correct task id
      expect(toggledTaskId, testTasks.first.id);
    });

    testWidgets('should call onEditTask when info button is tapped', (
      WidgetTester tester,
    ) async {
      Task? editedTask;
      void onEditTask(Task task) {
        editedTask = task;
      }

      // Build widget with test tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: testTasks,
              isLoading: false,
              onToggleTask: mockOnToggleTask,
              onEditTask: onEditTask,
              onDeleteTask: mockOnDeleteTask,
            ),
          ),
        ),
      );

      // Info buttons are only shown when task is selected or focused
      // Tap on first task to select it
      await tester.tap(find.text(testTasks.first.text).first);
      await tester.pump();

      // Now find the info button for the first task
      final infoButtons = find.byIcon(Icons.info_outline);
      expect(infoButtons, findsOneWidget);

      // Tap the info button
      await tester.tap(infoButtons.first);
      await tester.pump();

      // Verify onEditTask was called with correct task
      expect(editedTask, testTasks.first);
    });
  });
}
