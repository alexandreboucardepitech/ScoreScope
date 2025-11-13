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
    return Match.fromJson(json: doc.data()!, matchId: doc.id);
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
  Future<void> addMatch(Match m) async {
    await _collection.doc(m.id).set(m.toJson());
  }

  @override
  Future<void> updateMatch(Match m) async {
    await _collection.doc(m.id).update(m.toJson());
  }

  @override
  Future<void> deleteMatch(Match m) async {
    await _collection.doc(m.id).delete();
  }
}
