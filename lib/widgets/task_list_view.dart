import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/task.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final bool isLoading;
  final Function(int) onToggleTask;
  final Function(Task) onEditTask;
  final Function(int) onDeleteTask;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return const Center(
        child: Text('暂无任务', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onToggle: () => onToggleTask(task.id),
          onEdit: () => onEditTask(task),
          onDelete: () => onDeleteTask(task.id),
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
          leading: Checkbox(
            value: task.completed,
            onChanged: (value) => onToggle(),
            shape: const CircleBorder(),
          ),
          title: Text(
            task.text,
            style: TextStyle(
              decoration: task.completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.completed ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  task.dueDate!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              : null,
          trailing: task.listName != null
              ? Chip(
                  label: Text(task.listName!),
                  labelStyle: const TextStyle(fontSize: 12),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                )
              : null,
          onTap: onToggle,
        ),
      ),
    );
  }
}
