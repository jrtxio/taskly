import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/todo_list.dart';

class TaskInputDialog extends StatefulWidget {
  final List<TodoList> lists;
  final TodoList? selectedList;
  final Function(Task) onAdd;
  final bool isDatabaseConnected;

  const TaskInputDialog({
    super.key,
    required this.lists,
    this.selectedList,
    required this.onAdd,
    this.isDatabaseConnected = true,
  });

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  final _textController = TextEditingController();
  final _dateController = TextEditingController();
  TodoList? _selectedList;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.selectedList;
    if (widget.selectedList == null && widget.lists.isNotEmpty) {
      _selectedList = widget.lists.first;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入任务描述')),
      );
      return;
    }

    if (_selectedList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择任务列表')),
      );
      return;
    }

    final dueDate = _dateController.text.trim().isEmpty
        ? null
        : _dateController.text.trim();

    final task = Task(
      id: 0,
      listId: _selectedList!.id,
      text: text,
      dueDate: dueDate,
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _isSubmitting = true;
    });

    widget.onAdd(task).then((_) {
      Navigator.of(context).pop();
    }).catchError((error) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加任务失败: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDatabaseConnected) {
      return AlertDialog(
        title: const Text('无法添加任务'),
        content: const Text('数据库未连接，请先创建或打开数据库文件'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('添加新任务'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('任务描述:'),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '输入任务内容...',
              ),
            ),
            const SizedBox(height: 16),
            const Text('截止日期 (可选):'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '例如: +1d, @10am, 2025-08-07',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '支持智能日期格式: +1d (明天), @10am (上午10点), +1w (下周)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text('任务列表:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TodoList>(
              value: _selectedList,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: widget.lists.map((list) {
                return DropdownMenuItem<TodoList>(
                  value: list,
                  child: Text(list.name),
                );
              }).toList(),
              onChanged: (list) {
                setState(() {
                  _selectedList = list;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确定'),
        ),
      ],
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final List<TodoList> lists;
  final Function(Task) onUpdate;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.lists,
    required this.onUpdate,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final _textController = TextEditingController(text: widget.task.text);
  late final _dateController =
      TextEditingController(text: widget.task.dueDate ?? '');
  late TodoList _selectedList;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.lists.firstWhere(
      (list) => list.id == widget.task.listId,
      orElse: () => widget.lists.isNotEmpty ? widget.lists.first : widget.lists[0],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入任务描述')),
      );
      return;
    }

    final dueDate = _dateController.text.trim().isEmpty
        ? null
        : _dateController.text.trim();

    final updatedTask = widget.task.copyWith(
      text: text,
      dueDate: dueDate,
      listId: _selectedList.id,
    );

    setState(() {
      _isSubmitting = true;
    });

    widget.onUpdate(updatedTask).then((_) {
      Navigator.of(context).pop();
    }).catchError((error) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新任务失败: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑任务'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('任务描述:'),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('截止日期 (可选):'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '例如: +1d, @10am, 2025-08-07',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '支持智能日期格式: +1d (明天), @10am (上午10点), +1w (下周)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text('任务列表:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TodoList>(
              value: _selectedList,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: widget.lists.map((list) {
                return DropdownMenuItem<TodoList>(
                  value: list,
                  child: Text(list.name),
                );
              }).toList(),
              onChanged: (list) {
                setState(() {
                  _selectedList = list!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确定'),
        ),
      ],
    );
  }
}
