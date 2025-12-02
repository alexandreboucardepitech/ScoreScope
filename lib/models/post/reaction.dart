import 'package:cloud_firestore/cloud_firestore.dart';

class Reaction {
  final String id;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json, String? id) {
    final created = json['createdAt'];
    DateTime createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }

    final resolvedId = id ?? (json['id'] as String?) ?? '';

    return Reaction(
      id: resolvedId,
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
