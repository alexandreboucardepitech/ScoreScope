import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/cache/local_cache.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/app_cache.dart';

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
    if (RepositoryProvider.userRepository.currentUser?.options.utiliserCache ??
        true) {
      // L1 — mémoire
      final l1 = AppCache.getCompetition(id);
      if (l1 != null) return l1;

      // L2 — disque
      final l2 = LocalCache.getCompetition(id);
      if (l2 != null) {
        AppCache.setCompetition(id, l2); // remonte en L1
        return l2;
      }
    }

    // Firestore
    final doc = await _competitionsCollection.doc(id).get();
    if (!doc.exists) return null;
    final competition = Competition.fromJson(
      json: doc.data()!,
      competitionId: doc.id,
    );

    // Écriture dans les deux couches
    AppCache.setCompetition(id, competition);
    await LocalCache.setCompetition(id, competition);

    return competition;
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

  @override
  Future<void> addCompetition(Competition competition) async {
    final docRef = _competitionsCollection.doc(competition.id);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(competition.toJson());
      print("Compétition ajoutée : ${competition.nom}");
    } else {
      print("Compétition déjà existante : ${competition.nom}");
    }
  }

  @override
  Future<void> addCompetitionList(List<Competition> competitions) async {
    for (Competition comp in competitions) {
      await addCompetition(comp);
    }
  }

  @override
  Future<void> updateCompetition({
    required String id,
    String? nom,
    String? country,
    String? logoUrl,
    int? popularite,
  }) async {
    final docRef = _competitionsCollection.doc(id);
    await docRef.update({
      if (nom != null) 'nom': nom,
      if (country != null) 'country': country,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (popularite != null) 'popularite': popularite,
    });
  }
}
