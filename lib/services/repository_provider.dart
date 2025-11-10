import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_joueur_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/repositories/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/i_joueur_repository.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';
import 'package:scorescope/services/web/web_joueur_repository.dart';
import 'package:scorescope/services/web/web_match_repository.dart';

import 'mock/mock_equipe_repository.dart';

enum Environment {
  mock,
  web,
}

class RepositoryProvider {
  static Environment environment = Environment.mock;

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

  static IAppUserRepository get userRepository {
    switch (environment) {
      case Environment.mock:
        return MockAppUserRepository();
      case Environment.web:
        return WebAppUserRepository();
    }
  }
}
