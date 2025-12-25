import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repositories/i_recherche_repository.dart';
import 'package:scorescope/utils/search/search_query.dart';

class MockRechercheRepository implements IRechercheRepository {
  @override
  Future<ResultatsRechercheModel> search(String query,
      {String filter = "Tous", int minimumLength = 1}) async {
    return searchQuery(
      query,
      filter: filter,
      minimumLength: minimumLength,
    );
  }
}
