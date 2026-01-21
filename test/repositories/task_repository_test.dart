import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/repositories/task_repository.dart';
import 'package:taskly/interfaces/database_service_interface.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/models/todo_list.dart';

class MockDatabaseService implements DatabaseServiceInterface {
  final List<Task> _tasks = [];
  int _nextId = 1;

  @override
  Future<void> init() async {}

  @override
  void setDatabasePath(String path) {}

  @override
  Future<List<TodoList>> getAllLists() async => [];

  @override
  Future<TodoList?> getListById(int id) async => null;

  @override
  Future<int> addList(String name, {String? icon, int? color}) async => 0;

  @override
  Future<int> updateList(
    int id,
    String name, {
    String? icon,
    int? color,
    bool clearIcon = false,
    bool clearColor = false,
  }) async =>
      0;

  @override
  Future<int> deleteList(int id) async => 0;

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<List<Task>> getTasksByList(
    int listId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return _tasks.where((task) => task.listId == listId && !task.completed).toList();
  }

  @override
  Future<List<Task>> getCompletedTasksByList(int listId, {int limit = 50, int offset = 0}) async {
    return _tasks.where((task) => task.listId == listId && task.completed).toList();
  }

  @override
  Future<List<Task>> getTasksByListIncludingCompleted(int listId, {int limit = 50, int offset = 0}) async {
    final filtered = _tasks.where((task) => task.listId == listId).toList();
    final incomplete = filtered.where((task) => !task.completed).toList();
    final completed = filtered.where((task) => task.completed).toList();
    return [...incomplete, ...completed];
  }

  @override
  Future<List<Task>> getAllTasksIncludingCompleted({int limit = 50, int offset = 0}) async {
    final incomplete = _tasks.where((task) => !task.completed).toList();
    final completed = _tasks.where((task) => task.completed).toList();
    return [...incomplete, ...completed];
  }

  @override
  Future<List<Task>> getTodayTasks({int limit = 50, int offset = 0}) async {
    final now = DateTime.now();
    final todayString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.startsWith(todayString) &&
              !task.completed,
        )
        .toList();
  }

  @override
  Future<List<Task>> getPlannedTasks({int limit = 50, int offset = 0}) async {
    return _tasks
        .where((task) => task.dueDate != null && !task.completed)
        .toList();
  }

  @override
  Future<List<Task>> getPlannedTasksIncludingCompleted({int limit = 50, int offset = 0}) async {
    final withDueDate = _tasks.where((task) => task.dueDate != null).toList();
    final incomplete = withDueDate.where((task) => !task.completed).toList();
    final completed = withDueDate.where((task) => task.completed).toList();
    return [...incomplete, ...completed];
  }

  @override
  Future<List<Task>> getIncompleteTasks({
    int limit = 50,
    int offset = 0,
  }) async {
    return _tasks.where((task) => !task.completed).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks({int limit = 50, int offset = 0}) async {
    return _tasks.where((task) => task.completed).toList();
  }

  @override
  Future<int> getTaskCountByList(int listId) async {
    return _tasks.where((task) => task.listId == listId).length;
  }

  @override
  Future<int> getIncompleteTaskCount() async {
    return _tasks.where((task) => !task.completed).length;
  }

  @override
  Future<int> getCompletedTaskCount() async {
    return _tasks.where((task) => task.completed).length;
  }

  @override
  Future<int> getTodayTaskCount() async {
    final now = DateTime.now();
    final todayString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.startsWith(todayString) &&
              !task.completed,
        )
        .length;
  }

  @override
  Future<int> getPlannedTaskCount() async {
    return _tasks.where((task) => task.dueDate != null && !task.completed).length;
  }

  @override
  Future<int> addTask(Task task) async {
    final newTask = task.copyWith(id: _nextId++);
    _tasks.add(newTask);
    return newTask.id;
  }

  @override
  Future<int> updateTask(Task task) async {
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == task.id) {
        _tasks[i] = task;
        return 1;
      }
    }
    return 0;
  }

  @override
  Future<int> toggleTaskCompleted(int id) async {
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == id) {
        _tasks[i] = _tasks[i].copyWith(completed: !_tasks[i].completed);
        return 1;
      }
    }
    return 0;
  }

  @override
  Future<int> deleteTask(int id) async {
    final initialLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    return initialLength - _tasks.length;
  }

  @override
  Future<List<Task>> searchTasks(String keyword) async {
    final lowerKeyword = keyword.toLowerCase();
    return _tasks
        .where((task) => task.text.toLowerCase().contains(lowerKeyword))
        .toList();
  }

  @override
  Future<void> close() async {}

  @override
  bool isConnected() => false;

  @override
  void resetConnection() {}
}

