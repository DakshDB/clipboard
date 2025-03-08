import 'package:cloud_firestore/cloud_firestore.dart';

class Clip {
  final String id;
  final String content;
  final Timestamp createdAt;
  final Timestamp? deletedAt;

  Clip({
    required this.id,
    required this.content,
    required this.createdAt,
    this.deletedAt,
  });

  factory Clip.fromFirestore(String id, Map<String, dynamic> data) {
    return Clip(
      id: id,
      content: data['clip'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clip': content,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }
}