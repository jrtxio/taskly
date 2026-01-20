import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_window/desktop_window.dart';
import '../providers/app_provider.dart';
import '../providers/list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/list_navigation.dart';
import '../widgets/task_list_view.dart';
import '../widgets/task_dialogs.dart';
import '../widgets/menu_dialogs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentViewTitle = '';
  String _statusMessage = '未连接数据库';
  int? _todayCount;
  int? _plannedCount;
  int? _allCount;
  int? _completedCount;
  bool _wasConnected = false;

  @override
  void initState() {
    super.initState();
    _resizeWindow();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _resizeWindow() async {
    await DesktopWindow.setWindowSize(const Size(1024, 768));
  }

  Future<void> _loadInitialData() async {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Only load data if database is connected
    if (appProvider.isDatabaseConnected) {
      await listProvider.loadLists();

      if (listProvider.selectedList != null) {
        await taskProvider.loadTasksByList(listProvider.selectedList!.id);
        _updateViewTitle(listProvider.selectedList!.name);
      } else {
        await taskProvider.loadAllTasks();
        _updateViewTitle('全部');
      }

      _updateTaskCounts();
      _updateStatus('数据已加载');
    }
  }

  void _updateViewTitle(String title) {
    if (mounted) {
      setState(() {
        _currentViewTitle = title;
      });
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  Future<void> _updateTaskCounts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (!appProvider.isDatabaseConnected) {
      if (mounted) {
        setState(() {
          _todayCount = null;
          _plannedCount = null;
          _allCount = null;
          _completedCount = null;
        });
      }
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final todayTasks = await taskProvider.repository.getTodayTasks();
    final plannedTasks = await taskProvider.repository.getPlannedTasks();
    final allTasks = await taskProvider.repository.getIncompleteTasks();
    final completedTasks = await taskProvider.repository.getCompletedTasks();

    if (mounted) {
      setState(() {
        _todayCount = todayTasks.length;
        _plannedCount = plannedTasks.length;
        _allCount = allTasks.length;
        _completedCount = completedTasks.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppMenuBar(),

          Expanded(
            child: Consumer3<AppProvider, ListProvider, TaskProvider>(
              builder:
                  (context, appProvider, listProvider, taskProvider, child) {
                    // Show empty state if database is not connected
                    if (!appProvider.isDatabaseConnected) {
                      return _buildEmptyState();
                    }

                    // Monitor database connection status changes
                    final isConnected = appProvider.isDatabaseConnected;
                    if (_wasConnected != isConnected) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (isConnected) {
                          _updateStatus('数据库已连接');
                        } else {
                          _updateStatus('数据库已关闭');
                        }
                      });
                      _wasConnected = isConnected;
                    }

                    // Refresh data when database connection changes
                    if (appProvider.isDatabaseConnected &&
                        listProvider.lists.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        listProvider.loadLists();
                        taskProvider.loadAllTasks();
                      });
                    }
                    // Clear data when database is disconnected
                    if (!appProvider.isDatabaseConnected &&
                        (listProvider.lists.isNotEmpty ||
                            taskProvider.tasks.isNotEmpty)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        listProvider.clearLists();
                        taskProvider.clearTasks();
                        _updateTaskCounts();
                      });
                    }
                    return Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: ListNavigation(
                            lists: listProvider.lists,
                            selectedList: listProvider.selectedList,
                            onSelectList: (list) {
                              listProvider.selectList(list);
                              taskProvider.loadTasksByList(list.id);
                              _updateViewTitle(list.name);
                              _updateStatus('切换到列表: ${list.name}');
                            },
                            onAddList: (name) {
                              listProvider.addList(name);
                              _updateStatus('创建列表: $name');
                            },
                            onDeleteList: (id) {
                              listProvider.deleteList(id);
                              _updateStatus('删除列表成功');
                            },
                            onTodayTap: () {
                              if (!appProvider.isDatabaseConnected) {
                                _updateStatus('请先打开数据库');
                                return;
                              }
                              taskProvider.loadTodayTasks();
                              _updateViewTitle('今天');
                              _updateStatus('显示今天的任务');
                            },
                            onPlannedTap: () {
                              if (!appProvider.isDatabaseConnected) {
                                _updateStatus('请先打开数据库');
                                return;
                              }
                              taskProvider.loadPlannedTasks();
                              _updateViewTitle('计划');
                              _updateStatus('显示计划中的任务');
                            },
                            onAllTap: () {
                              if (!appProvider.isDatabaseConnected) {
                                _updateStatus('请先打开数据库');
                                return;
                              }
                              taskProvider.loadAllTasks();
                              _updateViewTitle('全部');
                              _updateStatus('显示全部任务');
                            },
                            onCompletedTap: () {
                              if (!appProvider.isDatabaseConnected) {
                                _updateStatus('请先打开数据库');
                                return;
                              }
                              taskProvider.loadCompletedTasks();
                              _updateViewTitle('已完成');
                              _updateStatus('显示已完成的任务');
                            },
                            todayCount: _todayCount,
                            plannedCount: _plannedCount,
                            allCount: _allCount,
                            completedCount: _completedCount,
                          ),
                        ),

                        const VerticalDivider(width: 1),

                        Expanded(
                          child: TaskListView(
                            tasks: taskProvider.tasks,
                            isLoading: taskProvider.isLoading,
                            isDatabaseConnected:
                                appProvider.isDatabaseConnected,
                            onToggleTask: (id) {
                              taskProvider.toggleTaskCompleted(id);
                              _updateTaskCounts();
                              _updateStatus('更新任务状态');
                            },
                            onEditTask: (task) {
                              _showEditTaskDialog(task);
                            },
                            onDeleteTask: (id) {
                              _showDeleteConfirmDialog(id);
                            },
                            currentViewTitle: _currentViewTitle,
                            currentListId: listProvider.selectedList?.id,
                            lists: listProvider.lists,
                          ),
                        ),
                      ],
                    );
                  },
            ),
          ),

          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Text(
            _statusMessage,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            'Taskly v1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            '未打开数据库',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Text(
            '请通过菜单栏"文件"菜单\n创建新数据库或打开已有数据库',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(dynamic task) {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        lists: listProvider.lists,
        onUpdate: (updatedTask) async {
          await taskProvider.updateTask(updatedTask);
          _updateTaskCounts();
          _updateStatus('任务已更新');
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个任务吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              taskProvider.deleteTask(taskId).then((_) {
                _updateTaskCounts();
                _updateStatus('任务已删除');
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
