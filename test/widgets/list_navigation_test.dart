import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/widgets/list_navigation.dart';
import 'package:taskly/models/todo_list.dart';
import 'package:taskly/l10n/app_localizations.dart';

void main() {
  group('ListNavigation Widget Tests', () {
    final testLists = [
      TodoList(id: 1, name: 'Work'),
      TodoList(id: 2, name: 'Personal'),
    ];

    Widget createWidget(ListNavigation nav) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: nav),
      );
    }

    testWidgets('should render headers and items correctly', skip: true, (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(ListNavigation(
        lists: testLists,
        selectedList: null,
        onSelectList: (_) {},
        onAddList: (_, {icon, color}) {},
        onDeleteList: (_) {},
        onTodayTap: () {},
        onPlannedTap: () {},
        onAllTap: () {},
        onCompletedTap: () {},
      )));

      expect(find.text('Smart Lists'), findsOneWidget);
      expect(find.text('My Lists'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should toggle Smart Lists section', skip: true, (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(ListNavigation(
        lists: testLists,
        selectedList: null,
        onSelectList: (_) {},
        onAddList: (_, {icon, color}) {},
        onDeleteList: (_) {},
        onTodayTap: () {},
        onPlannedTap: () {},
        onAllTap: () {},
        onCompletedTap: () {},
      )));

      // Initially expanded
      expect(find.text('Today'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('Smart Lists'));
      await tester.pumpAndSettle();

      // Should be hidden
      expect(find.text('Today'), findsNothing);

      // Tap header to expand
      await tester.tap(find.text('Smart Lists'));
      await tester.pumpAndSettle();

      // Should be visible
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should toggle My Lists section', skip: true, (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(ListNavigation(
        lists: testLists,
        selectedList: null,
        onSelectList: (_) {},
        onAddList: (_, {icon, color}) {},
        onDeleteList: (_) {},
        onTodayTap: () {},
        onPlannedTap: () {},
        onAllTap: () {},
        onCompletedTap: () {},
      )));

      // Initially expanded
      expect(find.text('Work'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('My Lists'));
      await tester.pumpAndSettle();

      // Should be hidden
      expect(find.text('Work'), findsNothing);

      // Tap header to expand
      await tester.tap(find.text('My Lists'));
      await tester.pumpAndSettle();

      // Should be visible
      expect(find.text('Work'), findsOneWidget);
    });
  });
}
