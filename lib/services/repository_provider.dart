import 'package:scorescope/services/mock/mock_amitie_repository.dart';
import 'package:scorescope/services/mock/mock_app_user_repository.dart';
import 'package:scorescope/services/mock/mock_competition_repository.dart';
import 'package:scorescope/services/mock/mock_joueur_repository.dart';
import 'package:scorescope/services/mock/mock_match_repository.dart';
import 'package:scorescope/services/mock/mock_notification_repository.dart';
import 'package:scorescope/services/mock/mock_post_repository.dart';
import 'package:scorescope/services/mock/mock_recherche_repository.dart';
import 'package:scorescope/services/mock/mock_stats_repository.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';
import 'package:scorescope/services/repositories/i_competition_repository.dart';
import 'package:scorescope/services/repositories/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/i_joueur_repository.dart';
import 'package:scorescope/services/repositories/i_match_repository.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repositories/i_notification_repository.dart';
import 'package:scorescope/services/repositories/i_post_repository.dart';
import 'package:scorescope/services/repositories/i_recherche_repository.dart';
import 'package:scorescope/services/repositories/i_stats_repository.dart';
import 'package:scorescope/services/web/web_amitie_repository.dart';
import 'package:scorescope/services/web/web_app_user_repository.dart';
import 'package:scorescope/services/web/web_competition_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';
import 'package:scorescope/services/web/web_joueur_repository.dart';
import 'package:scorescope/services/web/web_match_repository.dart';
import 'package:scorescope/services/web/web_notification_repository.dart';
import 'package:scorescope/services/web/web_post_repository.dart';
import 'package:scorescope/services/web/web_recherche_repository.dart';
import 'package:scorescope/services/web/web_stats_repository.dart';

import 'mock/mock_equipe_repository.dart';

enum Environment {
  mock,
  web,
}

class RepositoryProvider {
  static Environment environment = Environment.web;

  static IEquipeRepository? _equipeRepository;
  static IEquipeRepository get equipeRepository {
    return _equipeRepository ??= environment == Environment.mock
        ? MockEquipeRepository()
        : WebEquipeRepository();
  }

  static IMatchRepository? _matchRepository;
  static IMatchRepository get matchRepository {
    return _matchRepository ??= environment == Environment.mock
        ? MockMatchRepository()
        : WebMatchRepository();
  }

  static IJoueurRepository? _joueurRepository;
  static IJoueurRepository get joueurRepository {
    return _joueurRepository ??= environment == Environment.mock
        ? MockJoueurRepository()
        : WebJoueurRepository();
  }

  static IAppUserRepository? _userRepository;
  static IAppUserRepository get userRepository {
    return _userRepository ??= environment == Environment.mock
        ? MockAppUserRepository()
        : WebAppUserRepository();
  }

  static IAmitieRepository? _amitieRepository;
  static IAmitieRepository get amitieRepository {
    return _amitieRepository ??= environment == Environment.mock
        ? MockAmitieRepository()
        : WebAmitieRepository();
  }

  static IPostRepository? _postRepository;
  static IPostRepository get postRepository {
    return _postRepository ??= environment == Environment.mock
        ? MockPostRepository()
        : WebPostRepository();
  }

  static INotificationRepository? _notificationRepository;
  static INotificationRepository get notificationRepository {
    return _notificationRepository ??= environment == Environment.mock
        ? MockNotificationRepository()
        : WebNotificationRepository();
  }

  static ICompetitionRepository? _competitionRepository;
  static ICompetitionRepository get competitionRepository {
    return _competitionRepository ??= environment == Environment.mock
        ? MockCompetitionRepository()
        : WebCompetitionRepository();
  }

  static IRechercheRepository? _rechercheRepository;
  static IRechercheRepository get rechercheRepository {
    return _rechercheRepository ??= environment == Environment.mock
        ? MockRechercheRepository()
        : WebRechercheRepository();
  }

  static IStatsRepository? _statsRepository;
  static IStatsRepository get statsRepository {
    return _statsRepository ??= environment == Environment.mock
        ? MockStatsRepository()
        : WebStatsRepository();
  }

  static void reset() {
    _equipeRepository = null;
    _matchRepository = null;
    _joueurRepository = null;
    _userRepository = null;
    _amitieRepository = null;
    _postRepository = null;
    _notificationRepository = null;
    _competitionRepository = null;
    _rechercheRepository = null;
    _statsRepository = null;
  }
}
