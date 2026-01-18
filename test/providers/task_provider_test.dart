import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/interfaces/task_repository_interface.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/app_error.dart';

// Mock implementation for testing
class MockTaskRepository implements TaskRepositoryInterface {
  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByList(int listId) async => [];

  @override
  Future<List<Task>> getTodayTasks() async => [];

  @override
  Future<List<Task>> getPlannedTasks() async => [];

  @override
  Future<List<Task>> getIncompleteTasks() async => [];

  @override
  Future<List<Task>> getCompletedTasks() async => [];

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> addTask(Task task) async => 1;

  @override
  Future<int> updateTask(Task task) async => 1;

  @override
  Future<int> deleteTask(int id) async => 1;

  @override
  Future<int> toggleTaskCompleted(int id) async => 1;

  @override
  Future<List<Task>> searchTasks(String keyword) async => [];

  @override
  Future<List<Task>> getTasksByView(
    String viewType, {
    int? listId,
    String? keyword,
  }) async => [];

  @override
  Future<Map<String, List<Task>>> groupTasksByList(List<Task> tasks) async =>
      {};
}

void main() {
  group('TaskProvider Tests', () {
    test('should initialize with default values', () {
      // Create mock implementation
      final mockTaskRepository = MockTaskRepository();

      // Create TaskProvider with mocked dependency
      final taskProvider = TaskProvider.test(
        taskRepository: mockTaskRepository,
      );

      // Assert
      expect(taskProvider.tasks, isEmpty);
      expect(taskProvider.currentView, 'all');
      expect(taskProvider.searchKeyword, '');
      expect(taskProvider.isLoading, isFalse);
      expect(taskProvider.error, isNull);
      expect(taskProvider.hasError, isFalse);
    });

    test('should have correct getters', () {
      // Create mock implementation
      final mockTaskRepository = MockTaskRepository();

      // Create TaskProvider with mocked dependency
      final taskProvider = TaskProvider.test(
        taskRepository: mockTaskRepository,
      );

      // Assert
      expect(taskProvider.tasks, isList);
      expect(taskProvider.currentView, isA<String>());
      expect(taskProvider.searchKeyword, isA<String>());
      expect(taskProvider.isLoading, isA<bool>());
      expect(taskProvider.error, isNull);
      expect(taskProvider.hasError, isA<bool>());
    });
  });
}
