import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/match_user_data.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? bio;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> equipesPrefereesId;
  final List<MatchUserData> matchsUserData;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.bio,
    this.photoUrl,
    required this.createdAt,
    this.equipesPrefereesId = const [],
    this.matchsUserData = const [],
  });

  factory AppUser.fromJson({
    required Map<String, dynamic> json,
    String? userId,
  }) {
    return AppUser(
      uid: userId ?? json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      equipesPrefereesId: (json['equipesPrefereesId'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      matchsUserData: json['matchsUserData'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'equipesPrefereesId': equipesPrefereesId,
      'matchsUserData': matchsUserData,
    };
  }
}
