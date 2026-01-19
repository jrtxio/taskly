import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class TodoList {
  final int id;
  final String name;
  final String? icon;
  final Color? color;

  const TodoList({required this.id, required this.name, this.icon, this.color});

  // Convert from map to TodoList
  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] != null ? Color(map['color'] as int) : null,
    );
  }

  // Convert from TodoList to map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon, 'color': color?.value};
  }

  // Create a copy with updated values
  TodoList copyWith({int? id, String? name, String? icon, Color? color}) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoList &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ icon.hashCode ^ color.hashCode;

  @override
  String toString() =>
      'TodoList(id: $id, name: $name, icon: $icon, color: $color)';
}
