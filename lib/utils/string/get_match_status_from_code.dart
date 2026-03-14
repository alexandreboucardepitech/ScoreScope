import 'package:scorescope/models/match.dart';

MatchStatus getMatchStatusFromCode(String code) {
  switch (code) {
    case "FT":
    case "AET":
    case "PEN":
      return MatchStatus.finished;
    case "1H":
    case "HT":
    case "2H":
    case "ET":
    case "BT":
    case "P":
    case "SUSP":
    case "INT":
    case "LIVE":
      return MatchStatus.live;
    case "PST":
      return MatchStatus.postponed;
    case "NS":
    case "TBD":
    default:
      return MatchStatus.scheduled;
  }
}
