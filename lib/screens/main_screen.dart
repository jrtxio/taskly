import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_window/desktop_window.dart';
import '../providers/list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/list_navigation.dart';
import '../widgets/task_list_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Resize window for main screen
    _resizeWindow();
    // Load initial data after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Resize window to appropriate size for main screen
  Future<void> _resizeWindow() async {
    await DesktopWindow.setWindowSize(const Size(1024, 768));
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Load lists
    await listProvider.loadLists();

    // Load tasks based on selected list or default view
    if (listProvider.selectedList != null) {
      await taskProvider.loadTasksByList(listProvider.selectedList!.id);
    } else {
      await taskProvider.loadAllTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ListProvider, TaskProvider>(
        builder: (context, listProvider, taskProvider, child) {
          return Row(
            children: [
              // Left sidebar: List navigation
              SizedBox(
                width: 300,
                child: ListNavigation(
                  lists: listProvider.lists,
                  selectedList: listProvider.selectedList,
                  onSelectList: (list) {
                    listProvider.selectList(list);
                    taskProvider.loadTasksByList(list.id);
                  },
                  onAddList: (name) {
                    listProvider.addList(name);
                  },
                  onTodayTap: () {
                    taskProvider.loadTodayTasks();
                  },
                  onPlannedTap: () {
                    taskProvider.loadPlannedTasks();
                  },
                  onAllTap: () {
                    taskProvider.loadAllTasks();
                  },
                  onCompletedTap: () {
                    taskProvider.loadCompletedTasks();
                  },
                ),
              ),

              // Vertical divider
              const VerticalDivider(width: 1),

              // Right content: Task list view
              Expanded(
                child: TaskListView(
                  tasks: taskProvider.tasks,
                  isLoading: taskProvider.isLoading,
                  onToggleTask: (id) {
                    taskProvider.toggleTaskCompleted(id);
                  },
                  onEditTask: (task) {
                    // Navigate to task edit screen
                  },
                  onDeleteTask: (id) {
                    taskProvider.deleteTask(id);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加新任务',
        onPressed: () {
          // Navigate to add task screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
