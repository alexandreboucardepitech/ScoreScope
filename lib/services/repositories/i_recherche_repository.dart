import 'package:scorescope/models/resultats_recherche_model.dart';

abstract class IRechercheRepository {
  Future<ResultatsRechercheModel> search(
    String query, {
    String filter = "Tous",
    int minimumLength = 1,
  });
}
