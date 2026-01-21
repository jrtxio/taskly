import 'package:flutter/material.dart';
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
  late FocusNode _itemFocusNode;
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task.text);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _itemFocusNode = FocusNode()
      ..addListener(() {
        if (!_itemFocusNode.hasFocus) {
          setState(() => _isSelected = false);
        }
      });
    _textFocusNode = FocusNode()
      ..addListener(() {
        if (_textFocusNode.hasFocus) {
          _itemFocusNode.requestFocus();
        } else {
          _saveTextChanges();
        }
      });
    _notesFocusNode = FocusNode()
      ..addListener(() {
        if (_notesFocusNode.hasFocus) {
          _itemFocusNode.requestFocus();
        } else {
          _saveNotesChanges();
        }
      });
  }

  @override
  void didUpdateWidget(ReminderTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.text != widget.task.text) {
      _textController.text = widget.task.text;
    }
    if (oldWidget.task.notes != widget.task.notes) {
      _notesController.text = widget.task.notes ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    _textFocusNode.dispose();
    _notesFocusNode.dispose();
    _itemFocusNode.dispose();
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
      child: Focus(
        focusNode: _itemFocusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            setState(() => _isSelected = true);
          }
        },
        child: GestureDetector(
          onTap: () => _itemFocusNode.requestFocus(),
          child: Container(
            decoration: BoxDecoration(
              color: (_isHovered || _isSelected)
                  ? Colors.grey[50]
                  : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckbox(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        if (widget.task.notes != null &&
                            widget.task.notes!.isNotEmpty)
                          _buildNotesField(),
                        _buildDateTime(),
                      ],
                    ),
                  ),
                  if (_isSelected) ...[
                    const SizedBox(width: 8),
                    _buildInfoButton(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.task.completed ? Colors.transparent : Colors.grey,
            width: 2,
          ),
          color: widget.task.completed
              ? const Color(0xFF007AFF)
              : Colors.transparent,
        ),
        child: widget.task.completed
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : null,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _textController,
      focusNode: _textFocusNode,
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
        decoration: widget.task.completed ? TextDecoration.lineThrough : null,
        color: widget.task.completed ? Colors.grey : Colors.black87,
        height: 1.4,
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
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
      onSubmitted: _handleNotesSubmitted,
      onEditingComplete: () => _notesFocusNode.unfocus(),
      maxLines: null,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildDateTime() {
    final dateTimeDisplay = _formatDateTimeDisplay();
    if (dateTimeDisplay.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            dateTimeDisplay,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton() {
    return InkWell(
      onTap: widget.onShowDetail,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
      ),
    );
  }
}
