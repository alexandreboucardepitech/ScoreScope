import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/utils/string/get_pos_from_string.dart';

List<MatchJoueur> getJoueursTriesParNombreDeVotes(
    List<MatchJoueur> joueurs, MatchModel match) {
  List<MatchJoueur> newList = List<MatchJoueur>.from(joueurs);
  newList.removeWhere((player) => player.hasPlayed == false);
  newList.sort((a, b) {
    // tri par nombre de votes
    if ((a.joueur != null ? match.getNbVotesById(a.joueur!.id) : 0) >
        (b.joueur != null ? match.getNbVotesById(b.joueur!.id) : 0)) {
      return -1;
    }
    if ((b.joueur != null ? match.getNbVotesById(b.joueur!.id) : 0) >
        (a.joueur != null ? match.getNbVotesById(a.joueur!.id) : 0)) {
      return 1;
    }

    // tri par nombre de G+A
    if ((a.joueur != null
            ? match.getPlayerNbButs(a.joueur!.id) +
                match.getPlayerNbPassesDe(a.joueur!.id)
            : 0) >
        (b.joueur != null
            ? match.getPlayerNbButs(b.joueur!.id) +
                match.getPlayerNbPassesDe(b.joueur!.id)
            : 0)) {
      return -1;
    }
    if ((b.joueur != null
            ? match.getPlayerNbButs(b.joueur!.id) +
                match.getPlayerNbPassesDe(b.joueur!.id)
            : 0) >
        (a.joueur != null
            ? match.getPlayerNbButs(a.joueur!.id) +
                match.getPlayerNbPassesDe(a.joueur!.id)
            : 0)) {
      return 1;
    }

    // tri par nombre de buts
    if ((a.joueur != null ? match.getPlayerNbButs(a.joueur!.id) : 0) >
        (b.joueur != null ? match.getPlayerNbButs(b.joueur!.id) : 0)) {
      return -1;
    }
    if ((b.joueur != null ? match.getPlayerNbButs(b.joueur!.id) : 0) >
        (a.joueur != null ? match.getPlayerNbButs(a.joueur!.id) : 0)) {
      return 1;
    }

    // tri par nombre de passes dé
    if ((a.joueur != null ? match.getPlayerNbPassesDe(a.joueur!.id) : 0) >
        (b.joueur != null ? match.getPlayerNbPassesDe(b.joueur!.id) : 0)) {
      return -1;
    }
    if ((b.joueur != null ? match.getPlayerNbPassesDe(b.joueur!.id) : 0) >
        (a.joueur != null ? match.getPlayerNbPassesDe(a.joueur!.id) : 0)) {
      return 1;
    }

    // si pas de grid on fait avec la pos
    if (a.grid == null || b.grid == null) {
      if (b.pos == null) {
        return -1;
      }
      if (a.pos == null) {
        return 1;
      }
      final positions = ["G", "D", "M", "A"];
      if (positions.indexOf(a.pos!) < positions.indexOf(b.pos!)) {
        return -1;
      }
      if (positions.indexOf(b.pos!) < positions.indexOf(a.pos!)) {
        return 1;
      }
    }

    // tri par grid principale
    if (a.grid != null && b.grid != null) {
      if (getPosFromString(a.grid!, true) > getPosFromString(b.grid!, true)) {
        return 1;
      }
      if (getPosFromString(b.grid!, true) > getPosFromString(a.grid!, true)) {
        return -1;
      }

      // tri par grid secondaire
      if (getPosFromString(a.grid!, false) > getPosFromString(b.grid!, false)) {
        return 1;
      }
      if (getPosFromString(b.grid!, false) > getPosFromString(a.grid!, false)) {
        return -1;
      }
    }

    return -1; // par défaut
  });
  return newList;
}
