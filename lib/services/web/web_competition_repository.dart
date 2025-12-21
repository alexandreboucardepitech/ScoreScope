import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';

class WebCompetitionRepository implements ICompetitionRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('competitions');

  @override
  Future<List<Competition>> fetchAllCompetitions() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) =>
            Competition.fromJson(json: doc.data(), competitionId: doc.id))
        .toList();
  }

  @override
  Future<Competition?> fetchCompetitionById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Competition.fromJson(json: doc.data()!, competitionId: doc.id);
  }
}
