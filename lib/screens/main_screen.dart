import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:desktop_window/desktop_window.dart';
import '../providers/app_provider.dart';
import '../providers/list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/list_navigation.dart';
import '../widgets/task_list_view.dart';
import '../widgets/task_dialogs.dart';
import '../widgets/menu_dialogs.dart';
import '../widgets/native_menu_bar.dart';

enum TaskViewType { all, today, planned, completed, list }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TaskViewType _currentViewType = TaskViewType.all;
  String _statusMessage = '';
  int? _todayCount;
  int? _plannedCount;
  int? _allCount;
  int? _completedCount;
  Map<int, int> _listTaskCounts = {};
  bool _wasConnected = false;
  bool _showQuickAddInput = true;

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
        _setViewType(TaskViewType.list);
        if (mounted) {
          setState(() {
            _showQuickAddInput = true;
          });
        }
      } else {
        await taskProvider.loadAllTasks();
        _setViewType(TaskViewType.all);
        if (mounted) {
          setState(() {
            _showQuickAddInput = false;
          });
        }
      }

      await _updateTaskCounts();
      if (mounted) {
        _updateStatus(AppLocalizations.of(context)!.statusDataLoaded);
      }
    }
  }

  void _setViewType(TaskViewType type) {
    if (mounted) {
      setState(() {
        _currentViewType = type;
      });
    }
  }

  String _getViewTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentViewType) {
      case TaskViewType.today:
        return l10n.navToday;
      case TaskViewType.planned:
        return l10n.navPlanned;
      case TaskViewType.all:
        return l10n.navAll;
      case TaskViewType.completed:
        return l10n.navCompleted;
      case TaskViewType.list:
        final listProvider = Provider.of<ListProvider>(context, listen: false);
        return listProvider.selectedList?.name ?? '';
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
          _todayCount = 0;
          _plannedCount = 0;
          _allCount = 0;
          _completedCount = 0;
          _listTaskCounts = {};
        });
      }
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final todayCount = await taskProvider.repository.getTodayTaskCount();
    final plannedCount = await taskProvider.repository.getPlannedTaskCount();
    final allCount = await taskProvider.repository.getIncompleteTaskCount();
    final completedCount = await taskProvider.repository
        .getCompletedTaskCount();

    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final Map<int, int> counts = {};
    for (final list in listProvider.lists) {
      final count = await taskProvider.repository.getTaskCountByList(list.id);
      counts[list.id] = count;
    }

    if (mounted) {
      setState(() {
        _todayCount = todayCount;
        _plannedCount = plannedCount;
        _allCount = allCount;
        _completedCount = completedCount;
        _listTaskCounts = counts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Platform.isMacOS ? const NativeMenuBar() : const AppMenuBar(),

          Expanded(
            child: Consumer3<AppProvider, ListProvider, TaskProvider>(
              builder:
                  (context, appProvider, listProvider, taskProvider, child) {
                    // Monitor database connection status changes
                    final isConnected = appProvider.isDatabaseConnected;
                    if (_wasConnected != isConnected) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (isConnected) {
                          _updateStatus(AppLocalizations.of(context)!.statusDatabaseConnected);
                        } else {
                          _updateStatus(AppLocalizations.of(context)!.statusDatabaseClosed);
                        }
                      });
                      _wasConnected = isConnected;
                    }

                    // Refresh data when database connection changes
                    if (appProvider.isDatabaseConnected &&
                        listProvider.lists.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await _loadInitialData();
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
                        if (appProvider.isSidebarVisible)
                          SizedBox(
                            width: 280,
                            child: ListNavigation(
                              lists: listProvider.lists,
                              selectedList: listProvider.selectedList,
                              taskCounts: _listTaskCounts,
                              onSelectList: (list) {
                                listProvider.selectList(list);
                                taskProvider.loadTasksByList(list.id);
                                _setViewType(TaskViewType.list);
                                _updateStatus(AppLocalizations.of(context)!.statusSwitchList(list.name));
                                if (mounted) {
                                  setState(() {
                                    _showQuickAddInput = true;
                                  });
                                }
                              },
                              onAddList: (name, {icon, color}) {
                                listProvider.addList(
                                  name,
                                  icon: icon,
                                  color: color,
                                );
                                _updateStatus('创建列表: $name');
                              },
                              onDeleteList: (id) {
                                listProvider.deleteList(id);
                                _updateStatus('删除列表成功');
                              },
                              onTodayTap: () {
                                if (!appProvider.isDatabaseConnected) {
                                  _updateStatus(AppLocalizations.of(context)!.statusPleaseOpenDb);
                                  return;
                                }
                                listProvider.clearSelection();
                                taskProvider.loadTodayTasks();
                                _setViewType(TaskViewType.today);
                                _updateStatus(AppLocalizations.of(context)!.statusShowToday);
                                if (mounted) {
                                  setState(() {
                                    _showQuickAddInput = false;
                                  });
                                }
                              },
                              onPlannedTap: () {
                                if (!appProvider.isDatabaseConnected) {
                                  _updateStatus(AppLocalizations.of(context)!.statusPleaseOpenDb);
                                  return;
                                }
                                listProvider.clearSelection();
                                taskProvider.loadPlannedTasks();
                                _setViewType(TaskViewType.planned);
                                _updateStatus(AppLocalizations.of(context)!.statusShowPlanned);
                                if (mounted) {
                                  setState(() {
                                    _showQuickAddInput = false;
                                  });
                                }
                              },
                              onAllTap: () {
                                if (!appProvider.isDatabaseConnected) {
                                  _updateStatus(AppLocalizations.of(context)!.statusPleaseOpenDb);
                                  return;
                                }
                                listProvider.clearSelection();
                                taskProvider.loadAllTasks();
                                _setViewType(TaskViewType.all);
                                _updateStatus(AppLocalizations.of(context)!.statusShowAll);
                                if (mounted) {
                                  setState(() {
                                    _showQuickAddInput = false;
                                  });
                                }
                              },
                              onCompletedTap: () {
                                if (!appProvider.isDatabaseConnected) {
                                  _updateStatus(AppLocalizations.of(context)!.statusPleaseOpenDb);
                                  return;
                                }
                                listProvider.clearSelection();
                                taskProvider.loadCompletedTasks();
                                _setViewType(TaskViewType.completed);
                                _updateStatus(AppLocalizations.of(context)!.statusShowCompleted);
                                if (mounted) {
                                  setState(() {
                                    _showQuickAddInput = false;
                                  });
                                }
                              },
                              todayCount: _todayCount,
                              plannedCount: _plannedCount,
                              allCount: _allCount,
                              completedCount: _completedCount,
                              isDatabaseConnected:
                                  appProvider.isDatabaseConnected,
                            ),
                          ),

                        if (appProvider.isSidebarVisible)
                          const VerticalDivider(width: 1),

                        Expanded(
                          child: TaskListView(
                            tasks: taskProvider.tasks,
                            isLoading: taskProvider.isLoading,
                            isDatabaseConnected:
                                appProvider.isDatabaseConnected,
                            onToggleTask: (id) async {
                              await taskProvider.toggleTaskCompleted(id);
                              await _updateTaskCounts();
                              _updateStatus(AppLocalizations.of(context)!.statusUpdateTaskState);
                            },
                            onEditTask: (task) {
                              _showEditTaskDialog(task);
                            },
                            onDeleteTask: (id) {
                              _showDeleteConfirmDialog(id);
                            },
                            onMoveTaskToList: (taskId, newListId) {
                              _handleTaskMoved(taskId, newListId);
                            },
                            onTaskAdded: (listId) {
                              _handleTaskAdded(listId);
                            },
                            onTaskUpdated: (listId) {
                              _updateTaskCounts();
                            },
                            currentViewTitle: _getViewTitle(context),
                            currentListId: listProvider.selectedList?.id,
                            lists: listProvider.lists,
                            selectedList: listProvider.selectedList,
                            onToggleSidebar: appProvider.toggleSidebar,
                            isSidebarVisible: appProvider.isSidebarVisible,
                            showQuickAddInput: _showQuickAddInput,
                            completedCount: _completedCount,
                            isGrouped: _currentViewType == TaskViewType.all,
                          ),
                        ),
                      ],
                    );
                  },
            ),
          ),

          _buildStatusBar(context),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
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
            _statusMessage.isEmpty ? AppLocalizations.of(context)!.statusDatabaseNotConnected : _statusMessage,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(dynamic task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => TaskDetailDialog(
        task: task,
        onUpdate: (updatedTask) async {
          await taskProvider.updateTask(updatedTask);
          _updateTaskCounts();
          if (mounted) {
            _updateStatus(AppLocalizations.of(context)!.statusTaskUpdated);
          }
        },
      ),
    );
  }

  void _handleTaskAdded(int listId) async {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final addedList = listProvider.lists.firstWhere(
      (list) => list.id == listId,
      orElse: () => listProvider.lists.first,
    );

    await taskProvider.loadTasksByList(listId);
    listProvider.selectList(addedList);
    _setViewType(TaskViewType.list);
    _updateTaskCounts();
    if (mounted) {
      _updateStatus(AppLocalizations.of(context)!.statusTaskAdded);
    }
  }

  Future<void> _handleTaskMoved(int taskId, int newListId) async {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // appProvider is unused

    final movedList = listProvider.lists.firstWhere(
      (list) => list.id == newListId,
      orElse: () => listProvider.lists.first,
    );

    await taskProvider.loadTasksByList(newListId);
    listProvider.selectList(movedList);
    _setViewType(TaskViewType.list);
    _updateTaskCounts();
    if (mounted) {
      _updateStatus(AppLocalizations.of(context)!.statusTaskMoved(movedList.name));
    }
  }

  void _showDeleteConfirmDialog(int taskId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.taskDeleteConfirm),
        content: Text(l10n.taskDeleteConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
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
                if (mounted) {
                  _updateStatus(l10n.statusTaskDeleted);
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.taskDelete),
          ),
        ],
      ),
    );
  }
}
