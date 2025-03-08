import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final Timestamp createdAt;
  final String? description;

  Group({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
  });

  factory Group.fromFirestore(String id, Map<String, dynamic> data) {
    return Group(
      id: id,
      name: data['name'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      description: data['description'],
    );
  }

  Group copyWith({
    String? name,
    String? description,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'created_at': createdAt,
      'description': description,
    };
  }
}