import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repositories/i_recherche_repository.dart';
import 'package:scorescope/utils/search/search_page_state.dart';
import 'package:scorescope/utils/search/search_query.dart';

class MockRechercheRepository implements IRechercheRepository {
  @override
  Future<(ResultatsRechercheModel, SearchPageState)> search(String query,
      {String filter = "Tous"}) async {
    return searchQuery(
      query,
      filter: filter,
    );
  }
}
