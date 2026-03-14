import 'package:intl/intl.dart';
import 'package:scorescope/models/match.dart';

String displayScoreOrMatchDate(MatchModel match) {
  final bool displayScore =
      match.status == MatchStatus.live || match.status == MatchStatus.finished;

  return displayScore
      ? '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}'
      : DateFormat('HH:mm').format(match.date);
}
