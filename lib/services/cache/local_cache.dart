import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';

// "d" = données de l'objet
// "t" = date/heure du fetch Firestore (pour calculer le TTL)

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime fetchedAt;

  _CacheEntry({required this.data, required this.fetchedAt});

  bool isExpired(Duration ttl) => DateTime.now().difference(fetchedAt) > ttl;

  String encode() {
    return jsonEncode({
      'd': _sanitize(data),
      't': fetchedAt.toIso8601String(),
    });
  }

  static dynamic _sanitize(dynamic value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitize(v)));
    }
    if (value is List) return value.map(_sanitize).toList();
    return value;
  }

  static _CacheEntry? decode(Object? raw) {
    if (raw == null || raw is! String) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _CacheEntry(
        data: Map<String, dynamic>.from(map['d'] as Map),
        fetchedAt: DateTime.parse(map['t'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

class LocalCache {
  LocalCache._();

  static late Box _competitions;
  static late Box _equipes;
  static late Box _joueurs;
  static late Box _matchs;

  static const Duration _ttlCompetition = Duration(days: 7);
  static const Duration _ttlEquipe = Duration(days: 7);
  static const Duration _ttlJoueur = Duration(days: 3);

  static Future<void> init() async {
    await Hive.initFlutter();
    _competitions = await Hive.openBox('ss_competitions');
    _equipes = await Hive.openBox('ss_equipes');
    _joueurs = await Hive.openBox('ss_joueurs');
    _matchs = await Hive.openBox('ss_matchs');
  }

  static Competition? getCompetition(String id) {
    final entry = _CacheEntry.decode(_competitions.get(id));
    if (entry == null || entry.isExpired(_ttlCompetition)) return null;
    try {
      return Competition.fromJson(json: entry.data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setCompetition(String id, Competition c) =>
      _competitions.put(
        id,
        _CacheEntry(data: c.toJson(), fetchedAt: DateTime.now()).encode(),
      );

  static Equipe? getEquipe(String id) {
    final entry = _CacheEntry.decode(_equipes.get(id));
    if (entry == null || entry.isExpired(_ttlEquipe)) return null;
    try {
      return Equipe.fromJson(json: entry.data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setEquipe(String id, Equipe e) => _equipes.put(
        id,
        _CacheEntry(data: e.toJson(), fetchedAt: DateTime.now()).encode(),
      );

  static Joueur? getJoueur(String id) {
    final entry = _CacheEntry.decode(_joueurs.get(id));
    if (entry == null || entry.isExpired(_ttlJoueur)) return null;
    try {
      return Joueur.fromJson(json: entry.data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setJoueur(String id, Joueur j) => _joueurs.put(
        id,
        _CacheEntry(data: j.toJson(), fetchedAt: DateTime.now()).encode(),
      );

  static MatchModel? getMatch(String id) {
    final entry = _CacheEntry.decode(_matchs.get(id));
    if (entry == null) return null;
    try {
      final match = MatchModel.fromCacheJson(entry.data);
      if (match.isLive) return null;
      if (match.isScheduled &&
          DateTime.now().isAfter(match.date.subtract(const Duration(hours: 1))))
        return null;
      if (entry.isExpired(_matchTtl(match.date))) return null;
      return match;
    } catch (_) {
      return null;
    }
  }

  static Duration _matchTtl(DateTime matchDate) {
    final matchFrozenAt = matchDate.add(const Duration(hours: 3));
    if (DateTime.now().isAfter(matchFrozenAt)) {
      return const Duration(days: 7);
    }
    return const Duration(minutes: 10);
  }

  static Future<void> setMatch(String id, MatchModel m) => _matchs.put(
        id,
        _CacheEntry(data: m.toCacheJson(), fetchedAt: DateTime.now()).encode(),
      );

  static Future<void> invalidateMatch(String id) => _matchs.delete(id);

  static Future<void> clearAll() => Future.wait([
        _competitions.clear(),
        _equipes.clear(),
        _joueurs.clear(),
        _matchs.clear(),
      ]);
}
