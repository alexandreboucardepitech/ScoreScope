import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/services/cache/local_cache.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import 'package:scorescope/utils/handle_data/app_cache.dart';
import 'package:scorescope/utils/string/parse_map.dart';
import '../../../models/match.dart';
import 'package:scorescope/services/repository_provider.dart';

class WebMatchRepository implements IMatchRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('matchs');

  void _invalidateMatch(String matchId) {
    AppCache.invalidateMatch(matchId);
    LocalCache.invalidateMatch(matchId);
  }

  @override
  Future<MatchModel?> fetchMatchById(String id) async {
    if (RepositoryProvider.userRepository.currentUser?.options.utiliserCache ??
        true) {
      final l1 = AppCache.getMatch(id);
      if (l1 != null) {
        final liveData = await _fetchLiveMatchData(id);
        final refreshed = l1.copyWith(
          mvpVotes: liveData.$1,
          notes: liveData.$2,
        );
        AppCache.setMatch(id, refreshed);
        return refreshed;
      }

      final l2 = LocalCache.getMatch(id);
      if (l2 != null) {
        final liveData = await _fetchLiveMatchData(id);
        final matchWithLive = l2.copyWith(
          mvpVotes: liveData.$1,
          notes: liveData.$2,
        );
        AppCache.setMatch(id, matchWithLive);
        return matchWithLive;
      }
    }

    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    final matchModelId = MatchModelId.fromJson(doc.data()!, doc.id);
    final match = await MatchModel.fromMatchId(matchModelId);

    AppCache.setMatch(id, match);
    if (!match.isLive) {
      await LocalCache.setMatch(id, match);
    }

    return match;
  }

  @override
  Future<List<MatchModel>> fetchMatchesByDate(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    final futures = snapshot.docs.map((doc) => fetchMatchById(doc.id)).toList();

    final results = await Future.wait(futures);
    return results.whereType<MatchModel>().toList();
  }

  @override
  Future<List<MatchModel>> fetchMatchesListById(List<String> ids) async {
    final futures = ids.map((id) => fetchMatchById(id)).toList();
    final results = await Future.wait(futures);
    return results.whereType<MatchModel>().toList();
  }

  @override
  Future<List<MatchModel>> fetchTeamAllMatches(String teamId) async {
    final snap1 =
        await _collection.where('equipeDomicileId', isEqualTo: teamId).get();
    final snap2 =
        await _collection.where('equipeExterieurId', isEqualTo: teamId).get();

    final allIds = {
      ...snap1.docs.map((d) => d.id),
      ...snap2.docs.map((d) => d.id),
    };

    final futures = allIds.map((id) => fetchMatchById(id)).toList();
    final results = await Future.wait(futures);
    return results.whereType<MatchModel>().toList();
  }

  @override
  Future<List<MatchModel>> fetchAllMatches() async {
    final snapshot = await _collection.get();
    final futures = snapshot.docs.map((doc) async {
      final matchModelId = MatchModelId.fromJson(doc.data(), doc.id);
      return await MatchModel.fromMatchId(matchModelId);
    }).toList();
    return await Future.wait(futures);
  }

  @override
  Future<List<MatchModelId>> fetchAllMatchesId(
      {bool loadVotesAndNotes = true}) async {
    List<MatchModelId> matches = [];
    Query query = _collection.limit(100);
    DocumentSnapshot? lastDoc;

    while (true) {
      if (lastDoc != null) {
        query = _collection.startAfterDocument(lastDoc).limit(100);
      }
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;
      for (var doc in snapshot.docs) {
        dynamic data = doc.data();
        if (data != null) matches.add(MatchModelId.fromJson(data, doc.id));
      }
      lastDoc = snapshot.docs.last;
    }
    return matches;
  }

  @override
  Future<MatchModelId?> fetchMatchModelIdById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return MatchModelId.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<void> noterMatch(
    String matchId,
    String userId,
    DateTime matchDate,
    int? note,
  ) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();
    final data = doc.data() ?? {};
    final notes = Map<String, dynamic>.from(data['notes'] ?? {});

    if (note == null) {
      notes.remove(userId);
    } else {
      notes[userId] = note;
    }
    await docRef.update({'notes': notes});

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();
    if (docSnapshot.exists) {
      final userMatchData = docSnapshot.data()!;
      if (userMatchData['watchedAt'] == null) {
        await userMatchDocRef
            .update({'note': note, 'watchedAt': DateTime.now().toUtc()});
      } else {
        await userMatchDocRef.update({'note': note});
      }
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': note,
        'mvpVoteId': null,
        'favourite': false,
        'private': false,
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
      });
    }

    _invalidateMatch(matchId);
  }

  @override
  Future<void> enleverNote(
    String matchId,
    String userId,
    DateTime matchDate,
  ) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();
    final data = doc.data() ?? {};
    final notes = Map<String, dynamic>.from(data['notes'] ?? {});
    notes.remove(userId);
    await docRef.update({'notes': notes});

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();
    if (docSnapshot.exists) {
      final userMatchData = docSnapshot.data()!;
      if (userMatchData['watchedAt'] == null) {
        await userMatchDocRef
            .update({'note': null, 'watchedAt': DateTime.now().toUtc()});
      } else {
        await userMatchDocRef.update({'note': null});
      }
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': null,
        'mvpVoteId': null,
        'favourite': false,
        'private': false,
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
      });
    }

    _invalidateMatch(matchId);
  }

  @override
  Future<void> voterPourMVP(
    String matchId,
    String userId,
    DateTime matchDate,
    String? joueurId,
  ) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();
    final data = doc.data() ?? {};
    final votes = Map<String, dynamic>.from(data['mvpVotes'] ?? {});

    if (joueurId == null) {
      votes.remove(userId);
    } else {
      votes[userId] = joueurId;
    }
    await docRef.update({'mvpVotes': votes});

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();
    if (docSnapshot.exists) {
      final userMatchData = docSnapshot.data()!;
      if (userMatchData['watchedAt'] == null) {
        await userMatchDocRef.update(
            {'mvpVoteId': joueurId, 'watchedAt': DateTime.now().toUtc()});
      } else {
        await userMatchDocRef.update({'mvpVoteId': joueurId});
      }
    } else {
      await userMatchDocRef.set({
        'matchId': matchId,
        'note': null,
        'mvpVoteId': joueurId,
        'favourite': false,
        'private': false,
        'watchedAt': DateTime.now().toUtc(),
        'matchDate': matchDate,
      });
    }

    _invalidateMatch(matchId);
  }

  @override
  Future<void> enleverVote(String matchId, String userId) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();
    final data = doc.data() ?? {};
    final votes = Map<String, dynamic>.from(data['mvpVotes'] ?? {});
    votes.remove(userId);
    await docRef.update({'mvpVotes': votes});

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);
    final docSnapshot = await userMatchDocRef.get();
    if (docSnapshot.exists) {
      await userMatchDocRef.update({'mvpVoteId': FieldValue.delete()});
    }

    _invalidateMatch(matchId);
  }

  @override
  Future<void> addMatch(MatchModel match) async {
    await _collection.doc(match.id).set(match.toJson());
    AppCache.setMatch(match.id, match);
    await LocalCache.setMatch(match.id, match);
  }

  @override
  Future<void> updateMatch(MatchModel match) async {
    await _collection.doc(match.id).update(match.toJson());
    _invalidateMatch(match.id);
  }

  @override
  Future<void> updateMatchModelId(MatchModelId matchId) async {
    await _collection.doc(matchId.id).update(matchId.toJson());
    _invalidateMatch(matchId.id);
  }

  @override
  Future<void> updateField({
    required String matchId,
    MatchStatus? status,
    int? liveMinute,
    int? extraTime,
    int? saison,
    String? equipeDomicileId,
    String? equipeExterieurId,
    String? competitionId,
    DateTime? date,
    String? refereeName,
    String? stadiumName,
    int? scoreEquipeDomicile,
    int? scoreEquipeExterieur,
    List<ButId>? butsEquipeDomicileId,
    List<ButId>? butsEquipeExterieurId,
    List<MatchJoueurId>? joueursEquipeDomicileId,
    List<MatchJoueurId>? joueursEquipeExterieurId,
    Map<String, String>? mvpVotes,
    Map<String, int>? notes,
  }) async {
    await _collection.doc(matchId).update({
      if (status != null) 'status': status,
      if (liveMinute != null) 'liveMinute': liveMinute,
      if (extraTime != null) 'extraTime': extraTime,
      if (saison != null) 'saison': saison,
      if (equipeDomicileId != null) 'equipeDomicileId': equipeDomicileId,
      if (equipeExterieurId != null) 'equipeExterieurId': equipeExterieurId,
      if (competitionId != null) 'competitionId': competitionId,
      if (date != null) 'date': date,
      if (refereeName != null) 'refereeName': refereeName,
      if (stadiumName != null) 'stadiumName': stadiumName,
      if (scoreEquipeDomicile != null)
        'scoreEquipeDomicile': scoreEquipeDomicile,
      if (scoreEquipeExterieur != null)
        'scoreEquipeExterieur': scoreEquipeExterieur,
      if (butsEquipeDomicileId != null)
        'butsEquipeDomicile':
            butsEquipeDomicileId.map((b) => b.toJson()).toList(),
      if (butsEquipeExterieurId != null)
        'butsEquipeExterieur':
            butsEquipeExterieurId.map((b) => b.toJson()).toList(),
      if (joueursEquipeDomicileId != null)
        'joueursEquipeDomicile':
            joueursEquipeDomicileId.map((j) => j.toJson()).toList(),
      if (joueursEquipeExterieurId != null)
        'joueursEquipeExterieur':
            joueursEquipeExterieurId.map((j) => j.toJson()).toList(),
      if (mvpVotes != null) 'mvpVotes': mvpVotes,
      if (notes != null) 'notes': notes,
    });

    _invalidateMatch(matchId);
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    await _collection.doc(matchId).delete();
    _invalidateMatch(matchId);
  }

  @override
  Future<void> addMatchModelId(MatchModelId matchId) async {
    final docRef = _collection.doc(matchId.id);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(matchId.toJson());
      print("Match ajouté : ${matchId.id}");
    } else {
      print("Match déjà existant : ${matchId.id}");
    }
  }

  @override
  Future<void> addMatchModelIdList(List<MatchModelId> matchs) async {
    for (MatchModelId match in matchs) {
      await addMatchModelId(match);
    }
  }

  Future<(Map<String, String>, Map<String, int>)> _fetchLiveMatchData(
      String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return (<String, String>{}, <String, int>{});
      final data = doc.data()!;
      return (
        parseStringMap(data['mvpVotes']),
        parseIntMap(data['notes']),
      );
    } catch (_) {
      return (<String, String>{}, <String, int>{});
    }
  }
}
