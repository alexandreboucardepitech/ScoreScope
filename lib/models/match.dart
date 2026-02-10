import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

import 'equipe.dart';
import 'but.dart';

enum MatchStatus {
  scheduled,
  live,
  finished,
  postponed,
}

class MatchModel implements PodiumDisplayable {
  final String id;
  final MatchStatus status;
  final String? liveMinute;
  final Equipe equipeDomicile;
  final Equipe equipeExterieur;
  final Competition competition;
  final DateTime date;
  final int scoreEquipeDomicile;
  final int scoreEquipeExterieur;
  final List<But> butsEquipeDomicile;
  final List<But> butsEquipeExterieur;
  final List<Joueur> joueursEquipeDomicile;
  final List<Joueur> joueursEquipeExterieur;
  Map<String, String> mvpVotes;
  Map<String, int> notesDuMatch;

  MatchModel(
      {required this.id,
      required this.status,
      required this.equipeDomicile,
      required this.equipeExterieur,
      required this.competition,
      required this.date,
      this.liveMinute,
      required this.scoreEquipeDomicile,
      required this.scoreEquipeExterieur,
      required this.joueursEquipeDomicile,
      required this.joueursEquipeExterieur,
      List<But>? butsEquipeDomicile,
      List<But>? butsEquipeExterieur,
      Map<String, String>? mvpVotes,
      Map<String, int>? notesDuMatch})
      : butsEquipeDomicile = butsEquipeDomicile ?? [],
        butsEquipeExterieur = butsEquipeExterieur ?? [],
        mvpVotes = mvpVotes ?? {},
        notesDuMatch = notesDuMatch ?? {};

  bool get isFinished => status == MatchStatus.finished;
  bool get isLive => status == MatchStatus.live;
  bool get isScheduled => status == MatchStatus.scheduled;

  @override
  Future<String?> getColor() async {
    return null;
  }

