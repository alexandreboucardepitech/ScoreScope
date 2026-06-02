import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repositories/i_recherche_repository.dart';
import 'package:scorescope/utils/search/search_page_state.dart';
import 'package:scorescope/utils/search/search_query.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class WebRechercheRepository implements IRechercheRepository {
  @override
  Future<(ResultatsRechercheModel, SearchPageState)> search(
    String query, {
    String? filter,
  }) async {
    if (filter == null) {
      filter = translate.tous;
    }
    return searchQuery(
      query,
      filter: filter,
    );
  }
}
