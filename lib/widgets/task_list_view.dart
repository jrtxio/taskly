import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../providers/task_provider.dart';
import '../utils/date_parser.dart';

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final bool isLoading;
  final Function(int) onToggleTask;
  final Function(Task) onEditTask;
  final Function(int) onDeleteTask;
  final Function(int)? onTaskAdded;
  final String? currentViewTitle;
  final int? currentListId;
  final List<TodoList> lists;
  final bool isDatabaseConnected;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onDeleteTask,
    this.onTaskAdded,
    this.currentViewTitle,
    this.currentListId,
    this.lists = const [],
    this.isDatabaseConnected = true,
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isDatabaseConnected) {
      return _buildTaskList();
    }

    return Column(
      children: [
        _buildQuickAddInput(),
        Expanded(child: _buildTaskList()),
      ],
    );
  }

  Widget _buildQuickAddInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDatabaseConnected ? Colors.grey[50] : Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _quickAddController,
              enabled: widget.isDatabaseConnected,
              decoration: InputDecoration(
                hintText: widget.isDatabaseConnected
                    ? '添加新任务... (支持 +1d, @10am 等快捷日期)'
                    : '请先创建或打开数据库',
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return TaskItem(
          task: task,
          onToggle: () => widget.onToggleTask(task.id),
          onEdit: () => widget.onEditTask(task),
          onDelete: () => widget.onDeleteTask(task.id),
        );
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: task.completed,
              onChanged: (value) => onToggle(),
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey, width: 2),
            ),
          ),
          title: Text(
            task.text,
            style: TextStyle(
              fontSize: 15,
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: task.completed ? Colors.grey : Colors.black87,
              height: 1.4,
            ),
          ),
          subtitle: task.dueDate != null && task.dueDate!.isNotEmpty
              ? Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateParser.formatDateForDisplay(task.dueDate),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                )
              : null,
          trailing: task.listName != null
              ? Chip(
                  label: Text(
                    task.listName!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                )
              : null,
          onTap: onToggle,
        ),
      ),
    );
  }
}
