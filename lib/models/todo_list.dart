import 'package:flutter/foundation.dart';

@immutable
class TodoList {
  final int id;
  final String name;

  const TodoList({
    required this.id,
    required this.name,
  });

  // Convert from map to TodoList
  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  // Convert from TodoList to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a copy with updated values
  TodoList copyWith({
    int? id,
    String? name,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoList && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TodoList(id: $id, name: $name)';
}