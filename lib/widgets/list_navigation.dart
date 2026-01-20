import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_list.dart';
import '../providers/list_provider.dart';

class ListNavigation extends StatefulWidget {
  final List<TodoList> lists;
  final TodoList? selectedList;
  final Function(TodoList) onSelectList;
  final Function(String) onAddList;
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
  bool _isAddingList = false;
  final _newListController = TextEditingController();

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmDialog(TodoList list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除列表'),
          content: Text('确定要删除"${list.name}"吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteList(list.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void _handleAddList() {
    final name = _newListController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入列表名称')));
      return;
    }
    widget.onAddList(name);
    setState(() {
      _isAddingList = false;
      _newListController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSmartViewButton(
                        '今天',
                        Icons.today,
                        const Color(0xFF007AFF),
                        widget.todayCount ?? 0,
                        widget.onTodayTap,
                      ),
                      _buildSmartViewButton(
                        '计划',
                        Icons.calendar_month,
                        const Color(0xFFFF3B30),
                        widget.plannedCount ?? 0,
                        widget.onPlannedTap,
                      ),
                      _buildSmartViewButton(
                        '全部',
                        Icons.list,
                        const Color(0xFF8E8E93),
                        widget.allCount ?? 0,
                        widget.onAllTap,
                      ),
                      _buildSmartViewButton(
                        '已完成',
                        Icons.check_circle,
                        const Color(0xFFFF9500),
                        widget.completedCount ?? 0,
                        widget.onCompletedTap,
                      ),
                    ],
                  ),
                ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '我的列表',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 18,
                        onPressed: widget.isDatabaseConnected
                            ? () {
                                setState(() {
                                  _isAddingList = true;
                                });
                                _newListController.clear();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                if (_isAddingList)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.folder,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _newListController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: '输入列表名称',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              isDense: true,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 14),
                            onSubmitted: (value) => _handleAddList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          iconSize: 18,
                          onPressed: () {
                            setState(() {
                              _isAddingList = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                ...widget.lists.map((list) {
                  final isSelected = widget.selectedList?.id == list.id;
                  final tileColor = list.color ?? Colors.blue;

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
                        color: isSelected ? Colors.grey[100] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border(
                                left: BorderSide(color: tileColor, width: 3),
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => widget.onSelectList(list),
                        onSecondaryTap: () => _showDeleteConfirmDialog(list),
                        borderRadius: BorderRadius.circular(10),
                        splashColor: tileColor.withOpacity(0.2),
                        highlightColor: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
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
                                child: Icon(
                                  list.icon != null
                                      ? IconData(
                                          int.parse(list.icon!),
                                          fontFamily: 'MaterialIcons',
                                        )
                                      : Icons.folder,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  list.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
