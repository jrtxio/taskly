import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/date_parser.dart';

class ReminderTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final Function(Task) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onShowDetail;

  const ReminderTaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onUpdate,
    required this.onDelete,
    required this.onShowDetail,
  });

  @override
  State<ReminderTaskItem> createState() => _ReminderTaskItemState();
}

class _ReminderTaskItemState extends State<ReminderTaskItem> {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  late FocusNode _textFocusNode;
  late FocusNode _notesFocusNode;
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task.text);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _textFocusNode = FocusNode()
      ..addListener(() {
        if (_textFocusNode.hasFocus) {
          setState(() => _isSelected = true);
        } else {
          _saveTextChanges();
          _checkAndUpdateSelection();
        }
      });
    _notesFocusNode = FocusNode()
      ..addListener(() {
        if (_notesFocusNode.hasFocus) {
          setState(() => _isSelected = true);
        } else {
          _saveNotesChanges();
          _checkAndUpdateSelection();
        }
      });
  }

  @override
  void didUpdateWidget(ReminderTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.text != widget.task.text) {
      if (!_textFocusNode.hasFocus) {
        _textController.text = widget.task.text;
      }
    }
    if (oldWidget.task.notes != widget.task.notes) {
      if (!_notesFocusNode.hasFocus) {
        _notesController.text = widget.task.notes ?? '';
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    _textFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _saveTextChanges() {
    final value = _textController.text;
    if (value != widget.task.text) {
      final updatedTask = widget.task.copyWith(text: value);
      widget.onUpdate(updatedTask);
    }
  }

  void _saveNotesChanges() {
    final value = _notesController.text;
    final updatedNotes = value.isEmpty ? null : value;
    if (updatedNotes != widget.task.notes) {
      final updatedTask = widget.task.copyWith(notes: updatedNotes);
      widget.onUpdate(updatedTask);
    }
  }

  void _checkAndUpdateSelection() {
    if (!_textFocusNode.hasFocus && !_notesFocusNode.hasFocus) {
      setState(() => _isSelected = false);
    }
  }

  void _handleTextSubmitted(String value) {
    _textFocusNode.unfocus();
  }

  void _handleNotesSubmitted(String value) {
    _notesFocusNode.unfocus();
  }

  void _handleContainerTap() {
    if (!_textFocusNode.hasFocus && !_notesFocusNode.hasFocus) {
      setState(() => _isSelected = true);
    }
  }

  String _formatDateTimeDisplay() {
    if (widget.task.dueDate == null || widget.task.dueDate!.isEmpty) {
      return '';
    }

    final dateDisplay = DateParser.formatDateOnlyForDisplay(
      widget.task.dueDate,
    );
    final timeDisplay = DateParser.formatTimeForDisplay(widget.task.dueTime);

    if (timeDisplay.isNotEmpty) {
      return '$dateDisplay $timeDisplay';
    }
    return dateDisplay;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleContainerTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          decoration: BoxDecoration(
            color: (_isHovered || _isSelected) ? Colors.grey[50] : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckbox(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      _buildNotesField(),
                      _buildDateTime(),
                    ],
                  ),
                ),
                if (_isSelected ||
                    _textFocusNode.hasFocus ||
                    _notesFocusNode.hasFocus) ...[
                  const SizedBox(width: 4),
                  _buildInfoButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      key: Key('checkbox_${widget.task.id}'),
      onTap: widget.onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.task.completed
                ? Colors.transparent
                : Colors.grey[400]!,
            width: 1.5,
          ),
          color: widget.task.completed
              ? const Color(0xFF007AFF)
              : Colors.transparent,
        ),
        child: widget.task.completed
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _textController,
      focusNode: _textFocusNode,
      cursorColor: const Color(0xFF007AFF),
      cursorWidth: 1.5,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        decoration: widget.task.completed ? TextDecoration.lineThrough : null,
        color: widget.task.completed ? Colors.grey[500] : Colors.black87,
        height: 1.5,
      ),
      onSubmitted: _handleTextSubmitted,
      onEditingComplete: () => _textFocusNode.unfocus(),
      maxLines: null,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      focusNode: _notesFocusNode,
      cursorColor: const Color(0xFF007AFF),
      cursorWidth: 1.5,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      onSubmitted: _handleNotesSubmitted,
      onEditingComplete: () => _notesFocusNode.unfocus(),
      maxLines: null,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildDateTime() {
    final dateTimeDisplay = _formatDateTimeDisplay();
    final hasDate =
        widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty;

    if (!hasDate) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  '添加日期',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateParser.formatDateOnlyForDisplay(widget.task.dueDate!),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          if (widget.task.dueTime != null &&
              widget.task.dueTime!.isNotEmpty) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateParser.formatTimeForDisplay(widget.task.dueTime),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '添加时间',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    DateTime initialDate;

    try {
      initialDate =
          widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty
          ? DateTime.parse(widget.task.dueDate!)
          : now;
    } catch (e) {
      initialDate = now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final updatedTask = widget.task.copyWith(
        dueDate: DateFormat('yyyy-MM-dd').format(picked),
      );
      widget.onUpdate(updatedTask);
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (widget.task.dueTime != null && widget.task.dueTime!.isNotEmpty) {
      try {
        final parts = widget.task.dueTime!.split(':');
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        initialTime = TimeOfDay.now();
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final updatedTask = widget.task.copyWith(
        dueTime:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
      widget.onUpdate(updatedTask);
    }
  }

  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: widget.onShowDetail,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
      ),
    );
  }
}
