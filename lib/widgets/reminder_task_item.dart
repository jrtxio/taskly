import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/todo_list.dart';
import '../theme/app_design.dart';
import '../theme/app_theme.dart';
import '../utils/date_parser.dart';

class ReminderTaskItem extends StatefulWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onToggle;
  final Function(Task) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onShowDetail;
  final VoidCallback onSelect;
  final Function(int?) onMoveToList;
  final List<TodoList> lists;

  const ReminderTaskItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onToggle,
    required this.onUpdate,
    required this.onDelete,
    required this.onShowDetail,
    required this.onSelect,
    required this.onMoveToList,
    this.lists = const [],
  });

  @override
  State<ReminderTaskItem> createState() => _ReminderTaskItemState();
}

class _ReminderTaskItemState extends State<ReminderTaskItem>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  late FocusNode _textFocusNode;
  late FocusNode _notesFocusNode;
  bool _isHovered = false;
  bool _isTitleEditing = false;
  bool _isNotesEditing = false;

  bool _isInteractingWithPicker = false;

  // Animation for task completion
  late AnimationController _completionAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task.text);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _textFocusNode = FocusNode()
      ..addListener(() {
        if (_textFocusNode.hasFocus) {
          setState(() {
            _isTitleEditing = true;
          });
          widget.onSelect();
        } else {
          // Delay to allow interactions (like clicking date picker) to register
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            if (_isInteractingWithPicker) return;
            if (_textFocusNode.hasFocus) return;

            _saveTextChanges();
            setState(() {
              _isTitleEditing = false;
            });
          });
        }
      });
    _notesFocusNode = FocusNode()
      ..addListener(() {
        if (_notesFocusNode.hasFocus) {
          setState(() {
            _isNotesEditing = true;
          });
          widget.onSelect();
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            if (_isInteractingWithPicker) return;
            if (_notesFocusNode.hasFocus) return;

            _saveNotesChanges();
            setState(() {
              _isNotesEditing = false;
            });
          });
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
    _isInteractingWithPicker = true;
    final wasTitleEditing = _isTitleEditing;
    final wasNotesEditing = _isNotesEditing;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate != null &&
              widget.task.dueDate!.isNotEmpty
          ? DateTime.tryParse(widget.task.dueDate!) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    // Restore focus first, then reset the flag after focus is restored
    if (wasTitleEditing) {
      _textFocusNode.requestFocus();
    } else if (wasNotesEditing) {
      _notesFocusNode.requestFocus();
    }
    
    // Reset the flag after a frame to ensure focus restoration completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isInteractingWithPicker = false;
      }
    });

    if (pickedDate == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(pickedDate);

    final updatedTask = widget.task.copyWith(
      dueDate: '$dateStr 00:00:00',
    );
    widget.onUpdate(updatedTask);
  }

  Future<void> _showTimePicker() async {
    _isInteractingWithPicker = true;
    final wasTitleEditing = _isTitleEditing;
    final wasNotesEditing = _isNotesEditing;
    
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

    // Restore focus first, then reset the flag after focus is restored
    if (wasTitleEditing) {
      _textFocusNode.requestFocus();
    } else if (wasNotesEditing) {
      _notesFocusNode.requestFocus();
    }
    
    // Reset the flag after a frame to ensure focus restoration completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isInteractingWithPicker = false;
      }
    });

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

  void _handleRightClick(Offset offset) {
    if (_isTitleEditing || _isNotesEditing) return;
    _showContextMenu(offset);
  }

  void _showContextMenu(Offset offset) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        overlay.size.width - offset.dx,
        overlay.size.height - offset.dy,
      ),
      items: [
        if (!widget.task.completed)
          PopupMenuItem(
            value: 'complete',
            child: const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('标记完成'),
            ),
          )
        else
          PopupMenuItem(
            value: 'uncomplete',
            child: const ListTile(
              leading: Icon(Icons.circle_outlined),
              title: Text('标记未完成'),
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'move',
          child: const ListTile(
            leading: Icon(Icons.drive_file_move),
            title: Text('列表'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: const ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('删除任务', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    ).then((value) async {
      if (value == null) return;

      if (value == 'delete') {
        widget.onDelete();
      } else if (value == 'complete') {
        widget.onToggle();
      } else if (value == 'uncomplete') {
        widget.onToggle();
      } else if (value == 'move') {
        _showMoveMenu(offset);
      }
    });
  }

  void _showMoveMenu(Offset offset) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        overlay.size.width - offset.dx,
        overlay.size.height - offset.dy,
      ),
      items: widget.lists.map((list) {
        return PopupMenuItem(
          value: list.id,
          child: ListTile(
            leading: list.icon != null
                ? Text(list.icon!, style: const TextStyle(fontSize: 20))
                : const Icon(Icons.list),
            title: Text(list.name),
            trailing: list.id == widget.task.listId
                ? const Icon(Icons.check, size: 20)
                : null,
          ),
        );
      }).toList(),
    ).then((listId) {
      if (listId != null && listId != widget.task.listId) {
        widget.onMoveToList(listId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleContainerTap,
        onSecondaryTapDown: (details) => _handleRightClick(details.globalPosition),
        behavior: HitTestBehavior.translucent,
        child: Container(
          decoration: BoxDecoration(
            color: (_isHovered || widget.isSelected)
                ? AppTheme.highlightBackground(context)
                : AppTheme.cardBackground(context),
          ),
          child: Padding(
            padding: AppDesign.contentPadding,
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
                      if (_isTitleEditing ||
                          _isNotesEditing ||
                          (widget.task.notes != null &&
                              widget.task.notes!.isNotEmpty))
                        _buildNotesField(),
                      _buildDateTime(
                        hasNotes: widget.task.notes != null &&
                            widget.task.notes!.isNotEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Opacity(
                  opacity: (_isHovered || widget.isSelected) ? 1.0 : 0.0,
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
        width: AppDesign.checkboxSize,
        height: AppDesign.checkboxSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.task.completed
                ? Colors.transparent
                : AppTheme.onSurfaceTertiary(context),
            width: 1.5,
          ),
          color: widget.task.completed
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
        child: widget.task.completed
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildTitleField() {
    if (_isTitleEditing) {
      return TextField(
        controller: _textController,
        focusNode: _textFocusNode,
        autofocus: true,
        cursorColor: Theme.of(context).colorScheme.primary,
        cursorWidth: 1.5,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: widget.task.completed ? AppTheme.onSurfaceSecondary(context) : Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
        onSubmitted: _handleTextSubmitted,
        onEditingComplete: () => _textFocusNode.unfocus(),
        maxLines: null,
        textInputAction: TextInputAction.done,
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isTitleEditing = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _textFocusNode.requestFocus();
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Text(
          widget.task.text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: widget.task.completed ? TextDecoration.lineThrough : null,
            color: widget.task.completed ? AppTheme.onSurfaceSecondary(context) : Theme.of(context).colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      );
    }
  }

  Widget _buildNotesField() {
    if (_isNotesEditing) {
      return TextField(
        controller: _notesController,
        focusNode: _notesFocusNode,
        cursorColor: Theme.of(context).colorScheme.primary,
        cursorWidth: 1.5,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.onSurfaceVariant(context),
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
        onSubmitted: _handleNotesSubmitted,
        onEditingComplete: () => _notesFocusNode.unfocus(),
        maxLines: null,
        textInputAction: TextInputAction.done,
      );
    } else {
      final hasNotes = widget.task.notes != null && widget.task.notes!.isNotEmpty;
      final isInEditingContext = _isTitleEditing; // 标题正在编辑时，备注区域也应可点击
      
      return GestureDetector(
        onTap: () {
          setState(() {
            _isNotesEditing = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notesFocusNode.requestFocus();
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: (isInEditingContext && !hasNotes) 
              ? const BoxConstraints(minHeight: 20) 
              : null,
          child: Text(
            hasNotes 
                ? widget.task.notes! 
                : (isInEditingContext ? AppLocalizations.of(context)!.hintAddNotes : ''),
            style: TextStyle(
              fontSize: 12,
              color: hasNotes ? AppTheme.onSurfaceVariant(context) : AppTheme.onSurfaceTertiary(context),
              height: 1.4,
              fontWeight: FontWeight.w400,
              fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDateTime({bool hasNotes = false}) {
    final hasDate =
        widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty;

    final isEditing = _isTitleEditing || _isNotesEditing;

    if (!hasDate && !isEditing) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: hasNotes ? 2 : 4),
      child: Row(
        children: [
          if (hasDate || isEditing)
            MouseRegion(
              cursor: isEditing ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: isEditing ? _showDatePicker : null,
                child: Container(
                  padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: isEditing ? AppTheme.chipBackground(context) : Colors.transparent,
                    borderRadius: AppDesign.borderRadiusSmall,
                    border: isEditing ? Border.all(color: AppTheme.chipBorder(context)) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isEditing ? Theme.of(context).colorScheme.primary : (hasDate ? AppTheme.onSurfaceSecondary(context) : AppTheme.dividerColor(context)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasDate
                            ? DateParser.formatDateOnlyForDisplay(widget.task.dueDate!, AppLocalizations.of(context)!)
                            : AppLocalizations.of(context)!.labelAddDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isEditing ? Theme.of(context).colorScheme.primary : (hasDate ? AppTheme.onSurfaceVariant(context) : AppTheme.onSurfaceTertiary(context)),
                          fontStyle: FontStyle.normal,
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
                  padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: isEditing ? AppTheme.chipBackground(context) : Colors.transparent,
                    borderRadius: AppDesign.borderRadiusSmall,
                    border: isEditing ? Border.all(color: AppTheme.chipBorder(context)) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isEditing
                            ? Theme.of(context).colorScheme.primary
                            : (widget.task.dueTime != null &&
                                    widget.task.dueTime!.isNotEmpty
                                ? AppTheme.onSurfaceSecondary(context)
                                : AppTheme.dividerColor(context)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.dueTime != null &&
                                widget.task.dueTime!.isNotEmpty
                            ? DateParser.formatTimeForDisplay(widget.task.dueTime)
                            : AppLocalizations.of(context)!.labelAddTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: isEditing
                              ? Theme.of(context).colorScheme.primary
                              : (widget.task.dueTime != null &&
                                      widget.task.dueTime!.isNotEmpty
                                  ? AppTheme.onSurfaceVariant(context)
                                  : AppTheme.onSurfaceTertiary(context)),
                          fontStyle: FontStyle.normal,
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
        child: Icon(Icons.info_outline, size: 18, color: AppTheme.onSurfaceTertiary(context)),
      ),
    );
  }
}
