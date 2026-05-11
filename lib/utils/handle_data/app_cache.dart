// Cache mémoire global (durée de vie : session utilisateur).
// Évite les double-fetches Firestore pour les données rarement modifiées.

import 'package:scorescope/models/match.dart';

class AppCache {
  AppCache._();

  static final Map<String, MatchModel> _matches = {};

  static MatchModel? getMatch(String id) => _matches[id];

  static void setMatch(String id, MatchModel match) => _matches[id] = match;

  static final Map<String, String> _joueurNames = {};

  static String? getJoueurName(String id) => _joueurNames[id];

  static void setJoueurName(String id, String name) => _joueurNames[id] = name;

  static void clearAll() {
    _matches.clear();
    _joueurNames.clear();
  }
}