void main() {
  group('TaskRepository Tests', () {
    late TaskRepository taskRepository;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      taskRepository = TaskRepository(mockDatabaseService);
    });

    group('getAllTasks', () {
      test('should return empty list when no tasks exist', () async {
        final tasks = await taskRepository.getAllTasks();
        expect(tasks, isEmpty);
      });

      test('should return all tasks when tasks exist', () async {
        final task1 = Task(
          id: 0,
          listId: 1,
          text: 'Task 1',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task2 = Task(
          id: 0,
          listId: 2,
          text: 'Task 2',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task1);
        await taskRepository.addTask(task2);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks.length, 2);
        expect(tasks[0].text, 'Task 1');
        expect(tasks[1].text, 'Task 2');
      });
    });

    group('getTasksByList', () {
      test('should return empty list when list has no tasks', () async {
        final tasks = await taskRepository.getTasksByList(1);
        expect(tasks, isEmpty);
      });

      test('should return tasks for specific list', () async {
        final task1 = Task(
          id: 0,
          listId: 1,
          text: 'Task 1',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task2 = Task(
          id: 0,
          listId: 2,
          text: 'Task 2',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task3 = Task(
          id: 0,
          listId: 1,
          text: 'Task 3',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task1);
        await taskRepository.addTask(task2);
        await taskRepository.addTask(task3);

        final tasks = await taskRepository.getTasksByList(1);
        expect(tasks.length, 2);
        expect(tasks[0].text, 'Task 1');
        expect(tasks[1].text, 'Task 3');
      });
    });

    group('getTodayTasks', () {
      test('should return empty list when no tasks exist', () async {
        final tasks = await taskRepository.getTodayTasks();
        expect(tasks, isEmpty);
      });

      test('should return only today\'s incomplete tasks', () async {
        final now = DateTime.now();
        final todayString =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        final todayTask = Task(
          id: 0,
          listId: 1,
          text: 'Today Task',
          dueDate: '$todayString 10:00:00',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final completedTodayTask = Task(
          id: 0,
          listId: 1,
          text: 'Completed Today Task',
          dueDate: '$todayString 10:00:00',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );
        final otherTask = Task(
          id: 0,
          listId: 1,
          text: 'Other Task',
          dueDate: '2024-12-31 10:00:00',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(todayTask);
        await taskRepository.addTask(completedTodayTask);
        await taskRepository.addTask(otherTask);

        final tasks = await taskRepository.getTodayTasks();
        expect(tasks.length, 1);
        expect(tasks[0].text, 'Today Task');
      });
    });

    group('getPlannedTasks', () {
      test('should return empty list when no planned tasks exist', () async {
        final tasks = await taskRepository.getPlannedTasks();
        expect(tasks, isEmpty);
      });

      test('should return only incomplete tasks with due dates', () async {
        final plannedTask1 = Task(
          id: 0,
          listId: 1,
          text: 'Planned Task 1',
          dueDate: '2024-12-31 10:00:00',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final plannedTask2 = Task(
          id: 0,
          listId: 1,
          text: 'Planned Task 2',
          dueDate: '2025-01-01 10:00:00',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final completedPlannedTask = Task(
          id: 0,
          listId: 1,
          text: 'Completed Planned Task',
          dueDate: '2024-12-31 10:00:00',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );
        final unplannedTask = Task(
          id: 0,
          listId: 1,
          text: 'Unplanned Task',
          dueDate: null,
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(plannedTask1);
        await taskRepository.addTask(plannedTask2);
        await taskRepository.addTask(completedPlannedTask);
        await taskRepository.addTask(unplannedTask);

        final tasks = await taskRepository.getPlannedTasks();
        expect(tasks.length, 2);
        expect(tasks[0].text, 'Planned Task 1');
        expect(tasks[1].text, 'Planned Task 2');
      });
    });

    group('getIncompleteTasks', () {
      test('should return empty list when all tasks are completed', () async {
        final completedTask = Task(
          id: 0,
          listId: 1,
          text: 'Completed Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(completedTask);

        final tasks = await taskRepository.getIncompleteTasks();
        expect(tasks, isEmpty);
      });

      test('should return only incomplete tasks', () async {
        final incompleteTask1 = Task(
          id: 0,
          listId: 1,
          text: 'Incomplete Task 1',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final incompleteTask2 = Task(
          id: 0,
          listId: 1,
          text: 'Incomplete Task 2',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final completedTask = Task(
          id: 0,
          listId: 1,
          text: 'Completed Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(incompleteTask1);
        await taskRepository.addTask(incompleteTask2);
        await taskRepository.addTask(completedTask);

        final tasks = await taskRepository.getIncompleteTasks();
        expect(tasks.length, 2);
        expect(tasks[0].text, 'Incomplete Task 1');
        expect(tasks[1].text, 'Incomplete Task 2');
      });
    });

    group('getCompletedTasks', () {
      test('should return empty list when no tasks are completed', () async {
        final incompleteTask = Task(
          id: 0,
          listId: 1,
          text: 'Incomplete Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(incompleteTask);

        final tasks = await taskRepository.getCompletedTasks();
        expect(tasks, isEmpty);
      });

      test('should return only completed tasks', () async {
        final completedTask1 = Task(
          id: 0,
          listId: 1,
          text: 'Completed Task 1',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );
        final completedTask2 = Task(
          id: 0,
          listId: 1,
          text: 'Completed Task 2',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );
        final incompleteTask = Task(
          id: 0,
          listId: 1,
          text: 'Incomplete Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(completedTask1);
        await taskRepository.addTask(completedTask2);
        await taskRepository.addTask(incompleteTask);

        final tasks = await taskRepository.getCompletedTasks();
        expect(tasks.length, 2);
        expect(tasks[0].text, 'Completed Task 1');
        expect(tasks[1].text, 'Completed Task 2');
      });
    });

    group('addTask', () {
      test('should add task successfully with valid text', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'New Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        expect(taskId, greaterThan(0));

        final tasks = await taskRepository.getAllTasks();
        expect(tasks.length, 1);
        expect(tasks[0].id, taskId);
        expect(tasks[0].text, 'New Task');
      });

      test('should not trim whitespace from task text', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: '  New Task  ',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks[0].text, '  New Task  ');
      });

      test('should throw ArgumentError when task text is empty', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: '',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        expect(
          () => taskRepository.addTask(task),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'should throw ArgumentError when task text contains only whitespace',
        () async {
          final task = Task(
            id: 0,
            listId: 1,
            text: '   ',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          expect(
            () => taskRepository.addTask(task),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('updateTask', () {
      test('should update task successfully with valid text', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Original Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        final updatedTask = Task(
          id: taskId,
          listId: 1,
          text: 'Updated Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        final result = await taskRepository.updateTask(updatedTask);
        expect(result, 1);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks[0].text, 'Updated Task');
        expect(tasks[0].completed, true);
      });

      test('should not trim whitespace from updated task text', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Original Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        final updatedTask = Task(
          id: taskId,
          listId: 1,
          text: '  Updated Task  ',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.updateTask(updatedTask);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks[0].text, '  Updated Task  ');
      });

      test(
        'should throw ArgumentError when updated task text is empty',
        () async {
          final task = Task(
            id: 0,
            listId: 1,
            text: 'Original Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          final taskId = await taskRepository.addTask(task);
          final updatedTask = Task(
            id: taskId,
            listId: 1,
            text: '',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          expect(
            () => taskRepository.updateTask(updatedTask),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError when updated task text contains only whitespace',
        () async {
          final task = Task(
            id: 0,
            listId: 1,
            text: 'Original Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          final taskId = await taskRepository.addTask(task);
          final updatedTask = Task(
            id: taskId,
            listId: 1,
            text: '   ',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          expect(
            () => taskRepository.updateTask(updatedTask),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('should return 0 when updating non-existent task', () async {
        final task = Task(
          id: 999,
          listId: 1,
          text: 'Updated Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final result = await taskRepository.updateTask(task);
        expect(result, 0);
      });
    });

    group('toggleTaskCompleted', () {
      test('should toggle task from incomplete to completed', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        await taskRepository.toggleTaskCompleted(taskId);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks[0].completed, true);
      });

      test('should toggle task from completed to incomplete', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Task',
          completed: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        await taskRepository.toggleTaskCompleted(taskId);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks[0].completed, false);
      });

      test('should return 0 when toggling non-existent task', () async {
        final result = await taskRepository.toggleTaskCompleted(999);
        expect(result, 0);
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final taskId = await taskRepository.addTask(task);
        final result = await taskRepository.deleteTask(taskId);
        expect(result, 1);

        final tasks = await taskRepository.getAllTasks();
        expect(tasks.length, 0);
      });

      test('should return 0 when deleting non-existent task', () async {
        final result = await taskRepository.deleteTask(999);
        expect(result, 0);
      });
    });

    group('searchTasks', () {
      test('should return empty list when keyword is empty', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task);

        final tasks = await taskRepository.searchTasks('');
        expect(tasks, isEmpty);
      });

      test(
        'should return empty list when keyword contains only whitespace',
        () async {
          final task = Task(
            id: 0,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          await taskRepository.addTask(task);

          final tasks = await taskRepository.searchTasks('   ');
          expect(tasks, isEmpty);
        },
      );

      test('should return tasks matching keyword (case insensitive)', () async {
        final task1 = Task(
          id: 0,
          listId: 1,
          text: 'Buy groceries',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task2 = Task(
          id: 0,
          listId: 1,
          text: 'Complete project',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task3 = Task(
          id: 0,
          listId: 1,
          text: 'Call mom',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task1);
        await taskRepository.addTask(task2);
        await taskRepository.addTask(task3);

        final tasks = await taskRepository.searchTasks('buy');
        expect(tasks.length, 1);
        expect(tasks[0].text, 'Buy groceries');

        final tasksCaseInsensitive = await taskRepository.searchTasks(
          'GROCERIES',
        );
        expect(tasksCaseInsensitive.length, 1);
      });

      test('should return all tasks when keyword matches multiple', () async {
        final task1 = Task(
          id: 0,
          listId: 1,
          text: 'Buy groceries',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task2 = Task(
          id: 0,
          listId: 1,
          text: 'Buy milk',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task3 = Task(
          id: 0,
          listId: 1,
          text: 'Complete project',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task1);
        await taskRepository.addTask(task2);
        await taskRepository.addTask(task3);

        final tasks = await taskRepository.searchTasks('buy');
        expect(tasks.length, 2);
      });
    });

    group('getTasksByView', () {
      test('should return today tasks for viewType "today"', () async {
        final result = await taskRepository.getTasksByView('today');
        expect(result, isA<List<Task>>());
      });

      test('should return planned tasks for viewType "planned"', () async {
        final result = await taskRepository.getTasksByView('planned');
        expect(result, isA<List<Task>>());
      });

      test('should return incomplete tasks for viewType "all"', () async {
        final result = await taskRepository.getTasksByView('all');
        expect(result, isA<List<Task>>());
      });

      test('should return completed tasks for viewType "completed"', () async {
        final result = await taskRepository.getTasksByView('completed');
        expect(result, isA<List<Task>>());
      });

      test(
        'should return tasks by list for viewType "list" with listId',
        () async {
          final task = Task(
            id: 0,
            listId: 1,
            text: 'Task',
            completed: false,
            createdAt: DateTime.now().toIso8601String(),
          );

          await taskRepository.addTask(task);

          final result = await taskRepository.getTasksByView('list', listId: 1);
          expect(result.length, 1);
        },
      );

      test(
        'should return empty list for viewType "list" without listId',
        () async {
          final result = await taskRepository.getTasksByView('list');
          expect(result, isEmpty);
        },
      );

      test('should search tasks for viewType "search" with keyword', () async {
        final task = Task(
          id: 0,
          listId: 1,
          text: 'Test Task',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await taskRepository.addTask(task);

        final result = await taskRepository.getTasksByView(
          'search',
          keyword: 'test',
        );
        expect(result.length, 1);
      });

      test(
        'should return empty list for viewType "search" without keyword',
        () async {
          final result = await taskRepository.getTasksByView('search');
          expect(result, isEmpty);
        },
      );

      test('should return incomplete tasks for unknown viewType', () async {
        final result = await taskRepository.getTasksByView('unknown');
        expect(result, isA<List<Task>>());
      });
    });

    group('groupTasksByList', () {
      test('should return empty map when no tasks exist', () async {
        final result = await taskRepository.groupTasksByList([]);
        expect(result, isEmpty);
      });

      test('should group tasks by list name', () async {
        final task1 = Task(
          id: 0,
          listId: 1,
          text: 'Task 1',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task2 = Task(
          id: 0,
          listId: 1,
          text: 'Task 2',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task3 = Task(
          id: 0,
          listId: 2,
          text: 'Task 3',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        final task4 = Task(
          id: 0,
          listId: 3,
          text: 'Task 4',
          completed: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        final tasks = [task1, task2, task3, task4];
        final result = await taskRepository.groupTasksByList(tasks);

        expect(result.length, 3);
        expect(result['list_1']?.length, 2);
        expect(result['list_2']?.length, 1);
        expect(result['list_3']?.length, 1);
      });
    });
  });
}
