import 'package:intl/intl.dart';
import 'package:scorescope/models/match.dart';

String displayScoreOrMatchDate(MatchModel match) {
  final bool displayScore = match.isLive || match.isFinished;

  return displayScore
      ? '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}'
      : DateFormat('HH:mm').format(match.date);
}
