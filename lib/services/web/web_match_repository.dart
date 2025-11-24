import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import '../../../models/match.dart';

class WebMatchRepository implements IMatchRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  Future<List<Match>> fetchAllMatches() async {
    final snapshot = await _collection.get();

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data();

      final mvpVotesSnapshot =
          await _collection.doc(doc.id).collection('mvpVotes').get();

      data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

      final notesSnapshot =
          await _collection.doc(doc.id).collection('notes').get();

      data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

      return await Match.fromJson(json: data, matchId: doc.id);
    }).toList();

    return await Future.wait(futures);
  }

  @override
  Future<Match?> fetchMatchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final mvpVotesSnapshot =
        await _collection.doc(id).collection('mvpVotes').get();
    data['mvpVotes'] = mvpVotesSnapshot.docs.map((d) => d.data()).toList();

    final notesSnapshot = await _collection.doc(id).collection('notes').get();
    data['notesDuMatch'] = notesSnapshot.docs.map((d) => d.data()).toList();

    return Match.fromJson(json: data, matchId: doc.id);
  }

  @override
  Future<List<Match>> fetchMatchesListById(List<String> ids) async {
    List<Match> matches = [];
    for (String id in ids) {
      Match? match = await fetchMatchById(id);
      if (match != null) {
        matches.add(match);
      }
    }
    return matches;
  }

  @override
  Future<void> addMatch(Match match) async {
    await _collection.doc(match.id).set(match.toJson());
  }

  @override
  Future<void> updateMatch(Match match) async {
    await _collection.doc(match.id).update(match.toJson());
  }

  @override
  Future<void> deleteMatch(Match match) async {
    await _collection.doc(match.id).delete();
  }

  @override
  Future<void> noterMatch(String matchId, String userId, int? note) async {
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
      });
    }
  }

  @override
  Future<void> voterPourMVP(
      String matchId, String userId, String? joueurId) async {
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
        'mvpVoteId': joueurId,
        'favourite': false,
        'private': false,
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
