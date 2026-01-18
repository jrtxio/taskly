import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/task_list_view.dart';
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
        listName: 'Work',
      ),
      Task(
        id: 2,
        listId: 2,
        text: 'Buy groceries',
        dueDate: null,
        completed: true,
        createdAt: '2024-01-02T00:00:00Z',
        listName: 'Personal',
      ),
      Task(
        id: 3,
        listId: 3,
        text: 'Call mom',
        dueDate: '2024-12-25',
        completed: false,
        createdAt: '2024-01-03T00:00:00Z',
        listName: null,
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
      expect(find.byType(ListTile), findsNothing);
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
        expect(find.byType(ListTile), findsNothing);
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
      expect(find.byType(ListTile), findsNWidgets(testTasks.length));

      // Verify each task text is displayed
      for (final task in testTasks) {
        expect(find.text(task.text), findsOneWidget);
      }
    });

    testWidgets('should show completed tasks with strikethrough', (
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

      // Find the completed task (Buy groceries)
      final completedTaskText = find.text('Buy groceries');
      expect(completedTaskText, findsOneWidget);

      // Verify the completed task has strikethrough decoration
      final textWidget = tester.widget<Text>(completedTaskText);
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
      expect(textWidget.style?.color, Colors.grey);

      // Find an incomplete task (Complete project)
      final incompleteTaskText = find.text('Complete project');
      expect(incompleteTaskText, findsOneWidget);

      // Verify the incomplete task doesn't have strikethrough decoration
      final incompleteTextWidget = tester.widget<Text>(incompleteTaskText);
      expect(incompleteTextWidget.style?.decoration, TextDecoration.none);
      expect(incompleteTextWidget.style?.color, Colors.black);
    });

    testWidgets('should display due date when available', (
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

      // Verify due dates are displayed for tasks that have them
      expect(find.text('2024-12-31'), findsOneWidget);
      expect(find.text('2024-12-25'), findsOneWidget);

      // Verify no due date is displayed for tasks that don't have one
      // The second task (Buy groceries) doesn't have a due date
    });

    testWidgets('should display list name when available', (
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

      // Verify list names are displayed for tasks that have them
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);

      // Verify no list name is displayed for tasks that don't have one
      // The third task (Call mom) doesn't have a list name
    });

    testWidgets('should call onToggleTask when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      int? toggledTaskId;
      void onToggleTask(int id) {
        toggledTaskId = id;
      }

      // Build the widget with test tasks
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

      // Find the checkbox for the first task
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(testTasks.length));

      // Tap the first checkbox
      await tester.tap(checkboxes.first);
      await tester.pump();

      // Verify onToggleTask was called with the correct task id
      expect(toggledTaskId, testTasks.first.id);
    });

    testWidgets('should call onToggleTask when task tile is tapped', (
      WidgetTester tester,
    ) async {
      int? toggledTaskId;
      void onToggleTask(int id) {
        toggledTaskId = id;
      }

      // Build the widget with test tasks
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

      // Find the first task tile
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(testTasks.length));

      // Tap the first task tile
      await tester.tap(listTiles.first);
      await tester.pump();

      // Verify onToggleTask was called with the correct task id
      expect(toggledTaskId, testTasks.first.id);
    });
  });
}
