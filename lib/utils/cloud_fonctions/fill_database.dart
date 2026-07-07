import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/watch_together.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/construct_player_from_json.dart';
import 'package:scorescope/utils/string/get_first_and_last_name.dart';
import 'package:scorescope/utils/string/get_match_status_from_code.dart';

class FillDatabase {
  const FillDatabase._(); // empêche l'instanciation

  static Future<List<dynamic>> getDataFromApi(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    final url = Uri.parse(
      "https://us-central1-scorescope-5a12b.cloudfunctions.net/getFootballData",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "endpoint": endpoint,
        "params": params ?? {},
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData["response"] ?? [];
    } else {
      throw Exception("Erreur Cloud Function");
    }
  }

  static Future<Map<String, String?>> getTeamColors(
      String teamId, String season) async {
    Map<String, int> couleursPrincipale = {};
    Map<String, int> couleursSecondaire = {};
    List<dynamic> cinqDerniersMatchs = await getDataFromApi(
      "fixtures",
      params: {"team": teamId, "season": season, "last": "5"},
    );
    if (cinqDerniersMatchs.isEmpty) {
      print("ERREUR DATA EMPTY: pour getTeamColors $teamId, $season");
      return {"principale": null, "secondaire": null};
    } else {
      print("matchs bien récupérés pour l'équipe $teamId");
      List<String> cinqDerniersMatchsId = [];
      for (Map<String, dynamic> match in cinqDerniersMatchs) {
        final id = match["fixture"]["id"];
        cinqDerniersMatchsId.add(id.toString());
      }

      for (String matchId in cinqDerniersMatchsId) {
        List<dynamic> lineup = await getDataFromApi(
          "fixtures/lineups",
          params: {"team": teamId, "fixture": matchId},
        );
        if (lineup.isEmpty) {
          print("ERREUR DATA EMPTY: pour lineup $teamId, $matchId");
          return {"principale": null, "secondaire": null};
        } else {
          print("couleurs bien récupérées pour l'équipe $teamId");
          String? couleurPrincipale =
              lineup[0]?["team"]?["colors"]?["player"]?["primary"];
          String? couleurSecondaire =
              lineup[0]?["team"]?["colors"]?["player"]?["number"];
          int? principaleCount = couleursPrincipale[couleurPrincipale];
          if (couleurPrincipale != null) {
            couleursPrincipale[couleurPrincipale] =
                principaleCount != null ? principaleCount + 1 : 1;
          }
          int? secondaireCount = couleursSecondaire[couleurSecondaire];
          if (couleurSecondaire != null) {
            couleursSecondaire[couleurSecondaire] =
                secondaireCount != null ? secondaireCount + 1 : 1;
          }
        }
      }
    }
    if (couleursPrincipale.isEmpty || couleursSecondaire.isEmpty) {
      return {"principale": null, "secondaire": null};
    }
    String principale = couleursPrincipale.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    String secondaire = couleursSecondaire.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    return {"principale": principale, "secondaire": secondaire};
  }

  static Map<String, MatchJoueurId> createMatchJoueursFromJson(
    List<dynamic>? json, {
    bool isFromStartXI = false,
  }) {
    if (json == null || json.isEmpty) {
      return {};
    }

    Map<String, MatchJoueurId> joueurs = {}; // id -> item match joueur id

    for (Map<String, dynamic> player in json) {
      Map<String, dynamic>? playerInfos = player['player'];
      if (playerInfos != null) {
        MatchJoueurId matchJoueurId = MatchJoueurId(
          joueurId: playerInfos['id'].toString(),
          number: playerInfos['number'],
          pos: playerInfos['pos'],
          grid: playerInfos['grid'],
          hasPlayed: isFromStartXI,
          isStarter: isFromStartXI,
        );
        joueurs[matchJoueurId.joueurId] = matchJoueurId;
      }
    }

    return joueurs;
  }

