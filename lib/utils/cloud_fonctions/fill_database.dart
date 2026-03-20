import 'package:scorescope/models/but.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
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
    final token = dotenv.env['API_FOOTBALL_TOKEN'];
    final stringParams = params != null
        ? "?${params.entries.map((e) => "${e.key}=${e.value}").join("&")}"
        : "";
    final url =
        Uri.parse("https://v3.football.api-sports.io/$endpoint$stringParams");

    final response = await http.get(
      url,
      headers: {
        "X-RapidAPI-Key": token ?? "",
        "X-RapidAPI-Host": "v3.football.api-sports.io",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData?["errors"] is List &&
          (jsonData?["errors"] as List).isEmpty) {
        return jsonData['response'] ?? [];
      }
      Map<String, dynamic>? errors = jsonData?["errors"];
      if (errors != null && errors.isNotEmpty) {
        if (errors["rateLimit"] != null) {
          print("ERREUR STOP : ${errors["rateLimit"]}");
          await Future.delayed(const Duration(minutes: 1));
          return await getDataFromApi(endpoint, params: params);
        }
      }
      return jsonData['response'] ?? [];
    } else {
      throw Exception(
        "Erreur API : ${response.statusCode} ${response.reasonPhrase}",
      );
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
            hasPlayed: isFromStartXI);
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
        final List<dynamic>? startXIDomicile = lineup[0]?['startXI'];
        final List<dynamic>? startXIExterieur = lineup[1]?['startXI'];
        final List<dynamic>? substitutesDomicile = lineup[0]?['substitutes'];
        final List<dynamic>? substitutesExterieur = lineup[1]?['substitutes'];
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
      String competitionId, String season) async {
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
          equipes.add(newEquipe);
        }
      }
    }
    return equipes;
  }

  static Future<List<MatchModelId>> getMatchs(
      String competitionId, String season) async {
    List<MatchModelId> matchs = [];

    List<dynamic> data = await getDataFromApi(
      "fixtures",
      params: {"league": competitionId, "season": season},
    );
    if (data.isEmpty) {
      print("ERREUR DATA EMPTY: pour $competitionId, $season");
    } else {
      print("data bien récupérée pour $competitionId, $season : $data");
      for (Map<String, dynamic> matchData in data) {
        final String id = matchData['fixture']['id'].toString();
        final MatchStatus status = getMatchStatusFromCode(
            matchData['fixture']['status']['short'].toString());
        final String equipeDomicileId =
            matchData['teams']['home']['id'].toString();
        final String equipeExterieurId =
            matchData['teams']['away']['id'].toString();
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(
            matchData['fixture']['timestamp'] * 1000);
        final String? refereeName = data[0]?['fixture']?['referee'];
        final String? stadiumName = data[0]?['fixture']?['venue']?['name'];
        final int scoreEquipeDomicile = matchData['goals']['home'] ?? 0;
        final int scoreEquipeExterieur = matchData['goals']['away'] ?? 0;
        final int? liveMinute = matchData['fixture']['status']['elapsed'];
        final int? extraTime = matchData['fixture']['status']['extra'];

        Map<String, List<dynamic>> matchPlayers = await getMatchPlayers(id,
            equipeDomicileId: equipeDomicileId,
            equipeExterieurId: equipeExterieurId);

        MatchModelId newMatch = MatchModelId(
          id: id,
          status: status,
          equipeDomicileId: equipeDomicileId,
          equipeExterieurId: equipeExterieurId,
          competitionId: competitionId,
          date: date,
          refereeName: refereeName,
          stadiumName: stadiumName,
          scoreEquipeDomicile: scoreEquipeDomicile,
          scoreEquipeExterieur: scoreEquipeExterieur,
          joueursEquipeDomicileId:
              matchPlayers['equipeDomicilePlayers'] as List<MatchJoueurId>? ??
                  [],
          joueursEquipeExterieurId:
              matchPlayers['equipeExterieurPlayers'] as List<MatchJoueurId>? ??
                  [],
          butsEquipeDomicileId:
              matchPlayers['equipeDomicileButs'] as List<ButId>? ?? [],
          butsEquipeExterieurId:
              matchPlayers['equipeExterieurButs'] as List<ButId>? ?? [],
          liveMinute: liveMinute,
          extraTime: extraTime,
          mvpVotes: {},
          notes: {},
          saison: int.parse(season),
        );
        print("add match : $equipeDomicileId vs $equipeExterieurId");
        matchs.add(newMatch);
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
}
