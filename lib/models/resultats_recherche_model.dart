import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';

class ResultatsRechercheModel {
  final AppUser? user;
  final List<MatchModel> matchs;
  final List<Equipe> equipes;
  final List<Competition> competitions;
  final List<Joueur> joueurs;

  const ResultatsRechercheModel({
    this.user,
    this.matchs = const [],
    this.equipes = const [],
    this.competitions = const [],
    this.joueurs = const [],
  });

  bool get isEmpty =>
      matchs.isEmpty &&
      equipes.isEmpty &&
      competitions.isEmpty &&
      joueurs.isEmpty;
}
