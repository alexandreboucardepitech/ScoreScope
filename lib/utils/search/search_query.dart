import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/cache/local_cache.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/app_cache.dart';
import 'package:scorescope/utils/search/search_page_state.dart';
import 'package:scorescope/utils/string/string_helper.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

List<Equipe> _filterEquipes(Iterable<Equipe> source, String q) {
  final seen = <String>{};
  final startsWith = <Equipe>[];
  final contains = <Equipe>[];

  for (final e in source) {
    if (seen.contains(e.id)) continue;
    final nom = normalize(e.nom.toLowerCase());
    final nomCourt = normalize((e.nomCourt ?? '').toLowerCase());
    final code = normalize((e.code ?? '').toLowerCase());

    if (nom.startsWith(q) || nomCourt.startsWith(q) || code.startsWith(q)) {
      startsWith.add(e);
      seen.add(e.id);
    } else if (nom.contains(q) || nomCourt.contains(q) || code.contains(q)) {
      contains.add(e);
      seen.add(e.id);
    }
  }

  return [...startsWith, ...contains];
}

List<Joueur> _filterJoueurs(Iterable<Joueur> source, String q) {
  final seen = <String>{};
  final startsWith = <Joueur>[];
  final contains = <Joueur>[];

  for (final j in source) {
    if (seen.contains(j.id)) continue;
    final prenom = normalize(j.prenom.toLowerCase());
    final nom = normalize(j.nom.toLowerCase());
    final fullName = normalize(j.fullName.toLowerCase());

    if (prenom.startsWith(q) || nom.startsWith(q) || fullName.startsWith(q)) {
      startsWith.add(j);
      seen.add(j.id);
    } else if (prenom.contains(q) || nom.contains(q) || fullName.contains(q)) {
      contains.add(j);
      seen.add(j.id);
    }
  }

  return [...startsWith, ...contains];
}

List<Competition> _filterCompetitions(Iterable<Competition> source, String q) {
  final seen = <String>{};
  final startsWith = <Competition>[];
  final contains = <Competition>[];

  for (final c in source) {
    if (seen.contains(c.id)) continue;
    final nom = normalize(c.nom.toLowerCase());

    if (nom.startsWith(q)) {
      startsWith.add(c);
      seen.add(c.id);
    } else if (nom.contains(q)) {
      contains.add(c);
      seen.add(c.id);
    }
  }

  return [...startsWith, ...contains];
}

