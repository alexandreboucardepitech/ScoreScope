import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/match/i_match_repository.dart';
import '../../../models/match.dart';

class WebMatchRepository implements IMatchRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('matchs');

  @override
  Future<List<Match>> fetchAllMatches() async {
    final snapshot = await _collection.get();

    final futures = snapshot.docs.map((doc) async {
      return await Match.fromJson(json: doc.data(), matchId: doc.id);
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