  static Future<Map<String, List<dynamic>>> getMatchPlayers(
    String matchId, {
    required String equipeDomicileId,
    required String equipeExterieurId,
  }) async {
    Map<String, MatchJoueurId> equipeDomicilePlayers = {};
    Map<String, MatchJoueurId> equipeExterieurPlayers = {};
    List<ButId> equipeDomicileButs = [];
    List<ButId> equipeExterieurButs = [];

    List<dynamic>? startXIDomicile;
    List<dynamic>? startXIExterieur;
    List<dynamic>? substitutesDomicile;
    List<dynamic>? substitutesExterieur;

    // RÉCUPERER LES JOUEURS
    List<dynamic> lineup = await getDataFromApi(
      "fixtures/lineups",
      params: {"fixture": matchId},
    );
    if (lineup.isEmpty) {
      print("ERREUR DATA EMPTY: pour lineup $matchId");
      return {
        "equipeDomicilePlayers": equipeDomicilePlayers.values.toList(),
        "equipeExterieurPlayers": equipeExterieurPlayers.values.toList(),
        "equipeDomicileButs": equipeDomicileButs,
        "equipeExterieurButs": equipeExterieurButs,
      };
    } else {
      if (lineup.length > 1) {
        for (Map<String, dynamic> teamLineup in lineup) {
          if (teamLineup['team']?['id'].toString() == equipeDomicileId) {
            startXIDomicile = teamLineup['startXI'];
            substitutesDomicile = teamLineup['substitutes'];
          }
          if (teamLineup['team']?['id'].toString() == equipeExterieurId) {
            startXIExterieur = teamLineup['startXI'];
            substitutesExterieur = teamLineup['substitutes'];
          }
        }
        // startXIDomicile = lineup[0]?['startXI'];
        // startXIExterieur = lineup[1]?['startXI'];
        // substitutesDomicile = lineup[0]?['substitutes'];
        // substitutesExterieur = lineup[1]?['substitutes'];
        equipeDomicilePlayers.addAll(createMatchJoueursFromJson(
          startXIDomicile,
          isFromStartXI: true,
        ));
        equipeExterieurPlayers.addAll(createMatchJoueursFromJson(
          startXIExterieur,
          isFromStartXI: true,
        ));
        equipeDomicilePlayers.addAll(createMatchJoueursFromJson(
          substitutesDomicile,
          isFromStartXI: false,
        ));
        equipeExterieurPlayers.addAll(createMatchJoueursFromJson(
          substitutesExterieur,
          isFromStartXI: false,
        ));
      }
    }

    // RÉCUPERER LES BUTS
    List<dynamic> events = await getDataFromApi(
      "fixtures/events",
      params: {"fixture": matchId},
    );
    if (events.isEmpty) {
      print("ERREUR DATA EMPTY: pour events $matchId");
      return {
        "equipeDomicilePlayers": equipeDomicilePlayers.values.toList(),
        "equipeExterieurPlayers": equipeExterieurPlayers.values.toList(),
        "equipeDomicileButs": equipeDomicileButs,
        "equipeExterieurButs": equipeExterieurButs,
      };
    } else {
      for (Map<String, dynamic> event in events) {
        final String? eventType = event['type'];
        if (event['comments'] == "Penalty Shootout") {
          continue;
        }
        switch (eventType) {
          case 'subst':
            final String joueurEntrantId = event['assist']['id'].toString();
            if (equipeDomicilePlayers[joueurEntrantId] != null) {
              equipeDomicilePlayers[joueurEntrantId] =
                  equipeDomicilePlayers[joueurEntrantId]!
                      .copyWith(hasPlayed: true);
            } else if (equipeExterieurPlayers[joueurEntrantId] != null) {
              equipeExterieurPlayers[joueurEntrantId] =
                  equipeExterieurPlayers[joueurEntrantId]!
                      .copyWith(hasPlayed: true);
            }
          case 'Goal':
            final String buteurId = event['player']['id'].toString();
            final String passeurId = event['assist']['id'].toString();
            final String minute = event['time']['elapsed'].toString();
            final String teamId = event['team']['id'].toString();
            bool missed = false;
            TypeBut typeBut;
            switch (event['detail']) {
              case 'Normal Goal':
                typeBut = TypeBut.normal;
              case 'Own Goal':
                typeBut = TypeBut.owngoal;
              case 'Penalty':
                typeBut = TypeBut.penalty;
              case 'Missed Penalty':
                typeBut = TypeBut.normal;
                missed = true;
                break;
              default:
                typeBut = TypeBut.normal;
            }
            if (teamId == equipeDomicileId && missed == false) {
              equipeDomicileButs.add(
                ButId(
                  buteurId: buteurId,
                  minute: minute,
                  passeurId: passeurId,
                  typeBut: typeBut,
                ),
              );
            } else if (teamId == equipeExterieurId && missed == false) {
              equipeExterieurButs.add(
                ButId(
                  buteurId: buteurId,
                  minute: minute,
                  passeurId: passeurId,
                  typeBut: typeBut,
                ),
              );
            }
        }
      }
    }

    return {
      "equipeDomicilePlayers": equipeDomicilePlayers.values.toList(),
      "equipeExterieurPlayers": equipeExterieurPlayers.values.toList(),
      "equipeDomicileButs": equipeDomicileButs,
      "equipeExterieurButs": equipeExterieurButs,
    };
  }

  static Future<List<Competition>> getCompetitions(
      Map<String, String?> namesAndCountries) async {
    List<Competition> competitions = [];

    for (var entry in namesAndCountries.entries) {
      final name = entry.key;
      final country = entry.value;

      Map<String, String> params = {"name": name};
      if (country != null) {
        params["country"] = country;
      }

      List<dynamic> data = await getDataFromApi(
        "leagues",
        params: params,
      );

      if (data.isEmpty) {
        print("ERREUR DATA EMPTY: pour $name, $country");
      } else {
        Map<String, dynamic> league = data[0]['league'];
        Map<String, dynamic> country = data[0]['country'];
        Competition newCompetition = Competition(
          id: league['id'].toString(),
          nom: league['name'],
          country: country['name'],
          logoUrl: league['logo'],
          popularite: 0,
        );
        competitions.add(newCompetition);
      }
    }

    return competitions;
  }

  static Future<List<Equipe>> getEquipes(
    String competitionId,
    String season,
    bool creerEnDirect,
  ) async {
    List<Equipe> equipes = [];

    List<dynamic> data = await getDataFromApi(
      "teams",
      params: {"league": competitionId, "season": season},
    );

    if (data.isEmpty) {
      print("ERREUR DATA EMPTY: pour $competitionId, $season");
    } else {
      print("data bien récupérée pour $competitionId, $season : $data");
      for (Map<String, dynamic> teamData in data) {
        final String id = teamData['team']['id'].toString();
        if (await RepositoryProvider.equipeRepository.fetchEquipeById(id) ==
            null) {
          final String nom = teamData['team']['name'].toString();
          final String code = teamData['team']['code'].toString();
          final String logoPath = teamData['team']['logo'].toString();
          final bool national = teamData['team']['national'] ?? false;
          int saisonCouleurs = int.parse(season);
          Map<String, String?> couleurs = {
            "principale": null,
            "secondaire": null,
          };
          while ((couleurs["principale"] == null &&
                  couleurs["secondaire"] == null) &&
              saisonCouleurs >= int.parse(season) - 10) {
            couleurs = await getTeamColors(id, saisonCouleurs.toString());
            saisonCouleurs--;
          }
          Equipe newEquipe = Equipe(
            id: id,
            nom: nom,
            code: code,
            logoPath: logoPath,
            couleurPrincipale: couleurs["principale"],
            couleurSecondaire: couleurs["secondaire"],
            national: national,
          );
          print("add equipe : $nom");
          equipes.add(newEquipe);
          if (creerEnDirect) {
            await RepositoryProvider.equipeRepository.addEquipe(newEquipe);
          }
        }
      }
    }
    return equipes;
  }