ResultatsRechercheModel searchCacheOnlyQuery(
  String query, {
  String? filter,
}) {
  if (filter == null) {
    filter = translate.tous;
  }
  if (query.length < 3) return const ResultatsRechercheModel();

  final q = normalize(query.toLowerCase());

  List<Equipe> equipes = [];
  List<Joueur> joueurs = [];
  List<Competition> competitions = [];
  List<MatchModel> matchs = [];

  if (filter == translate.tous ||
      filter == translate.equipes ||
      filter == translate.matchs) {
    equipes = _filterEquipes(AppCache.allEquipes, q);
  }

  if (filter == translate.tous || filter == translate.competitions) {
    competitions = _filterCompetitions(AppCache.allCompetitions, q);
    competitions.sort((a, b) => b.popularite - a.popularite);
  }

  if (filter == translate.tous || filter == translate.joueurs) {
    joueurs = _filterJoueurs(AppCache.allJoueurs, q);
    joueurs.sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  if ((filter == translate.tous || filter == translate.matchs) &&
      equipes.isNotEmpty) {
    final equipeIds = equipes.map((e) => e.id).toSet();
    matchs = AppCache.allMatches
        .where((m) =>
            equipeIds.contains(m.equipeDomicile.id) ||
            equipeIds.contains(m.equipeExterieur.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (filter == translate.matchs) equipes = [];
  }

  return ResultatsRechercheModel(
    matchs: matchs,
    equipes: equipes,
    competitions: competitions,
    joueurs: joueurs,
  );
}

const int _kLimitEquipes = 15;
const int _kLimitNomCourt = 10;
const int _kLimitJoueurs = 15;
const int _kLimitCompetitions = 10;
const int _kLimitMatchs = 10;

const int _scoreExact = 3;
const int _scoreStartsWith = 2;
const int _scoreFirestore = 1;
const int _scoreNone = 0;

class _Bipartition {
  final List<Equipe> leftTeams;
  final List<Equipe> rightTeams;
  final int score;
  _Bipartition({
    required this.leftTeams,
    required this.rightTeams,
    required this.score,
  });
}

Future<(List<Equipe>, int)> _findTeams(
  String partQuery,
  List<Equipe> l2Cache,
  FirebaseFirestore db,
) async {
  if (partQuery.length < 3) return (<Equipe>[], _scoreNone);

  final q = normalize(partQuery.toLowerCase());

  final l1 = _filterEquipes(AppCache.allEquipes, q);
  if (l1.isNotEmpty) {
    final hasExact = l1.any((e) {
      final nom = normalize(e.nom.toLowerCase());
      final court = normalize((e.nomCourt ?? '').toLowerCase());
      return nom == q || court == q;
    });
    return (l1, hasExact ? _scoreExact : _scoreStartsWith);
  }

  final l2 = _filterEquipes(l2Cache, q);
  if (l2.isNotEmpty) return (l2, _scoreStartsWith);

  try {
    final t = partQuery.trim();
    final fsQ =
        t.isEmpty ? t : t[0].toUpperCase() + t.substring(1).toLowerCase();
    final fsEnd = fsQ + '\uf8ff';

    final snaps = await Future.wait([
      db
          .collection('equipes')
          .where('nom', isGreaterThanOrEqualTo: fsQ)
          .where('nom', isLessThan: fsEnd)
          .limit(5)
          .get(),
      db
          .collection('equipes')
          .where('nomCourt', isGreaterThanOrEqualTo: fsQ)
          .where('nomCourt', isLessThan: fsEnd)
          .limit(5)
          .get(),
    ]);

    final found = <Equipe>[];
    final seen = <String>{};
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        if (seen.contains(doc.id)) continue;
        try {
          final equipe = Equipe.fromJson(json: doc.data());
          found.add(equipe);
          seen.add(doc.id);
          AppCache.setEquipe(doc.id, equipe);
          unawaited(LocalCache.setEquipe(doc.id, equipe));
        } catch (_) {}
      }
    }

    if (found.isNotEmpty) return (found, _scoreFirestore);
  } catch (_) {}

  return (<Equipe>[], _scoreNone);
}

Future<List<MatchModel>> _searchMatchPair(
  String query,
  FirebaseFirestore db,
) async {
  final words =
      query.trim().toLowerCase().split(' ').where((w) => w.isNotEmpty).toList();

  if (words.length < 2) return [];

  final l2Cache = LocalCache.getAllEquipes();
  _Bipartition? best;

  for (int i = 1; i < words.length; i++) {
    final leftQ = words.sublist(0, i).join(' ');
    final rightQ = words.sublist(i).join(' ');

    if (leftQ.length < 3 || rightQ.length < 3) continue;

    final results = await Future.wait([
      _findTeams(leftQ, l2Cache, db),
      _findTeams(rightQ, l2Cache, db),
    ]);

    final leftTeams = results[0].$1;
    final leftScore = results[0].$2;
    final rightTeams = results[1].$1;
    final rightScore = results[1].$2;

    if (leftTeams.isEmpty || rightTeams.isEmpty) continue;

    final leftIds = leftTeams.map((e) => e.id).toSet();
    final rightIds = rightTeams.map((e) => e.id).toSet();
    if (leftIds.intersection(rightIds).isNotEmpty) continue;

    final score = leftScore + rightScore;
    if (best == null || score > best.score) {
      best = _Bipartition(
        leftTeams: leftTeams.take(5).toList(),
        rightTeams: rightTeams.take(5).toList(),
        score: score,
      );
    }
  }

  if (best == null) return [];

  final leftIds = best.leftTeams.map((e) => e.id).toList();
  final rightIds = best.rightTeams.map((e) => e.id).toList();

  try {
    final queries = [
      ...leftIds.map(
        (leftId) => db
            .collection('matchs')
            .where('equipeDomicileId', isEqualTo: leftId)
            .where('equipeExterieurId', whereIn: rightIds)
            .orderBy('date', descending: true)
            .get(),
      ),
      ...rightIds.map(
        (rightId) => db
            .collection('matchs')
            .where('equipeDomicileId', isEqualTo: rightId)
            .where('equipeExterieurId', whereIn: leftIds)
            .orderBy('date', descending: true)
            .get(),
      ),
    ];

    final snaps = await Future.wait(queries);

    final directIds = <String>{};
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        directIds.add(doc.id);
      }
    }

    if (directIds.isEmpty) return [];

    final matchResults = await Future.wait(
      directIds
          .map((id) => RepositoryProvider.matchRepository.fetchMatchById(id)),
    );

    final found = matchResults.whereType<MatchModel>().toList();
    found.sort((a, b) => b.date.compareTo(a.date));
    return found;
  } catch (e) {
    print('searchMatchPair error: $e');
  }

  return [];
}

