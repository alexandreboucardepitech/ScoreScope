class SearchPageState {
  final String? lastEquipeNom;

  final String? lastJoueurNom;

  final String? lastCompetitionNom;

  final DateTime? lastMatchDate;

  final bool hasMoreEquipes;
  final bool hasMoreJoueurs;
  final bool hasMoreCompetitions;
  final bool hasMoreMatchs;

  final List<String> matchEquipeIds;

  const SearchPageState({
    this.lastEquipeNom,
    this.lastJoueurNom,
    this.lastCompetitionNom,
    this.lastMatchDate,
    this.hasMoreEquipes = false,
    this.hasMoreJoueurs = false,
    this.hasMoreCompetitions = false,
    this.hasMoreMatchs = false,
    this.matchEquipeIds = const [],
  });

  static const empty = SearchPageState();

  SearchPageState copyWith({
    String? lastEquipeNom,
    String? lastJoueurNom,
    String? lastCompetitionNom,
    DateTime? lastMatchDate,
    bool? hasMoreEquipes,
    bool? hasMoreJoueurs,
    bool? hasMoreCompetitions,
    bool? hasMoreMatchs,
    List<String>? matchEquipeIds,
  }) {
    return SearchPageState(
      lastEquipeNom: lastEquipeNom ?? this.lastEquipeNom,
      lastJoueurNom: lastJoueurNom ?? this.lastJoueurNom,
      lastCompetitionNom: lastCompetitionNom ?? this.lastCompetitionNom,
      lastMatchDate: lastMatchDate ?? this.lastMatchDate,
      hasMoreEquipes: hasMoreEquipes ?? this.hasMoreEquipes,
      hasMoreJoueurs: hasMoreJoueurs ?? this.hasMoreJoueurs,
      hasMoreCompetitions: hasMoreCompetitions ?? this.hasMoreCompetitions,
      hasMoreMatchs: hasMoreMatchs ?? this.hasMoreMatchs,
      matchEquipeIds: matchEquipeIds ?? this.matchEquipeIds,
    );
  }

  bool hasMoreForSection(String section) {
    switch (section) {
      case 'Équipes':
        return hasMoreEquipes;
      case 'Joueurs':
        return hasMoreJoueurs;
      case 'Compétitions':
        return hasMoreCompetitions;
      case 'Matchs':
        return hasMoreMatchs;
      default:
        return false;
    }
  }
}