  static Future<MatchModelId> getMatchFromData(
      Map<String, dynamic> matchData) async {
    final String id = matchData['fixture']['id'].toString();
    final MatchStatus status =
        getStatusFromCode(matchData['fixture']['status']['short'].toString());
    final String equipeDomicileId = matchData['teams']['home']['id'].toString();
    final String equipeExterieurId =
        matchData['teams']['away']['id'].toString();
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
        matchData['fixture']['timestamp'] * 1000);
    final String? refereeName = matchData['fixture']?['referee'];
    final String? stadiumName = matchData['fixture']?['venue']?['name'];
    final int scoreEquipeDomicile = matchData['goals']['home'] ?? 0;
    final int scoreEquipeExterieur = matchData['goals']['away'] ?? 0;
    final int penaltyEquipeDomicile =
        matchData['score']?['penalty']?['home'] ?? 0;
    final int penaltyEquipeExterieur =
        matchData['score']?['penalty']?['away'] ?? 0;
    final int? liveMinute = matchData['fixture']['status']['elapsed'];
    final int? extraTime = matchData['fixture']['status']['extra'];
    final int leagueId = matchData['league']['id'];
    final int season = matchData['league']['season'];
    bool prolongations = false;
    if (matchData['fixture']['status']['short'].toString() == "AET")
      prolongations = true;

    Map<String, List<dynamic>> matchPlayers = await getMatchPlayers(id,
        equipeDomicileId: equipeDomicileId,
        equipeExterieurId: equipeExterieurId);

    List<MatchJoueurId> equipeDomicilePlayers =
        matchPlayers['equipeDomicilePlayers'] as List<MatchJoueurId>? ?? [];

    List<MatchJoueurId> equipeExterieurPlayers =
        matchPlayers['equipeExterieurPlayers'] as List<MatchJoueurId>? ?? [];

    for (MatchJoueurId joueur in equipeDomicilePlayers) {
      Joueur? joueurExiste = await RepositoryProvider.joueurRepository
          .fetchJoueurById(joueur.joueurId);
      if (joueurExiste == null) {
        Joueur? joueurCree =
            await createJoueurFromJson(joueur.joueurId, equipeDomicileId);
        if (joueurCree != null) {
          await RepositoryProvider.joueurRepository.addJoueur(joueurCree);
        }
      }
    }

    for (MatchJoueurId joueur in equipeExterieurPlayers) {
      Joueur? joueurExiste = await RepositoryProvider.joueurRepository
          .fetchJoueurById(joueur.joueurId);
      if (joueurExiste == null) {
        Joueur? joueurCree =
            await createJoueurFromJson(joueur.joueurId, equipeExterieurId);
        if (joueurCree != null) {
          await RepositoryProvider.joueurRepository.addJoueur(joueurCree);
        }
      }
    }

