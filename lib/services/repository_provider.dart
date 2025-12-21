import 'package:scorescope/services/mock/mock_amitie_repository.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_competition_repository.dart';
import 'package:scorescope/services/mock/mock_joueur_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/mock/mock_notification_repository.dart';
import 'package:scorescope/services/mock/mock_post_repository.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';
import 'package:scorescope/services/repositories/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/i_joueur_repository.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repositories/i_notification_repository.dart';
import 'package:scorescope/services/repositories/i_post_repository.dart';
import 'package:scorescope/services/web/web_amitie_repository.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/services/web/web_competition_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';
import 'package:scorescope/services/web/web_joueur_repository.dart';
import 'package:scorescope/services/web/web_match_repository.dart';
import 'package:scorescope/services/web/web_notification_repository.dart';
import 'package:scorescope/services/web/web_post_repository.dart';

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

  static IAppUserRepository get userRepository {
    switch (environment) {
      case Environment.mock:
        return MockAppUserRepository();
      case Environment.web:
        return WebAppUserRepository();
    }
  }

  static IAmitieRepository get amitieRepository {
    switch (environment) {
      case Environment.mock:
        return MockAmitieRepository();
      case Environment.web:
        return WebAmitieRepository();
    }
  }

  static IPostRepository get postRepository {
    switch (environment) {
      case Environment.mock:
        return MockPostRepository();
      case Environment.web:
        return WebPostRepository();
    }
  }

  static INotificationRepository get notificationRepository {
    switch (environment) {
      case Environment.mock:
        return MockNotificationRepository();
      case Environment.web:
        return WebNotificationRepository();
    }
  }

  static ICompetitionRepository get competitionRepository {
    switch (environment) {
      case Environment.mock:
        return MockCompetitionRepository();
      case Environment.web:
        return WebCompetitionRepository();
    }
  }
}
