import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/utils/search/search_page_state.dart';

abstract class IRechercheRepository {
  Future<(ResultatsRechercheModel, SearchPageState)> search(
    String query, {
    String? filter,
  });
}
