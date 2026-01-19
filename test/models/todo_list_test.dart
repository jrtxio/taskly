import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/todo_list.dart';

void main() {
  group('TodoList Model Tests', () {
    const testId = 1;
    const testName = 'Test List';

    // Test data
    final testTodoList = TodoList(
      id: testId,
      name: testName,
    );

    final testMap = {
      'id': testId,
      'name': testName,
      'icon': null,
      'color': null,
    };

    test('should create a TodoList instance with valid parameters', () {
      expect(testTodoList.id, testId);
      expect(testTodoList.name, testName);
      expect(testTodoList.icon, isNull);
      expect(testTodoList.color, isNull);
    });

    test('should convert from map to TodoList', () {
      final todoList = TodoList.fromMap(testMap);
      expect(todoList.id, testTodoList.id);
      expect(todoList.name, testTodoList.name);
      expect(todoList.icon, testTodoList.icon);
      expect(todoList.color, testTodoList.color);
    });

    test('should convert from TodoList to map', () {
      final map = testTodoList.toMap();
      expect(map, testMap);
    });

    test('should create a copy with updated values', () {
      const newName = 'Updated List';
      const newId = 2;

      final updatedList = testTodoList.copyWith(
        id: newId,
        name: newName,
      );

      expect(updatedList.id, newId);
      expect(updatedList.name, newName);
    });

    test('should create a copy with only name updated', () {
      const newName = 'Updated List';

      final updatedList = testTodoList.copyWith(name: newName);

      expect(updatedList.id, testId);
      expect(updatedList.name, newName);
    });

    test('should create a copy with only id updated', () {
      const newId = 2;

      final updatedList = testTodoList.copyWith(id: newId);

      expect(updatedList.id, newId);
      expect(updatedList.name, testName);
    });

    test('should have correct equality comparison', () {
      final sameList = TodoList(
        id: testId,
        name: testName,
      );

      final differentList = testTodoList.copyWith(name: 'Different List');
      final differentIdList = testTodoList.copyWith(id: 2);

      expect(testTodoList == sameList, true);
      expect(testTodoList == differentList, false);
      expect(testTodoList == differentIdList, false);
      expect(testTodoList == 'not a list', false);
    });

    test('should have correct hashCode', () {
      final sameList = TodoList(
        id: testId,
        name: testName,
      );

      final differentList = testTodoList.copyWith(name: 'Different List');

      expect(testTodoList.hashCode, sameList.hashCode);
      expect(testTodoList.hashCode, isNot(differentList.hashCode));
    });

    test('should have a useful toString method', () {
      final toStringResult = testTodoList.toString();
      expect(toStringResult, contains('TodoList'));
      expect(toStringResult, contains('id: $testId'));
      expect(toStringResult, contains('name: $testName'));
    });
  });
}