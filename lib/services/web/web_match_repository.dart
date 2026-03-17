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

    for (dynamic doc in snapshot.docs) {
      final data = doc.data();

      final mvpVotesSnapshot =
          await _collection.doc(doc.id).collection('mvpVotes').get();
      data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

      final notesSnapshot =
          await _collection.doc(doc.id).collection('notes').get();
      data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

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
          if (loadVotesAndNotes) {
            final mvpVotesSnapshot =
                await _collection.doc(doc.id).collection('mvpVotes').get();

            data['mvpVotes'] =
                mvpVotesSnapshot.docs.map((d) => d.data()).toList();

            final notesSnapshot =
                await _collection.doc(doc.id).collection('notes').get();

            data['notesDuMatch'] =
                notesSnapshot.docs.map((d) => d.data()).toList();
          }

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
    final mvpVotesSnapshot =
        await _collection.doc(id).collection('mvpVotes').get();
    data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

    final notesSnapshot = await _collection.doc(id).collection('notes').get();
    data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

    final MatchModelId matchModelId = MatchModelId.fromJson(data, doc.id);

    return await MatchModel.fromMatchId(matchModelId);
  }

  @override
  Future<MatchModelId?> fetchMatchModelIdById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final mvpVotesSnapshot =
        await _collection.doc(id).collection('mvpVotes').get();
    data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

    final notesSnapshot = await _collection.doc(id).collection('notes').get();
    data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

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

      final mvpVotesSnapshot =
          await _collection.doc(doc.id).collection('mvpVotes').get();
      data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

      final notesSnapshot =
          await _collection.doc(doc.id).collection('notes').get();
      data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

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
    int? scoreEquipeDomicile,
    int? scoreEquipeExterieur,
    List<ButId>? butsEquipeDomicileId,
    List<ButId>? butsEquipeExterieurId,
    List<MatchJoueurId>? joueursEquipeDomicileId,
    List<MatchJoueurId>? joueursEquipeExterieurId,
    Map<String, String>? mvpVotes,
    Map<String, int>? notesDuMatch,
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
      if (notesDuMatch != null) 'notesDuMatch': notesDuMatch,
    });
  }

  @override
  Future<void> deleteMatch(MatchModel match) async {
    await _collection.doc(match.id).delete();
  }

  @override
  Future<void> noterMatch(
      String matchId, String userId, DateTime matchDate, int? note) async {
    await _collection.doc(matchId).collection('notes').doc(userId).set({
      'userId': userId,
      'note': note,
    });

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'note': note,
      });
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
  Future<void> voterPourMVP(String matchId, String userId, DateTime matchDate,
      String? joueurId) async {
    await _collection.doc(matchId).collection('mvpVotes').doc(userId).set({
      'userId': userId,
      'joueurId': joueurId,
    });

    final userMatchDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('matchUserData')
        .doc(matchId);

    final docSnapshot = await userMatchDocRef.get();

    if (docSnapshot.exists) {
      await userMatchDocRef.update({
        'mvpVoteId': joueurId,
      });
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
    final vote = _collection.doc(matchId).collection('mvpVotes').doc(userId);
    final voteDoc = await vote.get();
    if (voteDoc.exists) {
      await _collection
          .doc(matchId)
          .collection('mvpVotes')
          .doc(userId)
          .delete();
    }

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
    for (dynamic doc in allDocs) {
      final data = doc.data();

      final mvpVotesSnapshot =
          await _collection.doc(doc.id).collection('mvpVotes').get();
      data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

      final notesSnapshot =
          await _collection.doc(doc.id).collection('notes').get();
      data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

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
      await _collection.doc(matchId.id).set(matchId.toJson());
      print("Match ajouté : ${matchId.id}");
    } else {
      print("Match déja existant : ${matchId.id}");
    }
  }

  @override
  Future<void> addMatchModelIdList(List<MatchModelId> matchs) async {
    for (MatchModelId match in matchs) {
      await addMatchModelId(match);
    }
  }
}
