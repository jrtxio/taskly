import 'package:flutter/foundation.dart';

@immutable
class Task {
  final int id;
  final int listId;
  final String text;
  final String? dueDate;
  final bool completed;
  final String createdAt;
  final String? listName;

  const Task({
    required this.id,
    required this.listId,
    required this.text,
    this.dueDate,
    required this.completed,
    required this.createdAt,
    this.listName,
  });

  // Convert from map to Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      text: map['text'] as String,
      dueDate: map['due_date'] as String?,
      completed: (map['completed'] as int) == 1,
      createdAt: map['created_at'] as String,
      listName: map['list_name'] as String?,
    );
  }

  // Convert from Task to map
  Map<String, dynamic> toMap() {
    final map = {
      'list_id': listId,
      'text': text,
      'due_date': dueDate,
      'completed': completed ? 1 : 0,
      'created_at': createdAt,
    };

    // Only include id if it's not 0 (for updates, not inserts)
    if (id != 0) {
      map['id'] = id;
    }

    return map;
  }

  // Create a copy with updated values
  Task copyWith({
    int? id,
    int? listId,
    String? text,
    String? dueDate,
    bool? completed,
    String? createdAt,
    String? listName,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      text: text ?? this.text,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      listName: listName ?? this.listName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.listId == listId &&
        other.text == text &&
        other.dueDate == dueDate &&
        other.completed == completed &&
        other.createdAt == createdAt &&
        other.listName == listName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listId.hashCode ^
        text.hashCode ^
        dueDate.hashCode ^
        completed.hashCode ^
        createdAt.hashCode ^
        listName.hashCode;
  }

  @override
  String toString() {
    return 'Task(id: $id, listId: $listId, text: $text, dueDate: $dueDate, completed: $completed, createdAt: $createdAt, listName: $listName)';
  }
}
