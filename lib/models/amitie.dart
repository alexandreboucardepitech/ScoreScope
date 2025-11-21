import 'package:cloud_firestore/cloud_firestore.dart';

class Amitie {
  final String firstUserId;
  final String secondUserId;
  final String status;
  final DateTime createdAt;

  Amitie({
    required this.firstUserId,
    required this.secondUserId,
    this.status = "pending",
    required this.createdAt,
  });

  factory Amitie.fromJson({
    required Map<String, dynamic> json,
    String? userId,
  }) {
    return Amitie(
      firstUserId: userId ?? json['firstUserId'] as String,
      secondUserId: userId ?? json['secondUserId'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstUserId': firstUserId,
      'secondUserId': secondUserId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  Amitie copyWith({
    String? firstUserId,
    String? secondUserId,
    String? status,
    DateTime? createdAt,
  }) {
    return Amitie(
      firstUserId: firstUserId ?? this.firstUserId,
      secondUserId: secondUserId ?? this.secondUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
