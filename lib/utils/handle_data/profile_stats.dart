import 'package:scorescope/models/match_user_data.dart';

class ProfileStats {
  final int nbMatchsRegardes;

  final int nbButs;

  final List<String> matchsRegardesId;

  final List<String> matchsFavorisId;

  final List<MatchUserData> allMatchUserData;

  final Map<String, Map<String, dynamic>> matchesData;

  const ProfileStats({
    required this.nbMatchsRegardes,
    required this.nbButs,
    required this.matchsRegardesId,
    required this.matchsFavorisId,
    required this.allMatchUserData,
    required this.matchesData,
  });
}
