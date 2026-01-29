import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../utils/date_parser.dart';
import '../theme/app_theme.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.taskEnterDesc)));
      return;
    }

    if (_selectedList == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.taskSelectTask)));
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

    widget
        .onAdd(task)
        .then((_) {
          Navigator.of(context).pop();
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
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                hintText: '+ 添加任务',
              ),
            ),
            const SizedBox(height: 16),
            const Text('截止日期 (可选):'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                hintText: '例如: +10m, @10am, 2025-08-07',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '支持: +10m(10分钟), +2h(2小时), +1d(明天), @10am(上午10点), @10:30pm(晚上10:30)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant(context)),
            ),
            const SizedBox(height: 16),
            const Text('任务列表:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TodoList>(
              value: _selectedList,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: widget.lists.map((list) {
                return DropdownMenuItem<TodoList>(
                  value: list,
                  child: Text(list.name),
                );
              }).toList(),
              onChanged: (list) {
                if (list != null) {
                  setState(() {
                    _selectedList = list;
                  });
                }
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

class TaskDetailDialog extends StatefulWidget {
  final Task task;
  final Function(Task) onUpdate;
  final VoidCallback? onDelete;

  const TaskDetailDialog({
    super.key,
    required this.task,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  late final TextEditingController _textController = TextEditingController(
    text: widget.task.text,
  );
  late final TextEditingController _notesController = TextEditingController(
    text: widget.task.notes ?? '',
  );
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeDateAndTime();
  }

  void _initializeDateAndTime() {
    if (widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.task.dueDate!);
      } catch (e) {
        _selectedDate = null;
      }
    }

    if (widget.task.dueTime != null && widget.task.dueTime!.isNotEmpty) {
      try {
        final parts = widget.task.dueTime!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        _selectedTime = null;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _getCombinedDueDate() {
    if (_selectedDate == null) return '';
    return DateFormat('yyyy-MM-dd').format(_selectedDate!);
  }

  String _getDueTime() {
    if (_selectedTime == null) return '';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (_isSubmitting) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入任务描述')));
      return;
    }

    final notes = _notesController.text.trim();
    final dueDate = _getCombinedDueDate();

    final updatedTask = widget.task.copyWith(
      text: text,
      notes: notes.isEmpty ? null : notes,
      dueDate: dueDate,
      dueTime: _getDueTime(),
      completed: widget.task.completed,
    );

    setState(() {
      _isSubmitting = true;
    });

    widget
        .onUpdate(updatedTask)
        .then((_) {
          Navigator.of(context).pop();
        })
        .catchError((error) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('更新任务失败: $error')));
        });
  }

  void _handleDelete() {
    if (widget.onDelete == null) return;
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
              widget.onDelete!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('任务详情'),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('任务:'),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('备注:'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                hintText: '添加备注信息...',
              ),
            ),
            const SizedBox(height: 20),
            const Text('日期:'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.dividerColor(context)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getCombinedDueDate(),
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('时间:'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.dividerColor(context)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getDueTime(),
                      style: TextStyle(
                        color: _selectedTime != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton(
            onPressed: _isSubmitting ? null : _handleDelete,
            child: const Text('删除'),
          ),
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
              : const Text('保存'),
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
  late final _dateController = TextEditingController(
    text: widget.task.dueDate ?? '',
  );
  TodoList? _selectedList;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.lists.isEmpty) return;
    _selectedList = widget.lists.firstWhere(
      (list) => list.id == widget.task.listId,
      orElse: () => widget.lists.first,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.taskEnterDesc)));
      return;
    }

    final dueDate = _dateController.text.trim().isEmpty
        ? null
        : _dateController.text.trim();

    if (_selectedList == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.taskSelectTask)));
      return;
    }

    final updatedTask = widget.task.copyWith(
      text: text,
      dueDate: dueDate,
      listId: _selectedList!.id,
    );

    setState(() {
      _isSubmitting = true;
    });

    widget
        .onUpdate(updatedTask)
        .then((_) {
          Navigator.of(context).pop();
        })
        .catchError((error) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.taskUpdateFailed(error.toString()))));
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.dialogEditTask),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.labelTaskDesc),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.labelDueDateOptional),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground(context),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.dividerColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                hintText: l10n.hintDateExample,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.hintDateSupport,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant(context)),
            ),
            const SizedBox(height: 16),
            Text(l10n.labelTaskList),
            const SizedBox(height: 8),
            DropdownButtonFormField<TodoList>(
              initialValue: _selectedList,
              decoration: const InputDecoration(border: OutlineInputBorder()),
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
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogConfirm),
        ),
      ],
    );
  }
}
