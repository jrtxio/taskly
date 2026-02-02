import 'package:flutter/foundation.dart';

@immutable
class Task {
  static const _sentinel = Object();

  final int id;
  final int listId;
  final String text;
  final String? dueDate;
  final String? dueTime;
  final bool completed;
  final String createdAt;
  final String? notes;

  const Task({
    required this.id,
    required this.listId,
    required this.text,
    this.dueDate,
    this.dueTime,
    required this.completed,
    required this.createdAt,
    this.notes,
  });

  // Convert from map to Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      text: map['text'] as String,
      dueDate: map['due_date'] as String?,
      dueTime: map['due_time'] as String?,
      completed: (map['completed'] as int) == 1,
      createdAt: map['created_at'] as String,
      notes: map['notes'] as String?,
    );
  }

  // Convert from Task to map
  Map<String, dynamic> toMap() {
    final map = {
      'list_id': listId,
      'text': text,
      'due_date': dueDate,
      'due_time': dueTime,
      'completed': completed ? 1 : 0,
      'created_at': createdAt,
      'notes': notes,
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
    Object? dueDate = _sentinel,
    Object? dueTime = _sentinel,
    bool? completed,
    String? createdAt,
    Object? notes = _sentinel,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      text: text ?? this.text,
      dueDate: dueDate == _sentinel ? this.dueDate : dueDate as String?,
      dueTime: dueTime == _sentinel ? this.dueTime : dueTime as String?,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      notes: notes == _sentinel ? this.notes : notes as String?,
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
        other.dueTime == dueTime &&
        other.completed == completed &&
        other.createdAt == createdAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listId.hashCode ^
        text.hashCode ^
        dueDate.hashCode ^
        dueTime.hashCode ^
        completed.hashCode ^
        createdAt.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'Task(id: $id, listId: $listId, text: $text, dueDate: $dueDate, dueTime: $dueTime, completed: $completed, createdAt: $createdAt, notes: $notes)';
  }
}
