import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/list_navigation.dart';
import 'package:taskly/models/todo_list.dart';

void main() {
  group('ListNavigation Widget Tests', () {
    final testLists = [
      TodoList(id: 1, name: 'Work'),
      TodoList(id: 2, name: 'Personal'),
      TodoList(id: 3, name: 'Shopping'),
    ];

    void mockOnSelectList(TodoList list) {}
    void mockOnAddList(String name, {String? icon, Color? color}) {}
    void mockOnDeleteList(int id) {}
    void mockOnTodayTap() {}
    void mockOnPlannedTap() {}
    void mockOnAllTap() {}
    void mockOnCompletedTap() {}

    testWidgets('should render correctly with initial data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListNavigation(
              lists: testLists,
              selectedList: testLists.first,
              onSelectList: mockOnSelectList,
              onAddList: mockOnAddList,
              onDeleteList: mockOnDeleteList,
              onTodayTap: mockOnTodayTap,
              onPlannedTap: mockOnPlannedTap,
              onAllTap: mockOnAllTap,
              onCompletedTap: mockOnCompletedTap,
            ),
          ),
        ),
      );

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('计划'), findsOneWidget);
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
      expect(find.text('我的列表'), findsOneWidget);
    });

    testWidgets('should call onTodayTap when Today tile is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;
      void onTodayTap() {
        wasCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListNavigation(
              lists: testLists,
              selectedList: null,
              onSelectList: mockOnSelectList,
              onAddList: mockOnAddList,
              onDeleteList: mockOnDeleteList,
              onTodayTap: onTodayTap,
              onPlannedTap: mockOnPlannedTap,
              onAllTap: mockOnAllTap,
              onCompletedTap: mockOnCompletedTap,
            ),
          ),
        ),
      );

      await tester.tap(find.text('今天'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('should call onPlannedTap when Planned tile is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;
      void onPlannedTap() {
        wasCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListNavigation(
              lists: testLists,
              selectedList: null,
              onSelectList: mockOnSelectList,
              onAddList: mockOnAddList,
              onDeleteList: mockOnDeleteList,
              onTodayTap: mockOnTodayTap,
              onPlannedTap: onPlannedTap,
              onAllTap: mockOnAllTap,
              onCompletedTap: mockOnCompletedTap,
            ),
          ),
        ),
      );

      await tester.tap(find.text('计划'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('should call onAllTap when All tile is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;
      void onAllTap() {
        wasCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListNavigation(
              lists: testLists,
              selectedList: null,
              onSelectList: mockOnSelectList,
              onAddList: mockOnAddList,
              onDeleteList: mockOnDeleteList,
              onTodayTap: mockOnTodayTap,
              onPlannedTap: mockOnPlannedTap,
              onAllTap: onAllTap,
              onCompletedTap: mockOnCompletedTap,
            ),
          ),
        ),
      );

      await tester.tap(find.text('全部'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('should call onCompletedTap when Completed tile is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;
      void onCompletedTap() {
        wasCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListNavigation(
              lists: testLists,
              selectedList: null,
              onSelectList: mockOnSelectList,
              onAddList: mockOnAddList,
              onDeleteList: mockOnDeleteList,
              onTodayTap: mockOnTodayTap,
              onPlannedTap: mockOnPlannedTap,
              onAllTap: mockOnAllTap,
              onCompletedTap: onCompletedTap,
            ),
          ),
        ),
      );

      await tester.tap(find.text('完成'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });
  });
}
