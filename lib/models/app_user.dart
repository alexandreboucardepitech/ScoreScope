import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/match.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? bio;
  final String? photoUrl;
  final DateTime createdAt;
  final bool private;
  final List<String> equipesPrefereesId;
  final List<String> competitionsPrefereesId;
  final List<MatchUserData> matchsUserData;

  AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.bio,
    this.photoUrl,
    required this.createdAt,
    this.private = false,
    this.equipesPrefereesId = const [],
    this.competitionsPrefereesId = const [],
    this.matchsUserData = const [],
  });

  MatchUserData? getMatchUserDataByMatch({MatchModel? match, String? matchId}) {
    for (MatchUserData matchData in matchsUserData) {
      if (matchData.matchId == matchId ||
          (match != null && matchData.matchId == match.id)) {
        return matchData;
      }
    }
    return null;
  }

  factory AppUser.fromJson({
    required Map<String, dynamic> json,
    String? userId,
  }) {
    return AppUser(
      uid: userId ?? json['uid'] as String,
      displayName: json['displayName'],
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photoUrl'] as String?,
      private: json['private'] as bool? ?? false,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      equipesPrefereesId: (json['equipesPrefereesId'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      competitionsPrefereesId:
          (json['competitionsPrefereesId'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      matchsUserData: (json['matchsUserData'] as List<dynamic>?)
              ?.map((e) => MatchUserData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'private': private,
      'createdAt': createdAt,
      'equipesPrefereesId': equipesPrefereesId,
      'competitionsPrefereesId': competitionsPrefereesId,
      'matchsUserData': matchsUserData,
    };
  }
}
