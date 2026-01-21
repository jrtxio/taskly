import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/date_parser.dart';

class ReminderTaskItem extends StatefulWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onToggle;
  final Function(Task) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onShowDetail;
  final VoidCallback onSelect;

  const ReminderTaskItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onToggle,
    required this.onUpdate,
    required this.onDelete,
    required this.onShowDetail,
    required this.onSelect,
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

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task.text);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _textFocusNode = FocusNode()
      ..addListener(() {
        if (_textFocusNode.hasFocus) {
          widget.onSelect();
        } else {
          _saveTextChanges();
        }
      });
    _notesFocusNode = FocusNode()
      ..addListener(() {
        if (_notesFocusNode.hasFocus) {
          widget.onSelect();
        } else {
          _saveNotesChanges();
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

  void _handleTextSubmitted(String value) {
    _textFocusNode.unfocus();
  }

  void _handleNotesSubmitted(String value) {
    _notesFocusNode.unfocus();
  }

  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate != null &&
              widget.task.dueDate!.isNotEmpty
          ? DateTime.tryParse(widget.task.dueDate!) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(pickedDate);

    final updatedTask = widget.task.copyWith(
      dueDate: '$dateStr 00:00:00',
    );
    widget.onUpdate(updatedTask);
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: widget.task.dueTime != null &&
              widget.task.dueTime!.isNotEmpty
          ? TimeOfDay(
              hour: int.tryParse(widget.task.dueTime!.split(':')[0]) ?? 9,
              minute: int.tryParse(widget.task.dueTime!.split(':')[1]) ?? 0,
            )
          : const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) return;

    final timeStr = DateFormat('HH:mm').format(
      DateTime(2024, 1, 1, pickedTime.hour, pickedTime.minute),
    );

    final updatedTask = widget.task.copyWith(
      dueTime: timeStr,
    );
    widget.onUpdate(updatedTask);
  }

  void _handleContainerTap() {
    if (!_textFocusNode.hasFocus && !_notesFocusNode.hasFocus) {
      widget.onSelect();
    }
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
            color: (_isHovered || widget.isSelected)
                ? Colors.grey[50]
                : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                      if (_textFocusNode.hasFocus ||
                          _notesFocusNode.hasFocus ||
                          (widget.task.notes != null &&
                              widget.task.notes!.isNotEmpty))
                        _buildNotesField(),
                      _buildDateTime(),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Opacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: _buildInfoButton(),
                ),
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
        filled: false,
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
    return GestureDetector(
      onTap: () => _notesFocusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: TextField(
        controller: _notesController,
        focusNode: _notesFocusNode,
        cursorColor: const Color(0xFF007AFF),
        cursorWidth: 1.5,
        decoration: const InputDecoration(
          filled: false,
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
      ),
    );
  }

  Widget _buildDateTime() {
    final hasDate =
        widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty;

    final isEditing = _textFocusNode.hasFocus || _notesFocusNode.hasFocus;

    if (!hasDate && !isEditing) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (hasDate || isEditing)
            MouseRegion(
              cursor: isEditing ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: isEditing ? _showDatePicker : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEditing ? Colors.blue[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isEditing ? Border.all(color: Colors.blue[200]!) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isEditing ? const Color(0xFF007AFF) : (hasDate ? Colors.grey[500] : Colors.grey[300]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasDate
                            ? DateParser.formatDateOnlyForDisplay(widget.task.dueDate!)
                            : '添加日期',
                        style: TextStyle(
                          fontSize: 13,
                          color: isEditing ? Colors.blue[700] : (hasDate ? Colors.grey[600] : Colors.grey[400]),
                          fontStyle: isEditing && !hasDate ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if ((widget.task.dueTime != null &&
                  widget.task.dueTime!.isNotEmpty) ||
              isEditing) ...[
            if (hasDate) const SizedBox(width: 8),
            MouseRegion(
              cursor: isEditing ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: isEditing ? _showTimePicker : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEditing ? Colors.blue[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isEditing ? Border.all(color: Colors.blue[200]!) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isEditing
                            ? const Color(0xFF007AFF)
                            : (widget.task.dueTime != null &&
                                    widget.task.dueTime!.isNotEmpty
                                ? Colors.grey[500]
                                : Colors.grey[300]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.dueTime != null &&
                                widget.task.dueTime!.isNotEmpty
                            ? DateParser.formatTimeForDisplay(widget.task.dueTime)
                            : '添加时间',
                        style: TextStyle(
                          fontSize: 13,
                          color: isEditing
                              ? Colors.blue[700]
                              : (widget.task.dueTime != null &&
                                      widget.task.dueTime!.isNotEmpty
                                  ? Colors.grey[600]
                                  : Colors.grey[400]),
                          fontStyle: isEditing &&
                                  (widget.task.dueTime == null ||
                                      widget.task.dueTime!.isEmpty)
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