String _buildFsQuery(String query) {
  final t = query.trim();
  if (t.isEmpty) return t;
  return t[0].toUpperCase() + t.substring(1).toLowerCase();
}

Future<(ResultatsRechercheModel, SearchPageState)> searchQuery(
  String query, {
  String? filter,
}) async {
  if (filter == null) {
    filter = translate.tous;
  }
  if (query.length < 3) {
    return (const ResultatsRechercheModel(), SearchPageState.empty);
  }

  final q = normalize(query.toLowerCase());
  final fsQuery = _buildFsQuery(query);
  final fsEnd = fsQuery + '\uf8ff';
  final db = FirebaseFirestore.instance;

  List<Equipe> equipes = [];
  List<Joueur> joueurs = [];
  List<Competition> competitions = [];
  List<MatchModel> matchs = [];

  String? lastEquipeNom;
  String? lastJoueurNom;
  String? lastCompetitionNom;
  DateTime? lastMatchDate;
  bool hasMoreEquipes = false;
  bool hasMoreJoueurs = false;
  bool hasMoreCompetitions = false;
  bool hasMoreMatchs = false;

  Future<void> fetchEquipes() async {
    equipes = _filterEquipes(AppCache.allEquipes, q);
    final seenIds = equipes.map((e) => e.id).toSet();

    final l2 = _filterEquipes(
      LocalCache.getAllEquipes().where((e) => !seenIds.contains(e.id)),
      q,
    );
    equipes = [...equipes, ...l2];
    seenIds.addAll(l2.map((e) => e.id));

    try {
      final snaps = await Future.wait([
        db
            .collection('equipes')
            .where('nom', isGreaterThanOrEqualTo: fsQuery)
            .where('nom', isLessThan: fsEnd)
            .orderBy('nom')
            .limit(_kLimitEquipes)
            .get(),
        db
            .collection('equipes')
            .where('nomCourt', isGreaterThanOrEqualTo: fsQuery)
            .where('nomCourt', isLessThan: fsEnd)
            .limit(_kLimitNomCourt)
            .get(),
      ]);

      for (final snap in snaps) {
        for (final doc in snap.docs) {
          if (seenIds.contains(doc.id)) continue;
          try {
            final equipe = Equipe.fromJson(json: doc.data());
            equipes.add(equipe);
            seenIds.add(doc.id);
            AppCache.setEquipe(doc.id, equipe);
            unawaited(LocalCache.setEquipe(doc.id, equipe));
          } catch (_) {}
        }
      }

      if (snaps[0].docs.isNotEmpty) {
        lastEquipeNom = snaps[0].docs.last.data()['nom'] as String?;
      }
      hasMoreEquipes = snaps[0].docs.length >= _kLimitEquipes ||
          snaps[1].docs.length >= _kLimitNomCourt;
    } catch (_) {}
  }

  Future<void> fetchCompetitions() async {
    competitions = _filterCompetitions(AppCache.allCompetitions, q);
    final seenIds = competitions.map((c) => c.id).toSet();

    final l2 = _filterCompetitions(
      LocalCache.getAllCompetitions().where((c) => !seenIds.contains(c.id)),
      q,
    );
    competitions = [...competitions, ...l2];
    seenIds.addAll(l2.map((c) => c.id));

    try {
      final snap = await db
          .collection('competitions')
          .where('nom', isGreaterThanOrEqualTo: fsQuery)
          .where('nom', isLessThan: fsEnd)
          .orderBy('nom')
          .limit(_kLimitCompetitions)
          .get();

      for (final doc in snap.docs) {
        if (seenIds.contains(doc.id)) continue;
        try {
          final comp = Competition.fromJson(json: doc.data());
          competitions.add(comp);
          seenIds.add(doc.id);
          AppCache.setCompetition(doc.id, comp);
          unawaited(LocalCache.setCompetition(doc.id, comp));
        } catch (_) {}
      }

      if (snap.docs.isNotEmpty) {
        lastCompetitionNom = snap.docs.last.data()['nom'] as String?;
      }
      hasMoreCompetitions = snap.docs.length >= _kLimitCompetitions;
    } catch (_) {}

    competitions.sort((a, b) => b.popularite - a.popularite);
  }

  Future<void> fetchJoueurs() async {
    joueurs = _filterJoueurs(AppCache.allJoueurs, q);
    final seenIds = joueurs.map((j) => j.id).toSet();

    final l2 = _filterJoueurs(
      LocalCache.getAllJoueurs().where((j) => !seenIds.contains(j.id)),
      q,
    );
    joueurs = [...joueurs, ...l2];
    seenIds.addAll(l2.map((j) => j.id));

    try {
      final snaps = await Future.wait([
        db
            .collection('joueurs')
            .where('prenom', isGreaterThanOrEqualTo: fsQuery)
            .where('prenom', isLessThan: fsEnd)
            .limit(_kLimitJoueurs)
            .get(),
        db
            .collection('joueurs')
            .where('nom', isGreaterThanOrEqualTo: fsQuery)
            .where('nom', isLessThan: fsEnd)
            .orderBy('nom')
            .limit(_kLimitJoueurs)
            .get(),
      ]);

      for (final snap in snaps) {
        for (final doc in snap.docs) {
          if (seenIds.contains(doc.id)) continue;
          try {
            final joueur = Joueur.fromJson(json: doc.data());
            joueurs.add(joueur);
            seenIds.add(doc.id);
            AppCache.setJoueur(doc.id, joueur);
            unawaited(LocalCache.setJoueur(doc.id, joueur));
          } catch (_) {}
        }
      }

      if (snaps[1].docs.isNotEmpty) {
        lastJoueurNom = snaps[1].docs.last.data()['nom'] as String?;
      }
      hasMoreJoueurs = snaps[0].docs.length >= _kLimitJoueurs ||
          snaps[1].docs.length >= _kLimitJoueurs;
    } catch (_) {}

    joueurs.sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  await Future.wait([
    if (filter == translate.tous ||
        filter == translate.equipes ||
        filter == translate.matchs)
      fetchEquipes(),
    if (filter == translate.tous || filter == translate.competitions)
      fetchCompetitions(),
    if (filter == translate.tous || filter == translate.joueurs) fetchJoueurs(),
  ]);

  final List<String> matchEquipeIds =
      equipes.take(15).map((e) => e.id).toList();

  if ((filter == translate.tous || filter == translate.matchs) &&
      equipes.isNotEmpty) {
    try {
      final snaps = await Future.wait([
        db
            .collection('matchs')
            .where('equipeDomicileId', whereIn: matchEquipeIds)
            .orderBy('date', descending: true)
            .limit(_kLimitMatchs)
            .get(),
        db
            .collection('matchs')
            .where('equipeExterieurId', whereIn: matchEquipeIds)
            .orderBy('date', descending: true)
            .limit(_kLimitMatchs)
            .get(),
      ]);

      final seenMatchIds = <String>{};
      for (final snap in snaps) {
        for (final doc in snap.docs) {
          seenMatchIds.add(doc.id);
        }
      }

      final results = await Future.wait(
        seenMatchIds.map(
          (id) => RepositoryProvider.matchRepository.fetchMatchById(id),
        ),
      );

      for (final match in results) {
        if (match != null) matchs.add(match);
      }

      matchs.sort((a, b) => b.date.compareTo(a.date));

      if (matchs.isNotEmpty) lastMatchDate = matchs.last.date;
      hasMoreMatchs = seenMatchIds.length >= _kLimitMatchs;
    } catch (_) {}
  }

  if (query.contains(' ') &&
      (filter == translate.tous || filter == translate.matchs)) {
    final pairMatchs = await _searchMatchPair(query, db);
    if (pairMatchs.isNotEmpty) {
      final existingIds = matchs.map((m) => m.id).toSet();
      final newPairMatchs =
          pairMatchs.where((m) => !existingIds.contains(m.id)).toList();
      matchs = [...newPairMatchs, ...matchs];
    }
  }

  if (filter == translate.matchs) equipes = [];

  final currentUser = await RepositoryProvider.userRepository.getCurrentUser();

  final pageState = SearchPageState(
    lastEquipeNom: lastEquipeNom,
    lastJoueurNom: lastJoueurNom,
    lastCompetitionNom: lastCompetitionNom,
    lastMatchDate: lastMatchDate,
    hasMoreEquipes: hasMoreEquipes,
    hasMoreJoueurs: hasMoreJoueurs,
    hasMoreCompetitions: hasMoreCompetitions,
    hasMoreMatchs: hasMoreMatchs,
    matchEquipeIds: matchEquipeIds,
  );

  return (
    ResultatsRechercheModel(
      user: currentUser,
      matchs: matchs,
      equipes: equipes,
      competitions: competitions,
      joueurs: joueurs,
    ),
    pageState,
  );
}

Future<(ResultatsRechercheModel, SearchPageState)> searchQueryLoadMore({
  required String query,
  required String section,
  required SearchPageState currentState,
}) async {
  if (query.length < 3 || !currentState.hasMoreForSection(section)) {
    return (const ResultatsRechercheModel(), currentState);
  }

  final fsQuery = _buildFsQuery(query);
  final fsEnd = fsQuery + '\uf8ff';
  final db = FirebaseFirestore.instance;

  switch (section) {
    case 'Équipes':
      return _loadMoreEquipes(db, fsQuery, fsEnd, currentState);
    case 'Joueurs':
      return _loadMoreJoueurs(db, fsQuery, fsEnd, currentState);
    case 'Compétitions':
      return _loadMoreCompetitions(db, fsQuery, fsEnd, currentState);
    case 'Matchs':
      return _loadMoreMatchs(db, currentState);
    default:
      return (const ResultatsRechercheModel(), currentState);
  }
}

Future<(ResultatsRechercheModel, SearchPageState)> _loadMoreEquipes(
  FirebaseFirestore db,
  String fsQuery,
  String fsEnd,
  SearchPageState state,
) async {
  if (state.lastEquipeNom == null) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreEquipes: false)
    );
  }

  try {
    final snap = await db
        .collection('equipes')
        .where('nom', isGreaterThanOrEqualTo: fsQuery)
        .where('nom', isLessThan: fsEnd)
        .orderBy('nom')
        .startAfter([state.lastEquipeNom])
        .limit(_kLimitEquipes)
        .get();

    final equipes = <Equipe>[];
    for (final doc in snap.docs) {
      try {
        final equipe = Equipe.fromJson(json: doc.data());
        equipes.add(equipe);
        AppCache.setEquipe(doc.id, equipe);
        unawaited(LocalCache.setEquipe(doc.id, equipe));
      } catch (_) {}
    }

    final newLastNom =
        snap.docs.isNotEmpty ? snap.docs.last.data()['nom'] as String? : null;

    return (
      ResultatsRechercheModel(equipes: equipes),
      state.copyWith(
        lastEquipeNom: newLastNom ?? state.lastEquipeNom,
        hasMoreEquipes: snap.docs.length >= _kLimitEquipes,
      ),
    );
  } catch (_) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreEquipes: false)
    );
  }
}

