import 'package:scorescope/services/mock/mock_joueur_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/repositories/equipe/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/joueur/i_joueur_repository.dart';
import 'package:scorescope/services/repositories/match/i_match_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';
import 'package:scorescope/services/web/web_joueur_repository.dart';
import 'package:scorescope/services/web/web_match_repository.dart';

import 'mock/mock_equipe_repository.dart';

enum Environment {
  mock,
  web,
}

class RepositoryProvider {
  static Environment environment = Environment.web;

  static IEquipeRepository get equipeRepository {
    switch (environment) {
      case Environment.mock:
        return MockEquipeRepository();
      case Environment.web:
        return WebEquipeRepository();
    }
  }

  static IMatchRepository get matchRepository {
    switch (environment) {
      case Environment.mock:
        return MockMatchRepository();
      case Environment.web:
        return WebMatchRepository();
    }
  }

  static IJoueurRepository get joueurRepository {
    switch (environment) {
      case Environment.mock:
        return MockJoueurRepository();
      case Environment.web:
        return WebJoueurRepository();
    }
  }
}
