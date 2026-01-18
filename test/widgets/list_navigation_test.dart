import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/list_navigation.dart';
import 'package:taskly/models/todo_list.dart';

void main() {
  group('ListNavigation Widget Tests', () {
    // Test data
    final testLists = [
      TodoList(id: 1, name: 'Work'),
      TodoList(id: 2, name: 'Personal'),
      TodoList(id: 3, name: 'Shopping'),
    ];

    // Mock callbacks
    void mockOnSelectList(TodoList list) {} 
    void mockOnAddList(String name) {} 
    void mockOnTodayTap() {} 
    void mockOnPlannedTap() {} 
    void mockOnAllTap() {} 
    void mockOnCompletedTap() {} 

    testWidgets('should render correctly with initial data', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: testLists.first,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Verify the widget renders correctly
      expect(find.text('今天'), findsOneWidget);
      expect(find.text('计划'), findsOneWidget);
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('已完成'), findsOneWidget);
      expect(find.text('任务列表'), findsOneWidget);

      // Verify the lists are displayed
      for (final list in testLists) {
        expect(find.text(list.name), findsOneWidget);
      }

      // Verify the selected list is highlighted
      final selectedListTile = find.byWidgetPredicate((widget) {
        return widget is ListTile && widget.selected == true;
      });
      expect(selectedListTile, findsOneWidget);
    });

    testWidgets('should call onTodayTap when Today tile is tapped', (WidgetTester tester) async {
      bool wasCalled = false;
      void onTodayTap() {
        wasCalled = true;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: onTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap Today tile
      await tester.tap(find.text('今天'));
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('should call onPlannedTap when Planned tile is tapped', (WidgetTester tester) async {
      bool wasCalled = false;
      void onPlannedTap() {
        wasCalled = true;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: onPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap Planned tile
      await tester.tap(find.text('计划'));
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('should call onAllTap when All tile is tapped', (WidgetTester tester) async {
      bool wasCalled = false;
      void onAllTap() {
        wasCalled = true;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: onAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap All tile
      await tester.tap(find.text('全部'));
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('should call onCompletedTap when Completed tile is tapped', (WidgetTester tester) async {
      bool wasCalled = false;
      void onCompletedTap() {
        wasCalled = true;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: onCompletedTap,
          ),
        ),
      ));

      // Tap Completed tile
      await tester.tap(find.text('已完成'));
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('should display custom lists', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Verify custom lists are displayed
      for (final list in testLists) {
        expect(find.text(list.name), findsOneWidget);
      }
    });

    testWidgets('should call onSelectList when a custom list is tapped', (WidgetTester tester) async {
      TodoList? selectedList;
      void onSelectList(TodoList list) {
        selectedList = list;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: onSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap the second list (Personal)
      await tester.tap(find.text('Personal'));
      await tester.pump();

      // Verify callback was called with the correct list
      expect(selectedList, testLists[1]);
    });

    testWidgets('should show add list input when add button is tapped', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Verify add list input is not initially shown
      expect(find.byType(TextField), findsNothing);

      // Tap add button
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();

      // Verify add list input is now shown
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should hide add list input when close button is tapped', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: mockOnAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap add button to show input
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();

      // Verify add list input is shown
      expect(find.byType(TextField), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Verify add list input is hidden
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should call onAddList when a new list is submitted', (WidgetTester tester) async {
      String? addedListName;
      void onAddList(String name) {
        addedListName = name;
      }

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListNavigation(
            lists: testLists,
            selectedList: null,
            onSelectList: mockOnSelectList,
            onAddList: onAddList,
            onTodayTap: mockOnTodayTap,
            onPlannedTap: mockOnPlannedTap,
            onAllTap: mockOnAllTap,
            onCompletedTap: mockOnCompletedTap,
          ),
        ),
      ));

      // Tap add button to show input
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();

      // Enter new list name
      const newListName = 'New List';
      await tester.enterText(find.byType(TextField), newListName);
      await tester.pump();

      // Submit the new list
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verify onAddList was called with the correct name
      expect(addedListName, newListName);
      // Verify add list input is hidden
      expect(find.byType(TextField), findsNothing);
    });
  });
}