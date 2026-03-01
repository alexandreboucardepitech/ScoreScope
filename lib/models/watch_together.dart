import 'package:cloud_firestore/cloud_firestore.dart';

class WatchTogether {
  String matchId;
  String ownerId;
  String friendId;
  String status;
  DateTime createdAt;

  WatchTogether({
    required this.matchId,
    required this.ownerId,
    required this.friendId,
    this.status = "pending",
    required this.createdAt,
  });

  factory WatchTogether.fromJson(Map<String, dynamic> json) {
    return WatchTogether(
      matchId: json['matchId'] as String,
      ownerId: json['ownerId'] as String,
      friendId: json['friendId'] as String,
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
      'matchId': matchId,
      'ownerId': ownerId,
      'friendId': friendId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
