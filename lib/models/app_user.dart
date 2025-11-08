import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/equipe.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final List<Equipe?> equipePreferees;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.equipePreferees = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      equipePreferees: (json['equipePreferees'] as List?)
              ?.map((e) => e != null ? Equipe.fromJson(e as Map<String, dynamic>) : null)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'equipePreferees': equipePreferees
          .map((e) => e?.toJson())
          .toList(),
    };
  }
}