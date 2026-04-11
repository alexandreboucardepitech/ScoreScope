import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import '../../../models/match.dart';

class WebMatchRepository implements IMatchRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  Future<List<MatchModel>> fetchAllMatches() async {
    final snapshot = await _collection.get();

    List<MatchModel> matchModels = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final MatchModelId matchModelId = MatchModelId.fromJson(data, doc.id);

      matchModels.add(await MatchModel.fromMatchId(matchModelId));
    }

    return matchModels;
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
        if (data != null) {
          matches.add(MatchModelId.fromJson(data, doc.id));
        }
      }

      lastDoc = snapshot.docs.last;
    }

    return matches;
  }

  @override
  Future<MatchModel?> fetchMatchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;

    final MatchModelId matchModelId = MatchModelId.fromJson(data, doc.id);

    return await MatchModel.fromMatchId(matchModelId);
  }

  @override
  Future<MatchModelId?> fetchMatchModelIdById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;

    return MatchModelId.fromJson(data, doc.id);
  }

  @override
  Future<List<MatchModel>> fetchMatchesListById(List<String> ids) async {
    List<MatchModel> matches = [];
    for (String id in ids) {
      MatchModel? match = await fetchMatchById(id);
      if (match != null) {
        matches.add(match);
      }
    }
    return matches;
  }

  @override
  Future<List<MatchModel>> fetchMatchesByDate(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    final Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .get();

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data();

      final MatchModelId matchModelId = MatchModelId.fromJson(data, doc.id);

      return await MatchModel.fromMatchId(matchModelId);
    }).toList();

    return await Future.wait(futures);
  }

  @override
  Future<void> addMatch(MatchModel match) async {
    await _collection.doc(match.id).set(match.toJson());
  }

  @override
  Future<void> updateMatch(MatchModel match) async {
    await _collection.doc(match.id).update(match.toJson());
  }

  @override
  Future<void> updateMatchModelId(MatchModelId matchId) async {
    await _collection.doc(matchId.id).update(matchId.toJson());
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
        'butsEquipeDomicileId': butsEquipeDomicileId,
      if (butsEquipeExterieurId != null)
        'butsEquipeExterieurId': butsEquipeExterieurId,
      if (joueursEquipeDomicileId != null)
        'joueursEquipeDomicileId': joueursEquipeDomicileId,
      if (joueursEquipeExterieurId != null)
        'joueursEquipeExterieurId': joueursEquipeExterieurId,
      if (mvpVotes != null) 'mvpVotes': mvpVotes,
      if (notes != null) 'notes': notes,
    });
  }

  @override
  Future<void> deleteMatch(MatchModel match) async {
    await _collection.doc(match.id).delete();
  }

  @override
  Future<void> noterMatch(
      String matchId, String userId, DateTime matchDate, int? note) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    Map<String, dynamic> notes = Map<String, dynamic>.from(data['notes'] ?? {});

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
      // if watchedAt is null or does not exist, set it to now
      final userMatchData = docSnapshot.data()!;
      if (userMatchData['watchedAt'] == null) {
        await userMatchDocRef.update({
          'note': note,
          'watchedAt': DateTime.now().toUtc(),
        });
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
  }

  @override
  Future<void> enleverNote(String matchId, String userId) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    Map<String, dynamic> notes = Map<String, dynamic>.from(data['notes'] ?? {});

    notes.remove(userId);

    await docRef.update({'notes': notes});
  }

  @override
  Future<void> voterPourMVP(String matchId, String userId, DateTime matchDate,
      String? joueurId) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    Map<String, dynamic> votes =
        Map<String, dynamic>.from(data['mvpVotes'] ?? {});

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
      // if watchedAt is null or does not exist, set it to now
      final userMatchData = docSnapshot.data()!;
      if (userMatchData['watchedAt'] == null) {
        await userMatchDocRef.update({
          'mvpVoteId': joueurId,
          'watchedAt': DateTime.now().toUtc(),
        });
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
  }

  @override
  Future<void> enleverVote(String matchId, String userId) async {
    final docRef = _collection.doc(matchId);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    Map<String, dynamic> votes =
        Map<String, dynamic>.from(data['mvpVotes'] ?? {});

    votes.remove(userId);

    await docRef.update({'mvpVotes': votes});

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'mvpVoteId': FieldValue.delete(),
      });
    }
  }

  @override
  Future<List<MatchModel>> fetchTeamAllMatches(String teamId) async {
    final snapshot =
        await _collection.where('equipeDomicileId', isEqualTo: teamId).get();

    final snapshot2 =
        await _collection.where('equipeExterieurId', isEqualTo: teamId).get();

    final allDocs = [...snapshot.docs, ...snapshot2.docs];

    List<MatchModel> matchs = [];

    for (var doc in allDocs) {
      final data = doc.data();

      final MatchModelId matchModelId = MatchModelId.fromJson(data, doc.id);

      matchs.add(await MatchModel.fromMatchId(matchModelId));
    }

    return matchs;
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
}
