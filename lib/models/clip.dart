import 'package:cloud_firestore/cloud_firestore.dart';

class Clip {
  final String id;
  final String content;
  final Timestamp createdAt;
  final Timestamp? deletedAt;
  final List<String> tags;
  final String? groupId;

  Clip({
    required this.id,
    required this.content,
    required this.createdAt,
    this.deletedAt,
    this.tags = const [],
    this.groupId,
  });

  factory Clip.fromFirestore(String id, Map<String, dynamic> data) {
    return Clip(
      id: id,
      content: data['clip'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      tags: List<String>.from(data['tags'] ?? []),
      groupId: data['group_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clip': content,
      'created_at': createdAt,
      'deleted_at': deletedAt,
      'tags': tags,
      'group_id': groupId,
    };
  }
}