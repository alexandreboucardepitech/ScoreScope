import 'package:cloud_firestore/cloud_firestore.dart';

class Commentaire {
  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;

  Commentaire({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory Commentaire.fromJson(Map<String, dynamic> json, String? id) {
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

    return Commentaire(
      id: resolvedId,
      authorId: json['authorId'] as String,
      text: json['text'] as String,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
