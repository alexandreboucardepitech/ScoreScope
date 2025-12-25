import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/string_helper.dart';

Future<ResultatsRechercheModel> searchQuery(
  String query, {
  String filter = "Tous",
  int minimumLength = 1,
}) async {
  if (query.length < minimumLength) {
    return const ResultatsRechercheModel();
  }

  final normalizedQuery = normalize(query.toLowerCase());

  List<Equipe> equipes = [];
  List<Joueur> joueurs = [];
  List<Competition> competitions = [];
  List<MatchModel> matchs = [];

  if (filter == "Tous" || filter == "Équipes" || filter == "Matchs") {
    final allEquipes =
        await RepositoryProvider.equipeRepository.fetchAllEquipes();

    equipes = allEquipes.where((e) {
      final nom = normalize(e.nom.toLowerCase());
      final nomCourt = normalize((e.nomCourt ?? '').toLowerCase());
      final code = normalize((e.code ?? '').toLowerCase());

      return nom.startsWith(normalizedQuery) ||
          nomCourt.startsWith(normalizedQuery) ||
          code.startsWith(normalizedQuery);
    }).toList();

    equipes.addAll(allEquipes.where((e) {
      final nom = normalize(e.nom.toLowerCase());
      final nomCourt = normalize((e.nomCourt ?? '').toLowerCase());
      final code = normalize((e.code ?? '').toLowerCase());

      return (nom.contains(normalizedQuery) ||
              nomCourt.contains(normalizedQuery) ||
              code.contains(normalizedQuery)) &&
          !equipes.contains(e);
    }).toList());
  }

  if (filter == "Tous" || filter == "Compétitions") {
    final allCompetitions =
        await RepositoryProvider.competitionRepository.fetchAllCompetitions();

    competitions = allCompetitions.where((c) {
      final nom = normalize(c.nom.toLowerCase());
      return nom.startsWith(normalizedQuery);
    }).toList();

    competitions.addAll(allCompetitions.where((c) {
      final nom = normalize(c.nom.toLowerCase());
      return nom.contains(normalizedQuery) && !competitions.contains(c);
    }).toList());

    competitions.sort((a, b) => b.popularite - a.popularite);
  }

  if (filter == "Tous" || filter == "Joueurs") {
    final allJoueurs =
        await RepositoryProvider.joueurRepository.fetchAllJoueurs();

    joueurs = allJoueurs.where((j) {
      final prenom = normalize(j.prenom.toLowerCase());
      final nom = normalize(j.nom.toLowerCase());
      final fullName = normalize(j.fullName.toLowerCase());

      return prenom.startsWith(normalizedQuery) ||
          nom.startsWith(normalizedQuery) ||
          fullName.startsWith(normalizedQuery);
    }).toList();

    joueurs.addAll(allJoueurs.where((j) {
      final prenom = normalize(j.prenom.toLowerCase());
      final nom = normalize(j.nom.toLowerCase());
      final fullName = normalize(j.fullName.toLowerCase());

      return (prenom.contains(normalizedQuery) ||
              nom.contains(normalizedQuery) ||
              fullName.contains(normalizedQuery)) &&
          !joueurs.contains(j);
    }).toList());

    joueurs.sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  if (filter == "Tous" || filter == "Matchs") {
    if (equipes.isNotEmpty) {
      final equipeIds = equipes.map((e) => e.id).toSet();

      final allMatchs =
          await RepositoryProvider.matchRepository.fetchAllMatches();

      matchs = allMatchs.where((m) {
        return equipeIds.contains(m.equipeDomicile.id) ||
            equipeIds.contains(m.equipeExterieur.id);
      }).toList();

      matchs.sort((a, b) => b.date.compareTo(a.date));
    }

    if (filter == "Matchs") {
      // on les avait chargées uniquement pour filtrer
      equipes = [];
    }
  }

  final AppUser? currentUser =
      await RepositoryProvider.userRepository.getCurrentUser();

  return ResultatsRechercheModel(
    user: currentUser,
    matchs: matchs,
    equipes: equipes,
    competitions: competitions,
    joueurs: joueurs,
  );
}