Future<(ResultatsRechercheModel, SearchPageState)> _loadMoreJoueurs(
  FirebaseFirestore db,
  String fsQuery,
  String fsEnd,
  SearchPageState state,
) async {
  if (state.lastJoueurNom == null) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreJoueurs: false)
    );
  }

  try {
    final snap = await db
        .collection('joueurs')
        .where('nom', isGreaterThanOrEqualTo: fsQuery)
        .where('nom', isLessThan: fsEnd)
        .orderBy('nom')
        .startAfter([state.lastJoueurNom])
        .limit(_kLimitJoueurs)
        .get();

    final joueurs = <Joueur>[];
    for (final doc in snap.docs) {
      try {
        final joueur = Joueur.fromJson(json: doc.data());
        joueurs.add(joueur);
        AppCache.setJoueur(doc.id, joueur);
        unawaited(LocalCache.setJoueur(doc.id, joueur));
      } catch (_) {}
    }

    final newLastNom =
        snap.docs.isNotEmpty ? snap.docs.last.data()['nom'] as String? : null;

    return (
      ResultatsRechercheModel(joueurs: joueurs),
      state.copyWith(
        lastJoueurNom: newLastNom ?? state.lastJoueurNom,
        hasMoreJoueurs: snap.docs.length >= _kLimitJoueurs,
      ),
    );
  } catch (_) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreJoueurs: false)
    );
  }
}