    MatchModelId newMatch = MatchModelId(
      id: id,
      status: status,
      equipeDomicileId: equipeDomicileId,
      equipeExterieurId: equipeExterieurId,
      competitionId: leagueId.toString(),
      date: date,
      refereeName: refereeName,
      stadiumName: stadiumName,
      scoreEquipeDomicile: scoreEquipeDomicile,
      scoreEquipeExterieur: scoreEquipeExterieur,
      penaltyEquipeDomicile: penaltyEquipeDomicile,
      penaltyEquipeExterieur: penaltyEquipeExterieur,
      prolongations: prolongations,
      joueursEquipeDomicileId: equipeDomicilePlayers,
      joueursEquipeExterieurId: equipeExterieurPlayers,
      butsEquipeDomicileId:
          matchPlayers['equipeDomicileButs'] as List<ButId>? ?? [],
      butsEquipeExterieurId:
          matchPlayers['equipeExterieurButs'] as List<ButId>? ?? [],
      liveMinute: liveMinute,
      extraTime: extraTime,
      mvpVotes: {},
      notes: {},
      saison: season,
    );
    print("add match : $equipeDomicileId vs $equipeExterieurId");
    return newMatch;
  }

  static Future<List<MatchModelId>> getMatchs(
    String competitionId,
    String season,
    DateTime? from,
    DateTime? to,
    bool creerEnDirect,
  ) async {
    List<MatchModelId> matchs = [];

    dynamic params = {"league": competitionId, "season": season};

    if (from != null) {
      params["from"] = DateFormat('yyyy-MM-dd').format(from);
    }

    if (to != null) {
      params["to"] = DateFormat('yyyy-MM-dd').format(to);
    }

    List<dynamic> data = await getDataFromApi(
      "fixtures",
      params: params,
    );
    if (data.isEmpty) {
      print("ERREUR DATA EMPTY: pour $competitionId, $season");
    } else {
      print("data bien récupérée pour $competitionId, $season : $data");
      int i = 0;
      for (Map<String, dynamic> matchData in data) {
        print("match $i sur ${data.length}");
        if (await RepositoryProvider.matchRepository
                .fetchMatchModelIdById(matchData['fixture']['id'].toString()) ==
            null) {
          MatchModelId newMatch =
              await FillDatabase.getMatchFromData(matchData);
          matchs.add(newMatch);
          if (creerEnDirect) {
            await RepositoryProvider.matchRepository.addMatchModelId(newMatch);
          }
        }
        i++;
      }
    }
    return matchs;
  }

  static Future<List<Joueur>> getJoueursFromId(String matchId) async {
    return [];
  }

  static Future<Joueur?> createJoueurFromJson(
      String joueurId, String equipeId) async {
    if (joueurId == "null") return null;
    List<dynamic> data = await getDataFromApi(
      "players/profiles",
      params: {"player": joueurId},
    );
    if (data.isEmpty) return null;
    Map<String, dynamic>? player = data[0]?['player'];
    if (player != null) {
      String? prenom = player['firstname'];
      String? nom = player['lastname'];
      String? fullName = player['name'];
      String? nationalite = player['nationalite'];
      DateTime? dateNaissance = player['birth']?['date'] != null
          ? DateTime.tryParse(player['birth']['date'])
          : null;
      String picture = player['photo'];
      Map<String, String> nomComplet =
          getFirstAndLastName(prenom, nom, fullName);
      if (fullName != null) {
        fullName = fullName.replaceAll('&apos;', "'");
      }
      final newJoueur = Joueur(
        id: joueurId,
        prenom: nomComplet["prenom"]!,
        nom: nomComplet["nom"]!,
        fullName: fullName,
        equipeId: equipeId,
        dateNaissance: dateNaissance,
        nationalite: nationalite,
        picture: picture,
      );
      return newJoueur;
    }
    return null;
  }

  static Future<List<Joueur>> getJoueurs(MatchModel match) async {
    Map<String, List<dynamic>> players = await getMatchPlayers(
      match.id,
      equipeDomicileId: match.equipeDomicile.id,
      equipeExterieurId: match.equipeDomicile.id,
    );

    List<Joueur> joueurs = [];

    List<MatchJoueurId>? equipeDomicilePlayers =
        players["equipeDomicilePlayers"] as List<MatchJoueurId>?;
    List<MatchJoueurId>? equipeExterieurPlayers =
        players["equipeExterieurPlayers"] as List<MatchJoueurId>?;
    if (equipeDomicilePlayers != null) {
      for (MatchJoueurId joueur in equipeDomicilePlayers) {
        Joueur? newJoueur = await createJoueurFromJson(
          joueur.joueurId,
          match.equipeDomicile.id,
        );
        if (newJoueur != null) {
          joueurs.add(newJoueur);
        }
      }
    }
    if (equipeExterieurPlayers != null) {
      for (MatchJoueurId joueur in equipeExterieurPlayers) {
        Joueur? newJoueur = await createJoueurFromJson(
          joueur.joueurId,
          match.equipeExterieur.id,
        );
        if (newJoueur != null) {
          joueurs.add(newJoueur);
        }
      }
    }

    return joueurs;
  }

  static Future<List<Joueur>> getMatchPlayersModels(
    List<MatchJoueurId> joueurs,
    String equipeId,
  ) async {
    List<Joueur> joueursModels = [];

    for (MatchJoueurId joueur in joueurs) {
      Joueur? joueurDejaExistant = await RepositoryProvider.joueurRepository
          .fetchJoueurById(joueur.joueurId);
      if (joueurDejaExistant == null ||
          joueurDejaExistant.equipeId != equipeId) {
        if (joueurDejaExistant != null &&
            joueurDejaExistant.equipeId != equipeId) {
          print(
              "${joueurDejaExistant.fullName} a changé d'équipe !! (de ${joueurDejaExistant.equipeId} à $equipeId)");
        }
        List<dynamic> data = await getDataFromApi(
          "players/profiles",
          params: {"player": joueur.joueurId},
        );
        List<dynamic> playerTeams = await getDataFromApi(
          "players/squads",
          params: {"player": joueur.joueurId},
        );
        if (data.isNotEmpty) {
          Map<String, dynamic>? player = data[0]?['player'];
          if (player != null) {
            final newJoueur = await constructPlayerFromJson(
              player,
              playerTeams,
              equipeId,
            );
            joueursModels.add(newJoueur);
          }
        }
      }
    }
    return joueursModels;
  }

  static Future<List<Joueur>> getJoueursFromMatchModelId(
      MatchModelId matchModelId) async {
    if (matchModelId.date.isAfter(DateTime.now())) return [];
    Map<String, List<dynamic>> players = await getMatchPlayers(
      matchModelId.id,
      equipeDomicileId: matchModelId.equipeDomicileId,
      equipeExterieurId: matchModelId.equipeExterieurId,
    );

    List<Joueur> joueurs = [];

    List<MatchJoueurId>? equipeDomicilePlayers =
        players["equipeDomicilePlayers"] as List<MatchJoueurId>?;
    List<MatchJoueurId>? equipeExterieurPlayers =
        players["equipeExterieurPlayers"] as List<MatchJoueurId>?;
    if (equipeDomicilePlayers != null) {
      joueurs += await getMatchPlayersModels(
        equipeDomicilePlayers,
        matchModelId.equipeDomicileId,
      );
    }
    if (equipeExterieurPlayers != null) {
      joueurs += await getMatchPlayersModels(
        equipeExterieurPlayers,
        matchModelId.equipeExterieurId,
      );
    }
    return joueurs;
  }

  static List<ButId> updateButInList(List<ButId> initialList, ButId newBut) {
    List<ButId> newList = List<ButId>.from(initialList);
    for (int i = 0; i < initialList.length; i++) {
      ButId but = initialList[i];
      if (but.buteurId == newBut.buteurId &&
          but.minute == newBut.minute &&
          but.passeurId == newBut.passeurId) {
        newList[i] = newBut;
        return newList;
      }
    }
    return newList;
  }

  static Future<void> updateMatchOwnGoalPenaltyAndStadiumNames(
      MatchModelId match) async {
    String? refereeName;
    String? stadiumName;
    List<dynamic> data = await getDataFromApi(
      "fixtures",
      params: {"id": match.id},
    );
    if (data.isNotEmpty) {
      refereeName = data[0]?['fixture']?['referee'];
      stadiumName = data[0]?['fixture']?['venue']?['name'];
    }
    Map<String, List<dynamic>> matchPlayers = await getMatchPlayers(
      match.id,
      equipeDomicileId: match.equipeDomicileId,
      equipeExterieurId: match.equipeExterieurId,
    );
    List<ButId>? butsDomicile =
        matchPlayers['equipeDomicileButs'] as List<ButId>?;
    List<ButId>? butsExterieur =
        matchPlayers['equipeExterieurButs'] as List<ButId>?;

    if (butsDomicile != null) {
      for (ButId but in butsDomicile) {
        Joueur? joueurExiste = await RepositoryProvider.joueurRepository
            .fetchJoueurById(but.buteurId);
        if (joueurExiste == null) {
          Joueur? newJoueur = await createJoueurFromJson(
            but.buteurId,
            match.equipeDomicileId,
          );
          if (newJoueur != null) {
            await RepositoryProvider.joueurRepository.addJoueur(newJoueur);
          }
        }
      }
    }
    if (butsExterieur != null) {
      for (ButId but in butsExterieur) {
        Joueur? joueurExiste = await RepositoryProvider.joueurRepository
            .fetchJoueurById(but.buteurId);
        if (joueurExiste == null) {
          Joueur? newJoueur = await createJoueurFromJson(
            but.buteurId,
            match.equipeExterieurId,
          );
          if (newJoueur != null) {
            await RepositoryProvider.joueurRepository.addJoueur(newJoueur);
          }
        }
      }
    }

    await RepositoryProvider.matchRepository.updateField(
      matchId: match.id,
      refereeName: refereeName,
      stadiumName: stadiumName,
      butsEquipeDomicileId: butsDomicile,
      butsEquipeExterieurId: butsExterieur,
    );
  }

  static Future<void> enleverToutesLesDonneesDeUser({
    required String userId,
    required bool enleverMatchs,
    required bool enleverFriendships,
    required bool enleverWatchTogether,
    required bool enleverPreferences,
    required bool enleverNotifications,
  }) async {
    if (enleverMatchs) {
      List<String> matchsRegardes =
          await RepositoryProvider.userRepository.getUserMatchsRegardesId(
        userId: userId,
        matchsPasRegardes: true,
      );
      print("nombre de matchs regardés : ${matchsRegardes.length}");
      for (String matchId in matchsRegardes) {
        MatchModel? match =
            await RepositoryProvider.matchRepository.fetchMatchById(matchId);
        if (match == null) {
          print("match $matchId non trouvé dans la base de données");
          continue;
        }
        await match.enleverNote(userId: userId);
        print(
            "note enlevée : ${match.equipeDomicile.nom} vs ${match.equipeExterieur.nom}");
        await match.enleverVote(userId: userId);
        print(
            "vote enlevé : ${match.equipeDomicile.nom} vs ${match.equipeExterieur.nom}");

        if (enleverWatchTogether) {
          List<WatchTogether> friendsWatchedWith = await RepositoryProvider
              .watchTogetherRepository
              .getFriendsWatchedWith(userId, matchId);
          for (WatchTogether watchTogether in friendsWatchedWith) {
            await RepositoryProvider.watchTogetherRepository
                .removeWatchTogether(
              ownerId: watchTogether.ownerId,
              friendId: watchTogether.friendId,
              matchId: matchId,
            );
            print(
                "watch together enlevé : ${match.equipeDomicile.nom} vs ${match.equipeExterieur.nom}");
          }
        }
        await RepositoryProvider.userRepository
            .removeMatchUserData(userId, matchId);
        print(
            "match user data enlevé : ${match.equipeDomicile.nom} vs ${match.equipeExterieur.nom}");
      }
    }

    if (enleverFriendships) {
      await RepositoryProvider.amitieRepository
          .removeAllFriendshipsForUser(userId);
      print("toutes les friendships enlevées");
    }

    if (enleverPreferences) {
      await RepositoryProvider.userRepository.updateOptions(
        userId: userId,
        allNotifications: true,
        comment: true,
        friendRequest: true,
        friendRequestAccepted: true,
        reaction: true,
        favoriteTeamMatch: true,
        weeklyRecap: true,
        language: LanguageOptions.french,
        theme: ThemeOptions.system,
        defaultVisionnageMatch: VisionnageMatch.tele,
      );
      print("toutes les préférences enlevées");

      await RepositoryProvider.userRepository.editProfile(
        userId: userId,
        newEquipesPrefereesId: [],
        newCompetitionsPrefereesId: [],
      );
      print("équipes et compétitions préférées enlevées");
    }

    if (enleverNotifications) {
      await RepositoryProvider.notificationRepository
          .deleteAllNotifications(userId: userId);
      print("notifications enlevées");
    }

    if (enleverWatchTogether) {
      await RepositoryProvider.watchTogetherRepository
          .removeAllWatchTogetherForUser(userId: userId);
      print("watch together enlevés");
    }
  }

  static Future<void> updateAllCompetitionsPopularite() async {
    List<AppUser> allUsers =
        await RepositoryProvider.userRepository.fetchAllUsers();
    Map<String, int> competitionIdToCount = {};
    for (AppUser user in allUsers) {
      for (String competitionId in user.competitionsPrefereesId) {
        if (competitionIdToCount.containsKey(competitionId)) {
          competitionIdToCount[competitionId] =
              competitionIdToCount[competitionId]! + 1;
        } else {
          competitionIdToCount[competitionId] = 1;
        }
      }
    }
    List<Competition> allCompetitions =
        await RepositoryProvider.competitionRepository.fetchAllCompetitions();
    for (Competition competition in allCompetitions) {
      int newPopularite = competitionIdToCount[competition.id] ?? 0;
      await RepositoryProvider.competitionRepository.updateCompetition(
        id: competition.id,
        popularite: newPopularite,
      );
      print("popularité mise à jour pour ${competition.nom} : $newPopularite");
    }
  }

  static Future<void> countEquipesPreferees() async {
    List<AppUser> allUsers =
        await RepositoryProvider.userRepository.fetchAllUsers();
    Map<String, int> equipesPrefereesCount = {};
    for (AppUser user in allUsers) {
      for (String equipeId in user.equipesPrefereesId) {
        if (equipesPrefereesCount.containsKey(equipeId)) {
          equipesPrefereesCount[equipeId] =
              equipesPrefereesCount[equipeId]! + 1;
        } else {
          equipesPrefereesCount[equipeId] = 1;
        }
      }
    }
    print(equipesPrefereesCount);
    Map<String, int> sortedEquipesPrefereesCount = Map.fromEntries(
      equipesPrefereesCount.entries.toList()
        ..sort(
          (a, b) => b.value.compareTo(a.value),
        ),
    );
    print(sortedEquipesPrefereesCount);
    for (final entry in sortedEquipesPrefereesCount.entries) {
      String equipeId = entry.key;
      int count = entry.value;

      Equipe? equipe =
          await RepositoryProvider.equipeRepository.fetchEquipeById(equipeId);

      print("Equipe ${equipe?.nom} ($equipeId) : $count préférences");
    }
  }

  static Future<Equipe?> createEquipeFromApiId({
    required String teamApiId,
    required String season,
    bool overwrite = false,
  }) async {
    if (!overwrite) {
      final existing =
          await RepositoryProvider.equipeRepository.fetchEquipeById(teamApiId);
      if (existing != null) {
        print("Équipe $teamApiId déjà présente en base (${existing.nom}), "
            "utilise overwrite: true pour la remplacer.");
        return existing;
      }
    }

    List<dynamic> data = await getDataFromApi(
      "teams",
      params: {"id": teamApiId},
    );

    if (data.isEmpty) {
      print("ERREUR DATA EMPTY: impossible de trouver l'équipe $teamApiId");
      return null;
    }

    final teamData = data[0];
    final String id = teamData['team']['id'].toString();
    final String nom = teamData['team']['name'].toString();
    final String code = teamData['team']['code'].toString();
    final String logoPath = teamData['team']['logo'].toString();
    final bool national = teamData['team']['national'] ?? false;

    int saisonCouleurs = int.parse(season);
    Map<String, String?> couleurs = {"principale": null, "secondaire": null};
    while ((couleurs["principale"] == null && couleurs["secondaire"] == null) &&
        saisonCouleurs >= int.parse(season) - 10) {
      couleurs = await getTeamColors(id, saisonCouleurs.toString());
      saisonCouleurs--;
    }

    final Equipe newEquipe = Equipe(
      id: id,
      nom: nom,
      code: code,
      logoPath: logoPath,
      couleurPrincipale: couleurs["principale"],
      couleurSecondaire: couleurs["secondaire"],
      national: national,
    );

    await RepositoryProvider.equipeRepository.addEquipe(newEquipe);
    print("Équipe créée : $nom ($id) — couleurs: ${couleurs['principale']} / "
        "${couleurs['secondaire']}");
    return newEquipe;
  }

  static Future<Equipe?> getOrCreateEquipe({
    required String teamApiId,
    required String season,
  }) async {
    final existing =
        await RepositoryProvider.equipeRepository.fetchEquipeById(teamApiId);
    if (existing != null) return existing;
    return createEquipeFromApiId(teamApiId: teamApiId, season: season);
  }

  static Future<MatchModelId?> createMatchFromFixtureId(String fixtureId,
      {bool seulementUpdateCompos = false}) async {
    List<dynamic> data = await getDataFromApi(
      "fixtures",
      params: {"id": fixtureId},
    );

    if (data.isEmpty) {
      print("ERREUR DATA EMPTY: fixture $fixtureId introuvable");
      return null;
    }

    final MatchModelId newMatch = await getMatchFromData(data[0]);
    if (seulementUpdateCompos) {
      await RepositoryProvider.matchRepository.updateField(
        matchId: newMatch.id,
        // joueursEquipeDomicileId: newMatch.joueursEquipeDomicileId,
        // joueursEquipeExterieurId: newMatch.joueursEquipeExterieurId,
        penaltyEquipeDomicile: newMatch.penaltyEquipeDomicile,
        penaltyEquipeExterieur: newMatch.penaltyEquipeExterieur,
        prolongations: newMatch.prolongations,
        // refereeName: newMatch.refereeName,
        // stadiumName: newMatch.stadiumName,
      );
      return newMatch;
    }
    await RepositoryProvider.matchRepository.addMatchModelId(newMatch);
    print("Match créé depuis fixture $fixtureId : "
        "${newMatch.equipeDomicileId} vs ${newMatch.equipeExterieurId}");
    return newMatch;
  }

  static Future<void> mettreAJourInfosMatchs(
    List<String> competitionsId,
  ) async {
    for (String competitionId in competitionsId) {
      List<dynamic> data = await getDataFromApi(
        "fixtures",
        params: {"league": competitionId, "season": "2025"},
      );
      int i = 0;
      print(data);

      for (Map<String, dynamic> match in data) {
        print("$i / ${data.length}");
        Map<String, dynamic>? fixture = match["fixture"];
        if (fixture == null) {
          print("FIXTURE NULL !!!!!!");
        }
        int? matchId = fixture?['id'];
        String? refereeName = fixture?['referee'];
        String? stadiumName = fixture?['venue']?['name'];
        if (refereeName == null) {
          print("REFEREE NAME NULL !!!");
          refereeName = "";
        }
        if (stadiumName == null) {
          print("STADIUM NAME NULL !!!");
          stadiumName = "";
        }
        MatchModelId? matchExistant = await RepositoryProvider.matchRepository
            .fetchMatchModelIdById(matchId.toString());
        if (matchId != null && matchExistant != null) {
          await RepositoryProvider.matchRepository.updateField(
            matchId: matchId.toString(),
            refereeName: refereeName,
            stadiumName: stadiumName,
          );
        } else {
          print("oula");
        }
        i++;
      }
    }
  }

  static Future<void> updateEquipeCouleurs({
    required String teamApiId,
    required String season,
  }) async {
    Equipe? equipe =
        await RepositoryProvider.equipeRepository.fetchEquipeById(teamApiId);
    if (equipe == null) {
      print(
          "Équipe $teamApiId introuvable en base, impossible de mettre à jour "
          "les couleurs. Crée-la d'abord avec getOrCreateEquipe.");
      return;
    }
    final Map<String, String?> couleurs =
        await getTeamColors(teamApiId, season);

    if (couleurs["principale"] == null && couleurs["secondaire"] == null) {
      print("Impossible de récupérer les couleurs pour $teamApiId / $season");
      return;
    }

    equipe = equipe.copyWith(
      couleurPrincipale: couleurs["principale"],
      couleurSecondaire: couleurs["secondaire"],
    );

    await RepositoryProvider.equipeRepository.updateEquipe(equipe);
    print("Couleurs mises à jour pour $teamApiId : "
        "${couleurs['principale']} / ${couleurs['secondaire']}");
  }

  static Future<void> updateJoueurEquipe({
    required String joueurId,
    required String newEquipeId,
  }) async {
    final Joueur? joueur =
        await RepositoryProvider.joueurRepository.fetchJoueurById(joueurId);
    if (joueur == null) {
      print("Joueur $joueurId introuvable en base");
      return;
    }
    final Joueur updated = joueur.copyWith(equipeId: newEquipeId);
    await RepositoryProvider.joueurRepository.updateJoueur(updated);
    print("Joueur ${joueur.fullName} (${joueur.id}) : équipe mise à jour "
        "${joueur.equipeId} → $newEquipeId");
  }

  static Future<void> updateEquipesDeTousLesJoueurs() async {
    List<MatchModelId> allMatches =
        await RepositoryProvider.matchRepository.fetchAllMatchesId();
    allMatches.sort((a, b) => a.date.compareTo(b.date));

    // joueurId -> {equipeId?, equipeNationaleId?}
    final Map<String, Map<String, String?>> playerUpdates = {};

    void applyClub(String joueurId, String equipeId) {
      playerUpdates.putIfAbsent(joueurId, () => {});
      playerUpdates[joueurId]!['equipeId'] = equipeId;
    }

    void applyNational(String joueurId, String equipeNationaleId) {
      playerUpdates.putIfAbsent(joueurId, () => {});
      playerUpdates[joueurId]!['equipeNationaleId'] = equipeNationaleId;
    }

    int i = 0;

    for (MatchModelId match in allMatches) {
      print("première boucle : $i / ${allMatches.length}");
      bool national = match.competitionId == "1" || match.competitionId == "10";

      for (MatchJoueurId matchJoueur in match.joueursEquipeDomicileId) {
        if (matchJoueur.joueurId == "null") continue;
        if (national) {
          applyNational(matchJoueur.joueurId, match.equipeDomicileId);
        } else {
          applyClub(matchJoueur.joueurId, match.equipeDomicileId);
        }
      }

      for (MatchJoueurId matchJoueur in match.joueursEquipeExterieurId) {
        if (matchJoueur.joueurId == "null") continue;
        if (national) {
          applyNational(matchJoueur.joueurId, match.equipeExterieurId);
        } else {
          applyClub(matchJoueur.joueurId, match.equipeExterieurId);
        }
      }
      i++;
    }

    print("Joueurs à mettre à jour : ${playerUpdates.length}");

    // 🔹 Une seule requête pour connaître tous les joueurs qui existent réellement
    final existingSnapshot =
        await FirebaseFirestore.instance.collection('joueurs').get();
    final existingIds = existingSnapshot.docs.map((d) => d.id).toSet();

    // 🔹 On sépare ce qui peut être écrit de ce qui doit être ignoré
    final missingIds = <String>[];
    playerUpdates.removeWhere((joueurId, _) {
      final exists = existingIds.contains(joueurId);
      if (!exists) missingIds.add(joueurId);
      return !exists;
    });

    print("Joueurs ignorés (absents en base) : ${missingIds.length}");
    if (missingIds.isNotEmpty) {
      print(missingIds.join(', '));
    }

    // 🔹 Écriture en batches de 500 (limite Firestore)
    final entries = playerUpdates.entries.toList();
    const batchSize = 500;

    for (int start = 0; start < entries.length; start += batchSize) {
      final chunk = entries.skip(start).take(batchSize);
      final batch = FirebaseFirestore.instance.batch();

      for (final entry in chunk) {
        final joueurId = entry.key;
        final updates = entry.value;

        batch.update(
          FirebaseFirestore.instance.collection('joueurs').doc(joueurId),
          updates,
        );
      }

      await batch.commit();
      print("Batch ${(start / batchSize).floor() + 1} committed "
          "(${chunk.length} joueurs)");
    }

    print("✅ Correction terminée");
  }

  static Future<void> deleteMatch(String matchId) async {
    await RepositoryProvider.matchRepository.deleteMatch(matchId);
    print("Match $matchId supprimé");
  }

  static Future<void> deleteEquipe(String equipeId) async {
    await RepositoryProvider.equipeRepository.deleteEquipe(equipeId);
    print("Équipe $equipeId supprimée");
  }

  static Future<void> inspectEquipeFromApi(String teamApiId) async {
    List<dynamic> data = await getDataFromApi(
      "teams",
      params: {"id": teamApiId},
    );
    if (data.isEmpty) {
      print("Aucune équipe trouvée pour l'ID $teamApiId");
      return;
    }
    print("=== Infos API pour l'équipe $teamApiId ===");
    print(const JsonEncoder.withIndent('  ').convert(data[0]));
  }

  static Future<void> inspectFixtureFromApi(String fixtureId) async {
    List<dynamic> data = await getDataFromApi(
      "fixtures",
      params: {"id": fixtureId},
    );
    if (data.isEmpty) {
      print("Aucun fixture trouvé pour l'ID $fixtureId");
      return;
    }
    print("=== Infos API pour le fixture $fixtureId ===");
    print(const JsonEncoder.withIndent('  ').convert(data[0]));
  }

  // ─────────────────────────────────────────────
  // SECTION MANUEL / DEBUG
  // Fonctions de mise à jour sans appel API.
  // À utiliser uniquement en mode debug (kDebugMode).
  // ─────────────────────────────────────────────

  static Future<void> manualUpdateScore(
    String matchId, {
    required int scoreD,
    required int scoreE,
    int? liveMinute,
  }) async {
    await RepositoryProvider.matchRepository.updateField(
      matchId: matchId,
      scoreEquipeDomicile: scoreD,
      scoreEquipeExterieur: scoreE,
      liveMinute: liveMinute,
    );
    print('✅ Score mis à jour : $scoreD - $scoreE');
  }

  static Future<void> manualUpdateMatchInfo(
    String matchId, {
    String? stadiumName,
    String? refereeName,
  }) async {
    await RepositoryProvider.matchRepository.updateField(
      matchId: matchId,
      stadiumName: stadiumName,
      refereeName: refereeName,
    );
    print(
        '✅ Infos match mises à jour : stade=$stadiumName, arbitre=$refereeName');
  }

  static Future<void> manualUpdateLineup(
    String matchId, {
    required List<MatchJoueurId> domicile,
    required List<MatchJoueurId> exterieur,
  }) async {
    await RepositoryProvider.matchRepository.updateField(
      matchId: matchId,
      joueursEquipeDomicileId: domicile,
      joueursEquipeExterieurId: exterieur,
    );
    print('✅ Compo mise à jour : ${domicile.length} joueurs domicile, '
        '${exterieur.length} joueurs extérieur');
  }

  static Future<void> manualUpdateGoals(
    String matchId, {
    required List<ButId> butsD,
    required List<ButId> butsE,
  }) async {
    await RepositoryProvider.matchRepository.updateField(
      matchId: matchId,
      butsEquipeDomicileId: butsD,
      butsEquipeExterieurId: butsE,
    );
    print(
        '✅ Buts mis à jour : ${butsD.length} domicile, ${butsE.length} extérieur');
  }

  static Future<void> manualUpdateSubstitution(
    String matchId, {
    required String joueurEntrantId,
  }) async {
    MatchModelId? match =
        await RepositoryProvider.matchRepository.fetchMatchModelIdById(matchId);
    if (match == null) {
      print('❌ Match $matchId introuvable');
      return;
    }

    bool found = false;

    final domicile = match.joueursEquipeDomicileId.map((j) {
      if (j.joueurId == joueurEntrantId) {
        found = true;
        return j.copyWith(hasPlayed: true);
      }
      return j;
    }).toList();

    final exterieur = match.joueursEquipeExterieurId.map((j) {
      if (j.joueurId == joueurEntrantId) {
        found = true;
        return j.copyWith(hasPlayed: true);
      }
      return j;
    }).toList();

    if (!found) {
      print(
          '❌ Joueur $joueurEntrantId introuvable dans la compo du match $matchId');
      return;
    }

    await RepositoryProvider.matchRepository.updateField(
      matchId: matchId,
      joueursEquipeDomicileId: domicile,
      joueursEquipeExterieurId: exterieur,
    );
    print('✅ Joueur $joueurEntrantId marqué comme entré en jeu');
  }
}
