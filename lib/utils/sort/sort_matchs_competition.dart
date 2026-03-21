import 'package:scorescope/models/match.dart';

List<MatchModel> sortMatchsCompetition({
  required List<MatchModel> matchs,
  required bool triDate,
}) {
  final list = List<MatchModel>.from(matchs);

  if (triDate) {
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  list.sort((a, b) {
    int compPopularity =
        b.competition.popularite.compareTo(a.competition.popularite);
    if (compPopularity != 0) return compPopularity;

    int compName = a.competition.nom.compareTo(b.competition.nom);
    if (compName != 0) return compName;

    return a.date.compareTo(b.date);
  });

  return list;
}