import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';

void main() {
  group('Task Model Tests', () {
    const testId = 1;
    const testListId = 1;
    const testText = 'Test Task';
    const testDueDate = '2024-12-31';
    const testCompleted = false;
    const testCreatedAt = '2024-01-01T00:00:00Z';
    const testListName = 'Test List';

    // Test data
    final testTask = Task(
      id: testId,
      listId: testListId,
      text: testText,
      dueDate: testDueDate,
      completed: testCompleted,
      createdAt: testCreatedAt,
      listName: testListName,
    );

    final testMap = {
      'id': testId,
      'list_id': testListId,
      'text': testText,
      'due_date': testDueDate,
      'completed': 0,
      'created_at': testCreatedAt,
      'list_name': testListName,
    };

    test('should create a Task instance with valid parameters', () {
      expect(testTask.id, testId);
      expect(testTask.listId, testListId);
      expect(testTask.text, testText);
      expect(testTask.dueDate, testDueDate);
      expect(testTask.completed, testCompleted);
      expect(testTask.createdAt, testCreatedAt);
      expect(testTask.listName, testListName);
    });

    test('should convert from map to Task', () {
      final task = Task.fromMap(testMap);
      expect(task, testTask);
    });

    test('should convert from Task to map', () {
      final map = testTask.toMap();
      expect(map, {
        'id': testId,
        'list_id': testListId,
        'text': testText,
        'due_date': testDueDate,
        'completed': 0,
        'created_at': testCreatedAt,
      });
    });

    test('should exclude id from map when id is 0', () {
      final taskWithZeroId = Task(
        id: 0,
        listId: testListId,
        text: testText,
        completed: testCompleted,
        createdAt: testCreatedAt,
      );
      final map = taskWithZeroId.toMap();
      expect(map.containsKey('id'), false);
    });

    test('should convert completed bool to int correctly', () {
      final completedTask = testTask.copyWith(completed: true);
      final completedMap = completedTask.toMap();
      expect(completedMap['completed'], 1);

      final incompleteTask = testTask.copyWith(completed: false);
      final incompleteMap = incompleteTask.toMap();
      expect(incompleteMap['completed'], 0);
    });

    test('should create a copy with updated values', () {
      const newText = 'Updated Task';
      const newCompleted = true;
      const newDueDate = '2025-01-01';

      final updatedTask = testTask.copyWith(
        text: newText,
        completed: newCompleted,
        dueDate: newDueDate,
      );

      expect(updatedTask.id, testId);
      expect(updatedTask.text, newText);
      expect(updatedTask.completed, newCompleted);
      expect(updatedTask.dueDate, newDueDate);
      expect(updatedTask.createdAt, testCreatedAt);
      expect(updatedTask.listName, testListName);
    });

    test('should have correct equality comparison', () {
      final sameTask = Task(
        id: testId,
        listId: testListId,
        text: testText,
        dueDate: testDueDate,
        completed: testCompleted,
        createdAt: testCreatedAt,
        listName: testListName,
      );

      final differentTask = testTask.copyWith(text: 'Different Task');

      expect(testTask == sameTask, true);
      expect(testTask == differentTask, false);
      expect(testTask == 'not a task', false);
    });

    test('should have correct hashCode', () {
      final sameTask = Task(
        id: testId,
        listId: testListId,
        text: testText,
        dueDate: testDueDate,
        completed: testCompleted,
        createdAt: testCreatedAt,
        listName: testListName,
      );

      final differentTask = testTask.copyWith(text: 'Different Task');

      expect(testTask.hashCode, sameTask.hashCode);
      expect(testTask.hashCode, isNot(differentTask.hashCode));
    });

    test('should have a useful toString method', () {
      final toStringResult = testTask.toString();
      expect(toStringResult, contains('Task'));
      expect(toStringResult, contains('id: $testId'));
      expect(toStringResult, contains('text: $testText'));
      expect(toStringResult, contains('completed: $testCompleted'));
    });

    test('should handle null dueDate and listName', () {
      final taskWithoutDueDate = Task(
        id: testId,
        listId: testListId,
        text: testText,
        completed: testCompleted,
        createdAt: testCreatedAt,
      );

      expect(taskWithoutDueDate.dueDate, null);
      expect(taskWithoutDueDate.listName, null);

      final map = taskWithoutDueDate.toMap();
      expect(map['due_date'], null);
    });

    test('should correctly convert from map with null values', () {
      final mapWithNulls = {
        'id': testId,
        'list_id': testListId,
        'text': testText,
        'due_date': null,
        'completed': 0,
        'created_at': testCreatedAt,
        'list_name': null,
      };

      final task = Task.fromMap(mapWithNulls);
      expect(task.dueDate, null);
      expect(task.listName, null);
    });
  });
}