  @override
  Widget buildPodiumCard({
    required BuildContext context,
    required PodiumContext podium,
  }) {
    final isFirst = podium.isFirst;

    final logoSize = isFirst ? 32.0 : 28.0;
    final scoreStyle = TextStyle(
      fontSize: isFirst ? 18 : 16,
      fontWeight: FontWeight.bold,
    );

    if (isFirst) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          equipeDomicile.logoPath != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(equipeDomicile.logoPath!,
                        width: logoSize, height: logoSize),
                    if (equipeDomicile.code != null)
                      Text(
                        equipeDomicile.code!,
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 10,
                        ),
                      ),
                  ],
                )
              : Text(
                  equipeDomicile.code ??
                      equipeDomicile.nomCourt ??
                      equipeDomicile.nom,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
          Text('$scoreEquipeDomicile - $scoreEquipeExterieur',
              style: scoreStyle),
          equipeExterieur.logoPath != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(equipeExterieur.logoPath!,
                        width: logoSize, height: logoSize),
                    if (equipeExterieur.code != null)
                      Text(
                        equipeExterieur.code!,
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontSize: 10,
                        ),
                      ),
                  ],
                )
              : Text(
                  equipeExterieur.code ??
                      equipeExterieur.nomCourt ??
                      equipeExterieur.nom,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
          const SizedBox(width: 6),
          buildValueChip(
            context,
            podium.value,
            ColorPalette.accent(context),
            large: isFirst,
          ),
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
          top: podium.rank == 3 ? 2 : 0,
          bottom: podium.rank == 2 ? 2 : 0,
        ),
        child: Row(
          children: [
            Text(
              '${podium.rank}.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: podium.rank == 2 ? Colors.grey : Colors.brown,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  equipeDomicile.logoPath != null
                      ? Image.asset(equipeDomicile.logoPath!,
                          width: 24, height: 24)
                      : Text(
                          equipeDomicile.code ??
                              equipeDomicile.nomCourt ??
                              equipeDomicile.nom,
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                          ),
                        ),
                  const SizedBox(width: 4),
                  Text('$scoreEquipeDomicile - $scoreEquipeExterieur'),
                  const SizedBox(width: 4),
                  equipeExterieur.logoPath != null
                      ? Image.asset(equipeExterieur.logoPath!,
                          width: 24, height: 24)
                      : Text(
                          equipeExterieur.code ??
                              equipeExterieur.nomCourt ??
                              equipeExterieur.nom,
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                          ),
                        ),
                ],
              ),
            ),
            Text(
              podium.value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget buildPodiumRow({
    required BuildContext context,
    required PodiumContext podium,
  }) {
    final isFirst = podium.rank == 1;
    final logoSize = isFirst ? 32.0 : 20.0;
    final textStyle = TextStyle(
      fontSize: isFirst ? 16 : 14,
      fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
      color: ColorPalette.textPrimary(context),
    );

    if (isFirst) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          equipeDomicile.logoPath != null
              ? Image.asset(
                  equipeDomicile.logoPath!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                )
              : Flexible(
                  child: Text(
                    equipeDomicile.code ??
                        equipeDomicile.nomCourt ??
                        equipeDomicile.nom,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
          const SizedBox(width: 6),
          Text(
            '$scoreEquipeDomicile - $scoreEquipeExterieur',
            style: textStyle,
          ),
          const SizedBox(width: 6),
          equipeExterieur.logoPath != null
              ? Image.asset(
                  equipeExterieur.logoPath!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                )
              : Flexible(
                  child: Text(
                    equipeExterieur.code ??
                        equipeExterieur.nomCourt ??
                        equipeExterieur.nom,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorPalette.accent(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              podium.value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    equipeDomicile.logoPath != null
                        ? Image.asset(
                            equipeDomicile.logoPath!,
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          )
                        : Flexible(
                            child: Text(
                              equipeDomicile.code ??
                                  equipeDomicile.nomCourt ??
                                  equipeDomicile.nom,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                          ),
                    const SizedBox(width: 4),
                    equipeExterieur.logoPath != null
                        ? Image.asset(
                            equipeExterieur.logoPath!,
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          )
                        : Flexible(
                            child: Text(
                              equipeExterieur.code ??
                                  equipeExterieur.nomCourt ??
                                  equipeExterieur.nom,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$scoreEquipeDomicile - $scoreEquipeExterieur',
                  style: textStyle,
                ),
              ],
            ),
          ),
          Text(
            podium.value.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget buildDetailsLine(
      {required BuildContext context, required PodiumContext podium}) {
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ColorPalette.textPrimary(context),
    );

    AppUser? user = RepositoryProvider.userRepository.currentUser;

    final bool isHomeFavorite =
        user?.equipesPrefereesId.contains(equipeDomicile.id) ?? false;
    final bool isAwayFavorite =
        user?.equipesPrefereesId.contains(equipeExterieur.id) ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          equipeDomicile.code ?? equipeDomicile.nomCourt ?? equipeDomicile.nom,
          style: textStyle.copyWith(
            color: scoreEquipeDomicile > scoreEquipeExterieur
                ? ColorPalette.accent(context)
                : ColorPalette.textPrimary(context),
          ),
        ),
        const SizedBox(width: 6),
        buildTeamLogo(
          context,
          equipeDomicile.logoPath,
          isFavorite: isHomeFavorite,
          size: 28,
        ),
        const SizedBox(width: 6),
        Text(
          '$scoreEquipeDomicile - $scoreEquipeExterieur',
          style: textStyle,
        ),
        const SizedBox(width: 6),
        buildTeamLogo(
          context,
          equipeExterieur.logoPath,
          isFavorite: isAwayFavorite,
          size: 28,
        ),
        const SizedBox(width: 6),
        Text(
          equipeExterieur.code ??
              equipeExterieur.nomCourt ??
              equipeExterieur.nom,
          style: textStyle.copyWith(
            color: scoreEquipeExterieur > scoreEquipeDomicile
                ? ColorPalette.accent(context)
                : ColorPalette.textPrimary(context),
          ),
        ),
      ],
    );
  }

  int getNbViewers() {
    return mvpVotes.length > notesDuMatch.length
        ? mvpVotes.length
        : notesDuMatch.length;
  }

  //////////////////// NOTE DU MATCH ////////////////////

  double getNoteMoyenne() {
    if (notesDuMatch.isEmpty) return -1.0;

    final notes = notesDuMatch.values;
    final somme = notes.reduce((a, b) => a + b);
    final moyenne = somme / notes.length;

    return moyenne;
  }

  Future<void> noterMatch({
    required String userId,
    required int? note,
  }) async {
    if (note != null) {
      notesDuMatch[userId] = note;
      RepositoryProvider.matchRepository.noterMatch(id, userId, date, note);
    }
  }

  Future<void> enleverNote({required String userId}) async {
    notesDuMatch.remove(userId);
    RepositoryProvider.matchRepository.noterMatch(id, userId, date, null);
  }

  ///////////////////////// MVP /////////////////////////

  Future<void> voterPourMVP({
    required String userId,
    required String? joueurId,
  }) async {
    if (joueurId != null) {
      mvpVotes[userId] = joueurId;
      RepositoryProvider.matchRepository
          .voterPourMVP(id, userId, date, joueurId);
    }
  }

  Future<void> enleverVote({required String userId}) async {
    mvpVotes.remove(userId);
    RepositoryProvider.matchRepository.enleverVote(id, userId);
  }

  Map<String, int> getAllVoteCounts() {
    Map<String, int> voteCounts = <String, int>{};
    for (final playerId in mvpVotes.values) {
      voteCounts[playerId] = (voteCounts[playerId] ?? 0) + 1;
    }
    return voteCounts;
  }

  Future<Joueur?> getMvp() async {
    if (mvpVotes.isEmpty) return null;

    Map<String, int> voteCounts = getAllVoteCounts();

    String? mvpId;
    int maxVotes = -1;
    voteCounts.forEach((playerId, voteCount) {
      if (voteCount > maxVotes) {
        maxVotes = voteCount;
        mvpId = playerId;
      }
    });

    if (mvpId == null) return null;

    return await RepositoryProvider.joueurRepository.fetchJoueurById(mvpId!);
  }

  int getNbVotesById(String id) {
    Map<String, int> voteCounts = getAllVoteCounts();
    return voteCounts[id] ?? 0;
  }

  // --- MODIFICATION ICI ---
  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'liveMinute': liveMinute,
        'competitionId': competition.id,
        'date': date.toIso8601String(),
        'scoreEquipeDomicile': scoreEquipeDomicile,
        'scoreEquipeExterieur': scoreEquipeExterieur,
        'equipeDomicileId': equipeDomicile.id,
        'equipeExterieurId': equipeExterieur.id,
        'joueursEquipeDomicile':
            joueursEquipeDomicile.map((j) => j.id).toList(),
        'joueursEquipeExterieur':
            joueursEquipeExterieur.map((j) => j.id).toList(),
        'butsEquipeDomicile': butsEquipeDomicile
            .map((b) => {'joueurId': b.buteur.id, 'minute': b.minute})
            .toList(),
        'butsEquipeExterieur': butsEquipeExterieur
            .map((b) => {'joueurId': b.buteur.id, 'minute': b.minute})
            .toList(),
        'mvpVotes': mvpVotes,
        'notesDuMatch': notesDuMatch,
      };

  static Future<MatchModel> fromJson(
      {required Map<String, dynamic> json, String? matchId}) async {
    try {
      String statusString = json['status'] as String? ?? 'scheduled';

      MatchStatus status = MatchStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => MatchStatus.scheduled,
      );

      final competition = await RepositoryProvider.competitionRepository
          .fetchCompetitionById(json['competitionId']);

      final equipeDomicile = await RepositoryProvider.equipeRepository
          .fetchEquipeById(json['equipeDomicileId']);
      final equipeExterieur = await RepositoryProvider.equipeRepository
          .fetchEquipeById(json['equipeExterieurId']);

      final joueursDomicile = <Joueur>[];
      for (final id in (json['joueursEquipeDomicileId'] as List? ?? [])) {
        final joueur =
            await RepositoryProvider.joueurRepository.fetchJoueurById(id);
        if (joueur != null) joueursDomicile.add(joueur);
      }

      final joueursExterieur = <Joueur>[];
      for (final id in (json['joueursEquipeExterieurId'] as List? ?? [])) {
        final joueur =
            await RepositoryProvider.joueurRepository.fetchJoueurById(id);
        if (joueur != null) joueursExterieur.add(joueur);
      }

      final mvpVotesList = json['mvpVotes'] as List<dynamic>? ?? [];
      final mvpVotes = {
        for (var doc in mvpVotesList)
          doc['userId'] as String: doc['joueurId'] as String
      };

      final notesList = json['notesDuMatch'] as List<dynamic>? ?? [];
      final notesDuMatch = {
        for (var doc in notesList)
          doc['userId'] as String: (doc['note'] as num).toInt()
      };

      Future<List<But>> reconstructButs(List<dynamic>? butsList) async {
        if (butsList == null) return [];

        final buts = <But>[];
        for (final b in butsList) {
          final joueurId = b['buteurId'] as String?;
          Joueur? joueur;
          if (joueurId != null) {
            joueur = await RepositoryProvider.joueurRepository
                .fetchJoueurById(joueurId);
          }
          if (joueur != null) {
            buts.add(But(buteur: joueur, minute: b['minute']));
          }
        }
        return buts;
      }

      return MatchModel(
          id: matchId ?? json['id'],
          status: status,
          liveMinute: json['liveMinute'] as String?,
          competition: competition!,
          date: (json['date'] is Timestamp)
              ? (json['date'] as Timestamp).toDate()
              : DateTime.parse(
                  json['date'] as String? ?? DateTime.now().toIso8601String()),
          scoreEquipeDomicile:
              (json['scoreEquipeDomicile'] as num?)?.toInt() ?? 0,
          scoreEquipeExterieur:
              (json['scoreEquipeExterieur'] as num?)?.toInt() ?? 0,
          equipeDomicile: equipeDomicile!,
          equipeExterieur: equipeExterieur!,
          joueursEquipeDomicile: joueursDomicile,
          joueursEquipeExterieur: joueursExterieur,
          butsEquipeDomicile:
              await reconstructButs(json['butsEquipeDomicile'] as List?),
          butsEquipeExterieur:
              await reconstructButs(json['butsEquipeExterieur'] as List?),
          mvpVotes: mvpVotes,
          notesDuMatch: notesDuMatch);
    } catch (e) {
      throw Exception('Erreur lors de la conversion du match depuis JSON: $e');
    }
  }

  @override
  String toString() =>
      '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom} [${status.name}]';
}
