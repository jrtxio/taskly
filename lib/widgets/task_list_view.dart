import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../providers/task_provider.dart';
import '../utils/date_parser.dart';
import 'reminder_task_item.dart';

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final bool isLoading;
  final Function(int) onToggleTask;
  final Function(Task) onEditTask;
  final Function(int) onDeleteTask;
  final Function(int)? onTaskUpdated;
  final Function(int)? onTaskAdded;
  final String? currentViewTitle;
  final int? currentListId;
  final List<TodoList> lists;
  final bool isDatabaseConnected;
  final TodoList? selectedList;
  final VoidCallback? onToggleSidebar;
  final bool isSidebarVisible;
  final bool showQuickAddInput;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onDeleteTask,
    this.onTaskUpdated,
    this.onTaskAdded,
    this.currentViewTitle,
    this.currentListId,
    this.lists = const [],
    this.isDatabaseConnected = true,
    this.selectedList,
    this.onToggleSidebar,
    this.isSidebarVisible = true,
    this.showQuickAddInput = true,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final _quickAddController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  void _handleQuickAdd() {
    if (_isSubmitting || !widget.isDatabaseConnected) return;

    final input = _quickAddController.text.trim();
    if (input.isEmpty) return;

    final parts = input.split(RegExp(r'\s+(?=[+@]|$)'));
    String taskText = input;
    String? dueDate;

    if (parts.length >= 2) {
      taskText = parts.sublist(0, parts.length - 1).join(' ').trim();
      final datePart = parts.last.trim();
      final parsedDate = DateParser.parse(datePart);
      if (parsedDate != null) {
        dueDate = parsedDate;
      }
    }

    if (taskText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入任务描述')));
      return;
    }

    final listId =
        widget.currentListId ??
        (widget.lists.isNotEmpty ? widget.lists.first.id : 0);
    if (listId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先创建一个任务列表')));
      return;
    }

    final task = Task(
      id: 0,
      listId: listId,
      text: taskText,
      dueDate: dueDate,
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _isSubmitting = true;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider
        .addTask(task)
        .then((_) {
          setState(() {
            _quickAddController.clear();
            _isSubmitting = false;
          });
          widget.onTaskAdded?.call(task.listId);
        })
        .catchError((error) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('添加任务失败: $error')));
        });
  }

  Future<void> _handleTaskUpdate(Task updatedTask) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.updateTask(updatedTask);
    widget.onTaskUpdated?.call(updatedTask.listId);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDatabaseConnected) {
      return Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildTaskList()),
        ],
      );
    }

    return Column(
      children: [
        _buildHeader(),
        if (widget.showQuickAddInput) _buildQuickAddInput(),
        Expanded(child: _buildTaskList()),
      ],
    );
  }

  Widget _buildHeader() {
    String title;
    IconData? icon;
    Color? iconColor;

    if (widget.selectedList != null) {
      final list = widget.selectedList!;
      title = list.name;
      iconColor = list.color ?? Colors.blue;
      icon = list.icon != null ? null : Icons.folder;
    } else {
      title = widget.currentViewTitle ?? '';
      iconColor = _getViewTitleColor(title);
      icon = _getViewTitleIcon(title);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.isSidebarVisible ? Icons.chevron_left : Icons.menu,
              color: Colors.grey[600],
            ),
            onPressed: widget.onToggleSidebar,
            padding: const EdgeInsets.only(left: -12),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: widget.isSidebarVisible ? '隐藏侧边栏' : '显示侧边栏',
          ),
          if (widget.isDatabaseConnected) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor ?? Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 14)
                    : (widget.selectedList?.icon != null
                          ? Text(
                              widget.selectedList!.icon!,
                              style: const TextStyle(fontSize: 14),
                            )
                          : const Icon(
                              Icons.folder,
                              color: Colors.white,
                              size: 14,
                            )),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getViewTitleIcon(String title) {
    switch (title) {
      case '今天':
        return Icons.today;
      case '计划':
        return Icons.calendar_month;
      case '全部':
        return Icons.list;
      case '完成':
        return Icons.check_circle;
      default:
        return Icons.inbox;
    }
  }

  Color _getViewTitleColor(String title) {
    switch (title) {
      case '今天':
        return const Color(0xFF007AFF);
      case '计划':
        return const Color(0xFFFF3B30);
      case '全部':
        return const Color(0xFF8E8E93);
      case '完成':
        return const Color(0xFFFF9500);
      default:
        return Colors.blue;
    }
  }

  Widget _buildQuickAddInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDatabaseConnected ? Colors.grey[50] : Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _quickAddController,
              enabled: widget.isDatabaseConnected,
              decoration: InputDecoration(
                hintText: widget.isDatabaseConnected ? '+ 添加任务' : '请先创建或打开数据库',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintStyle: TextStyle(
                  color: widget.isDatabaseConnected
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
              ),
              onSubmitted: (_) => _handleQuickAdd(),
            ),
          ),
          if (_isSubmitting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (!widget.isDatabaseConnected) {
      return const Center(
        child: Text(
          '请点击"文件"菜单创建或打开数据库',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '暂无任务',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final shouldGroup = widget.selectedList == null;
    if (shouldGroup) {
      return _buildGroupedTaskList();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return ReminderTaskItem(
          task: task,
          onToggle: () => widget.onToggleTask(task.id),
          onUpdate: _handleTaskUpdate,
          onDelete: () => widget.onDeleteTask(task.id),
          onShowDetail: () => widget.onEditTask(task),
        );
      },
    );
  }

  Widget _buildGroupedTaskList() {
    final Map<int, List<Task>> groupedTasks = {};
    for (final task in widget.tasks) {
      if (!groupedTasks.containsKey(task.listId)) {
        groupedTasks[task.listId] = [];
      }
      groupedTasks[task.listId]!.add(task);
    }

    final sortedListIds = groupedTasks.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedTasks.length,
      itemBuilder: (context, index) {
        final listId = sortedListIds[index];
        final tasks = groupedTasks[listId]!;
        final list = widget.lists.firstWhere(
          (l) => l.id == listId,
          orElse: () => TodoList(
            id: listId,
            name: '列表 $listId',
            icon: null,
            color: Colors.blue,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListHeader(list, tasks.length),
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ReminderTaskItem(
                  task: task,
                  onToggle: () => widget.onToggleTask(task.id),
                  onUpdate: _handleTaskUpdate,
                  onDelete: () => widget.onDeleteTask(task.id),
                  onShowDetail: () => widget.onEditTask(task),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(TodoList list, int taskCount) {
    final color = list.color ?? Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: list.icon != null
                  ? Text(list.icon!, style: const TextStyle(fontSize: 14))
                  : const Icon(Icons.folder, color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            list.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              taskCount.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