Future<(ResultatsRechercheModel, SearchPageState)> _loadMoreCompetitions(
  FirebaseFirestore db,
  String fsQuery,
  String fsEnd,
  SearchPageState state,
) async {
  if (state.lastCompetitionNom == null) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreCompetitions: false)
    );
  }

  try {
    final snap = await db
        .collection('competitions')
        .where('nom', isGreaterThanOrEqualTo: fsQuery)
        .where('nom', isLessThan: fsEnd)
        .orderBy('nom')
        .startAfter([state.lastCompetitionNom])
        .limit(_kLimitCompetitions)
        .get();

    final competitions = <Competition>[];
    for (final doc in snap.docs) {
      try {
        final comp = Competition.fromJson(json: doc.data());
        competitions.add(comp);
        AppCache.setCompetition(doc.id, comp);
        unawaited(LocalCache.setCompetition(doc.id, comp));
      } catch (_) {}
    }
    competitions.sort((a, b) => b.popularite - a.popularite);

    final newLastNom =
        snap.docs.isNotEmpty ? snap.docs.last.data()['nom'] as String? : null;

    return (
      ResultatsRechercheModel(competitions: competitions),
      state.copyWith(
        lastCompetitionNom: newLastNom ?? state.lastCompetitionNom,
        hasMoreCompetitions: snap.docs.length >= _kLimitCompetitions,
      ),
    );
  } catch (_) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreCompetitions: false)
    );
  }
}

