import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/todo_list.dart';
import '../providers/list_provider.dart';
import 'emoji_picker.dart';
import 'color_picker.dart';

class ListNavigation extends StatefulWidget {
  final List<TodoList> lists;
  final TodoList? selectedList;
  final Map<int, int>? taskCounts;
  final Function(TodoList) onSelectList;
  final Function(String, {String? icon, Color? color}) onAddList;
  final Function(int) onDeleteList;
  final VoidCallback onTodayTap;
  final VoidCallback onPlannedTap;
  final VoidCallback onAllTap;
  final VoidCallback onCompletedTap;
  final int? todayCount;
  final int? plannedCount;
  final int? allCount;
  final int? completedCount;
  final bool isDatabaseConnected;

  const ListNavigation({
    super.key,
    required this.lists,
    required this.selectedList,
    this.taskCounts,
    required this.onSelectList,
    required this.onAddList,
    required this.onDeleteList,
    required this.onTodayTap,
    required this.onPlannedTap,
    required this.onAllTap,
    required this.onCompletedTap,
    this.todayCount,
    this.plannedCount,
    this.allCount,
    this.completedCount,
    this.isDatabaseConnected = true,
  });

  @override
  State<ListNavigation> createState() => _ListNavigationState();
}

class _ListNavigationState extends State<ListNavigation> {
  @override
  void dispose() {
    super.dispose();
  }

  void _showDeleteConfirmDialog(TodoList list) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.taskDelete),
          content: Text(l10n.dialogConfirmDeleteList(list.name)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteList(list.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.taskDelete),
            ),
          ],
        );
      },
    );
  }

  void _showListEditDialog({TodoList? list, bool renameOnly = false}) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = list != null;
    final nameController = TextEditingController(text: isEditing ? list.name : '');
    String? selectedEmoji = isEditing ? list.icon : null;
    Color? selectedColor = isEditing ? list.color : null;
    bool clearIcon = false;
    bool clearColor = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? l10n.dialogEditList : l10n.dialogCreateList),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.dialogListName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!renameOnly) ...[
                    Row(
                      children: [
                        Text('${l10n.dialogListIcon}: '),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            final emoji = await EmojiPicker.show(
                              context,
                              selectedEmoji: selectedEmoji,
                            );
                            if (emoji != null) {
                              setState(() {
                                selectedEmoji = emoji;
                                clearIcon = false;
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor ?? Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: selectedEmoji != null
                                  ? Text(
                                      selectedEmoji!,
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selectedEmoji != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                selectedEmoji = null;
                                clearIcon = true;
                              });
                            },
                            tooltip: l10n.dialogClearIcon,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('${l10n.dialogListColor}: '),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            print('DEBUG: Before ColorPicker.show - selectedColor: $selectedColor');
                            final color = await ColorPicker.show(
                              context,
                              selectedColor: selectedColor,
                            );
                            print('DEBUG: After ColorPicker.show - selected color: $color');
                            if (color != null) {
                              setState(() {
                                selectedColor = color;
                                clearColor = false;
                                print('DEBUG: Updated selectedColor to: $selectedColor, clearColor: $clearColor');
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor ?? Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.palette,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selectedColor != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                selectedColor = null;
                                clearColor = true;
                              });
                            },
                            tooltip: '清除颜色',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请输入列表名称')),
                    );
                    return;
                  }

                  if (isEditing) {
                    final listProvider = Provider.of<ListProvider>(
                      context,
                      listen: false,
                    );
                    print('DEBUG: Calling updateList with - name: $name, icon: $selectedEmoji, color: $selectedColor, clearIcon: $clearIcon, clearColor: $clearColor');
                    listProvider.updateList(
                      list.id,
                      name,
                      icon: selectedEmoji,
                      color: selectedColor,
                      clearIcon: clearIcon,
                      clearColor: clearColor,
                    );
                  } else {
                    widget.onAddList(
                      name,
                      icon: selectedEmoji,
                      color: selectedColor,
                    );
                  }

                  Navigator.of(context).pop();
                },
                child: Text(l10n.dialogConfirm),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditMenu(TodoList list, Offset offset) {
    final l10n = AppLocalizations.of(context)!;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        overlay.size.width - offset.dx,
        overlay.size.height - offset.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'info',
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.menuShowListInfo),
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.menuRename),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(l10n.dialogDeleteList, style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    ).then((value) async {
      if (value == null) return;

      if (value == 'delete') {
        _showDeleteConfirmDialog(list);
      } else if (value == 'info') {
        if (mounted) {
          _showListEditDialog(list: list, renameOnly: false);
        }
      } else if (value == 'rename') {
        if (mounted) {
          _showListEditDialog(list: list, renameOnly: true);
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSmartViewButton(
                        l10n.navToday,
                        Icons.today,
                        const Color(0xFF007AFF),
                        widget.todayCount ?? 0,
                        widget.onTodayTap,
                      ),
                      _buildSmartViewButton(
                        l10n.navPlanned,
                        Icons.calendar_month,
                        const Color(0xFFFF3B30),
                        widget.plannedCount ?? 0,
                        widget.onPlannedTap,
                      ),
                      _buildSmartViewButton(
                        l10n.navAll,
                        Icons.list,
                        const Color(0xFF8E8E93),
                        widget.allCount ?? 0,
                        widget.onAllTap,
                      ),
                      _buildSmartViewButton(
                        l10n.navCompleted,
                        Icons.check_circle,
                        const Color(0xFFFF9500),
                        widget.completedCount ?? 0,
                        widget.onCompletedTap,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.sectionMyLists,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 18,
                        onPressed: widget.isDatabaseConnected
                            ? () {
                                _showListEditDialog();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                ...widget.lists.map((list) {
                  final isSelected = widget.selectedList?.id == list.id;
                  final tileColor = list.color ?? Colors.blue;
                  final taskCount = widget.taskCounts?[list.id] ?? 0;

                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => widget.onSelectList(list),
                        onDoubleTap: () => _showListEditDialog(list: list),
                        onSecondaryTapDown: (details) => _showEditMenu(list, details.globalPosition),
                        onLongPress: () => _showEditMenu(list, Offset.zero),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            splashColor: tileColor.withOpacity(0.2),
                            highlightColor: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: tileColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: tileColor.withOpacity(0.3),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: list.icon != null
                                          ? Text(
                                              list.icon!,
                                              style: const TextStyle(fontSize: 18),
                                            )
                                          : const Icon(
                                              Icons.folder,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      list.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (taskCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        taskCount.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartViewButton(
    String label,
    IconData icon,
    Color color,
    int count,
    VoidCallback onTap,
  ) {
    final isEnabled = widget.isDatabaseConnected;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              left: 0,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 0,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
