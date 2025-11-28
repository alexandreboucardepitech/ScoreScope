import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';

class MatchRegardeAmi {
  final AppUser friend;
  final MatchUserData matchData;
  final MatchModel? match;
  final DateTime? eventDate;
  final String? mvpName;

  MatchRegardeAmi({
    required this.friend,
    required this.matchData,
    required this.match,
    required this.eventDate,
    required this.mvpName,
  });
}