Future<(ResultatsRechercheModel, SearchPageState)> _loadMoreMatchs(
  FirebaseFirestore db,
  SearchPageState state,
) async {
  if (state.lastMatchDate == null || state.matchEquipeIds.isEmpty) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreMatchs: false)
    );
  }

  try {
    final ids = state.matchEquipeIds.take(15).toList();
    final lastTs = Timestamp.fromDate(state.lastMatchDate!);

    final snaps = await Future.wait([
      db
          .collection('matchs')
          .where('equipeDomicileId', whereIn: ids)
          .orderBy('date', descending: true)
          .startAfter([lastTs])
          .limit(_kLimitMatchs)
          .get(),
      db
          .collection('matchs')
          .where('equipeExterieurId', whereIn: ids)
          .orderBy('date', descending: true)
          .startAfter([lastTs])
          .limit(_kLimitMatchs)
          .get(),
    ]);

    final seenMatchIds = <String>{};
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        seenMatchIds.add(doc.id);
      }
    }

    final results = await Future.wait(
      seenMatchIds.map(
        (id) => RepositoryProvider.matchRepository.fetchMatchById(id),
      ),
    );

    final matchs = results.whereType<MatchModel>().toList();
    matchs.sort((a, b) => b.date.compareTo(a.date));

    final newLastDate = matchs.isNotEmpty ? matchs.last.date : null;

    return (
      ResultatsRechercheModel(matchs: matchs),
      state.copyWith(
        lastMatchDate: newLastDate ?? state.lastMatchDate,
        hasMoreMatchs: seenMatchIds.length >= _kLimitMatchs,
      ),
    );
  } catch (_) {
    return (
      const ResultatsRechercheModel(),
      state.copyWith(hasMoreMatchs: false)
    );
  }
}
