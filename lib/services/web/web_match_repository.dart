import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import '../../../models/match.dart';

class WebMatchRepository implements IMatchRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  Future<List<MatchModel>> fetchAllMatches() async {
    final snapshot = await _collection.get();

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data();

      final mvpVotesSnapshot =
          await _collection.doc(doc.id).collection('mvpVotes').get();

      data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

      final notesSnapshot =
          await _collection.doc(doc.id).collection('notes').get();

      data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

      return await MatchModel.fromJson(json: data, matchId: doc.id);
    }).toList();

    return await Future.wait(futures);
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

    return MatchModel.fromJson(json: data, matchId: doc.id);
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

      return await MatchModel.fromJson(json: data, matchId: doc.id);
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
    await _collection.doc(matchId).collection('mvpVotes').doc(userId).delete();

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
}
