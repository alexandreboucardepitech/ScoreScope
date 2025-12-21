import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';

class WebCompetitionRepository implements ICompetitionRepository {
  final CollectionReference<Map<String, dynamic>> _competitionsCollection =
      FirebaseFirestore.instance.collection('competitions');
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<List<Competition>> fetchAllCompetitions() async {
    final snapshot = await _competitionsCollection.get();
    return snapshot.docs
        .map((doc) =>
            Competition.fromJson(json: doc.data(), competitionId: doc.id))
        .toList();
  }

  @override
  Future<Competition?> fetchCompetitionById(String id) async {
    final doc = await _competitionsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Competition.fromJson(json: doc.data()!, competitionId: doc.id);
  }

  @override
  Future<void> updateFavoriteCompetitions(
      {required String userId, required List<String> competitionIds}) async {
    // on récupère d'abord les compétitions préférées actuelles (avant changement)
    final userDoc = await _usersCollection.doc(userId).get();
    if (!userDoc.exists) return;
    final data = userDoc.data();
    if (data == null) return;
    final currentFavoriteCompetitions =
        (data['competitionsPrefereesId'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
    final allFavoriteCompetitions = {
      ...currentFavoriteCompetitions,
      ...competitionIds,
    }.toList();

    final List<String> competitionsRemoved = [];
    final List<String> competitionsAdded = [];

    for (String compId in allFavoriteCompetitions) {
      if (competitionIds.contains(compId) &&
          !currentFavoriteCompetitions.contains(compId)) {
        competitionsAdded.add(compId);
      } else if (!competitionIds.contains(compId) &&
          currentFavoriteCompetitions.contains(compId)) {
        competitionsRemoved.add(compId);
      }
    }

    await _usersCollection
        .doc(userId)
        .update({'competitionsPrefereesId': competitionIds});

    for (String compId in competitionsAdded) {
      await _competitionsCollection.doc(compId).update({
        'popularite': FieldValue.increment(1),
      });
    }
    for (String compId in competitionsRemoved) {
      await _competitionsCollection.doc(compId).update({
        'popularite': FieldValue.increment(-1),
      });
    }
  }
}
