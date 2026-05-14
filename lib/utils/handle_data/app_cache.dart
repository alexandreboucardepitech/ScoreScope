// lib/utils/app_cache.dart
//
// Cache mémoire (L1) — durée de vie = session utilisateur.
// Premier niveau consulté avant L2 (disque) et Firestore.
// Zéro dépendance externe.

import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';

class AppCache {
  AppCache._();

  static final Map<String, MatchModel> _matches = {};

  static MatchModel? getMatch(String id) {
    final match = _matches[id];
    if (match == null) return null;
    if (match.isLive) return null;
    if (match.isScheduled &&
        DateTime.now().isAfter(match.date.subtract(const Duration(hours: 1))))
      return null;
    return match;
  }

  static void setMatch(String id, MatchModel m) => _matches[id] = m;

  static void invalidateMatch(String id) => _matches.remove(id);

  static final Map<String, Joueur> _joueurs = {};
  static final Map<String, String> _joueurNames = {};

  static Joueur? getJoueur(String id) => _joueurs[id];
  static void setJoueur(String id, Joueur j) {
    _joueurs[id] = j;
    _joueurNames[id] = j.fullName;
  }

  static String? getJoueurName(String id) =>
      _joueurNames[id] ?? _joueurs[id]?.fullName;
  static void setJoueurName(String id, String name) => _joueurNames[id] = name;

  static final Map<String, Equipe> _equipes = {};

  static Equipe? getEquipe(String id) => _equipes[id];
  static void setEquipe(String id, Equipe e) => _equipes[id] = e;

  static final Map<String, Competition> _competitions = {};

  static Competition? getCompetition(String id) => _competitions[id];
  static void setCompetition(String id, Competition c) => _competitions[id] = c;

  static void clearAll() {
    _matches.clear();
    _joueurs.clear();
    _joueurNames.clear();
    _equipes.clear();
    _competitions.clear();
  }
}
