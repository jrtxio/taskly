import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';

void main() {
  group('Task Model Tests', () {
    const testId = 1;
    const testListId = 1;
    const testText = 'Test Task';
    const testDueDate = '2024-12-31';
    const testDueTime = '14:30';
    const testCompleted = false;
    const testCreatedAt = '2024-01-01T00:00:00Z';
    const testNotes = 'Test notes';

    // Test data
    final testTask = Task(
      id: testId,
      listId: testListId,
      text: testText,
      dueDate: testDueDate,
      dueTime: testDueTime,
      completed: testCompleted,
      createdAt: testCreatedAt,
      notes: testNotes,
    );

    final testMap = {
      'id': testId,
      'list_id': testListId,
      'text': testText,
      'due_date': testDueDate,
      'due_time': testDueTime,
      'completed': 0,
      'created_at': testCreatedAt,
      'notes': testNotes,
    };

    test('should create a Task instance with valid parameters', () {
      expect(testTask.id, testId);
      expect(testTask.listId, testListId);
      expect(testTask.text, testText);
      expect(testTask.dueDate, testDueDate);
      expect(testTask.dueTime, testDueTime);
      expect(testTask.completed, testCompleted);
      expect(testTask.createdAt, testCreatedAt);
      expect(testTask.notes, testNotes);
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
        'due_time': testDueTime,
        'completed': 0,
        'created_at': testCreatedAt,
        'notes': testNotes,
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
      expect(updatedTask.notes, testNotes);
    });

    test('should have correct equality comparison', () {
      final sameTask = Task(
        id: testId,
        listId: testListId,
        text: testText,
        dueDate: testDueDate,
        dueTime: testDueTime,
        completed: testCompleted,
        createdAt: testCreatedAt,
        notes: testNotes,
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
        dueTime: testDueTime,
        completed: testCompleted,
        createdAt: testCreatedAt,
        notes: testNotes,
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

    test('should handle null dueDate, dueTime, and notes', () {
      final taskWithoutDueDate = Task(
        id: testId,
        listId: testListId,
        text: testText,
        completed: testCompleted,
        createdAt: testCreatedAt,
      );

      expect(taskWithoutDueDate.dueDate, null);
      expect(taskWithoutDueDate.dueTime, null);
      expect(taskWithoutDueDate.notes, null);

      final map = taskWithoutDueDate.toMap();
      expect(map['due_date'], null);
      expect(map['due_time'], null);
      expect(map['notes'], null);
    });

    test('should correctly convert from map with null values', () {
      final mapWithNulls = {
        'id': testId,
        'list_id': testListId,
        'text': testText,
        'due_date': null,
        'due_time': null,
        'completed': 0,
        'created_at': testCreatedAt,
        'notes': null,
      };

      final task = Task.fromMap(mapWithNulls);
      expect(task.dueDate, null);
      expect(task.dueTime, null);
      expect(task.notes, null);
    });
  });
}
