import 'package:flutter/material.dart';
import '../models/todo_list.dart';

class ListNavigation extends StatefulWidget {
  final List<TodoList> lists;
  final TodoList? selectedList;
  final Function(TodoList) onSelectList;
  final Function(String) onAddList;
  final VoidCallback onTodayTap;
  final VoidCallback onPlannedTap;
  final VoidCallback onAllTap;
  final VoidCallback onCompletedTap;

  const ListNavigation({
    super.key,
    required this.lists,
    required this.selectedList,
    required this.onSelectList,
    required this.onAddList,
    required this.onTodayTap,
    required this.onPlannedTap,
    required this.onAllTap,
    required this.onCompletedTap,
  });

  @override
  State<ListNavigation> createState() => _ListNavigationState();
}

class _ListNavigationState extends State<ListNavigation> {
  bool _isAddingList = false;
  final TextEditingController _newListController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Quick views
          Expanded(
            child: ListView(
              children: [
                // Quick view buttons in grid layout
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5, // 宽度是高度的1.5倍
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Today
                      GestureDetector(
                        onTap: widget.onTodayTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF), // iOS blue
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
                              // Icon and text on the left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.today,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '今天',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Number on the top right, aligned with icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: const Text(
                                  '0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Planned
                      GestureDetector(
                        onTap: widget.onPlannedTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30), // iOS red
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
                              // Icon and text on the left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '计划',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Number on the top right, aligned with icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // All
                      GestureDetector(
                        onTap: widget.onAllTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E8E93), // iOS gray
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
                              // Icon and text on the left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.list,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '全部',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Number on the top right, aligned with icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: const Text(
                                  '5',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Completed
                      GestureDetector(
                        onTap: widget.onCompletedTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500), // iOS orange
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
                              // Icon and text on the left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '已完成',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Number on the top right, aligned with icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: const Text(
                                  '0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Divider(),

                // Lists header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '任务列表',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 18,
                        onPressed: () {
                          setState(() {
                            _isAddingList = true;
                          });
                          _newListController.clear();
                        },
                      ),
                    ],
                  ),
                ),

                // Add list input
                if (_isAddingList)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newListController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: '输入列表名称',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                widget.onAddList(value.trim());
                                setState(() {
                                  _isAddingList = false;
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isAddingList = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Lists
                ...widget.lists.map((list) {
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(list.name),
                    selected: widget.selectedList?.id == list.id,
                    selectedColor: Colors.blue,
                    selectedTileColor: Colors.blue[50],
                    onTap: () => widget.onSelectList(list),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      iconSize: 18,
                      onPressed: () {
                        // Implement list actions (edit, delete)
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
