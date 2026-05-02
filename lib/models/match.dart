import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/string/parse_map.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/views/details/match_details_page.dart';

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
  final int? liveMinute;
  final int? extraTime;
  final int? saison;
  final Equipe equipeDomicile;
  final Equipe equipeExterieur;
  final Competition competition;
  final DateTime date;
  String? refereeName;
  String? stadiumName;
  final int scoreEquipeDomicile;
  final int scoreEquipeExterieur;
  final List<But> butsEquipeDomicile;
  final List<But> butsEquipeExterieur;
  final List<MatchJoueur> joueursEquipeDomicile;
  final List<MatchJoueur> joueursEquipeExterieur;
  Map<String, String> mvpVotes;
  Map<String, int> notes;

  MatchModel(
      {required this.id,
      required this.status,
      this.liveMinute,
      this.extraTime,
      this.saison,
      required this.equipeDomicile,
      required this.equipeExterieur,
      required this.competition,
      required this.date,
      this.refereeName,
      this.stadiumName,
      required this.scoreEquipeDomicile,
      required this.scoreEquipeExterieur,
      required this.joueursEquipeDomicile,
      required this.joueursEquipeExterieur,
      List<But>? butsEquipeDomicile,
      List<But>? butsEquipeExterieur,
      Map<String, String>? mvpVotes,
      Map<String, int>? notes})
      : butsEquipeDomicile = butsEquipeDomicile ?? [],
        butsEquipeExterieur = butsEquipeExterieur ?? [],
        mvpVotes = mvpVotes ?? {},
        notes = notes ?? {};

  bool get isFinished => status == MatchStatus.finished;
  bool get isLive => status == MatchStatus.live;
  bool get isScheduled => status == MatchStatus.scheduled;

  @override
  Future<String?> getColor() async {
    return null;
  }

  @override
  GestureTapCallback? onTap(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchDetailsPage(match: this),
        ),
      );
    };
  }

  Widget compactMatchDisplay(
      {num? value, double logoSize = 32, TextStyle? textStyle}) {
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
                      ? CachedNetworkImage(
                          imageUrl: equipeDomicile.logoPath!,
                          width: logoSize,
                          height: logoSize,
                          errorWidget: (context, error, stackTrace) => Icon(
                            Icons.shield,
                            color: ColorPalette.textPrimary(context),
                          ),
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
                      ? CachedNetworkImage(
                          imageUrl: equipeExterieur.logoPath!,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                          errorWidget: (context, error, stackTrace) => Icon(
                            Icons.shield,
                            color: ColorPalette.textPrimary(context),
                          ),
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
        if (value != null)
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  @override
  Widget buildPodiumCard({
    required BuildContext context,
    required PodiumContext podium,
    bool logoBackground = true,
  }) {
    final isFirst = podium.isFirst;

    final logoSize = isFirst ? 28.0 : 24.0;
    final scoreStyle = TextStyle(
      fontSize: isFirst ? 16 : 14,
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
                    CachedNetworkImage(
                      imageUrl: equipeDomicile.logoPath!,
                      width: logoSize,
                      height: logoSize,
                      errorWidget: (context, error, stackTrace) => Icon(
                        Icons.shield,
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),
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
                    CachedNetworkImage(
                      imageUrl: equipeExterieur.logoPath!,
                      width: logoSize,
                      height: logoSize,
                      errorWidget: (context, error, stackTrace) => Icon(
                        Icons.shield,
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),
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
                      ? CachedNetworkImage(
                          imageUrl: equipeDomicile.logoPath!,
                          width: 24,
                          height: 24,
                          errorWidget: (context, error, stackTrace) => Icon(
                            Icons.shield,
                            color: ColorPalette.textPrimary(context),
                          ),
                        )
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
                      ? CachedNetworkImage(
                          imageUrl: equipeExterieur.logoPath!,
                          width: 24,
                          height: 24,
                          errorWidget: (context, error, stackTrace) => Icon(
                            Icons.shield,
                            color: ColorPalette.textPrimary(context),
                          ),
                        )
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
    bool logoBackground = true,
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
              ? CachedNetworkImage(
                  imageUrl: equipeDomicile.logoPath!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  errorWidget: (context, error, stackTrace) => Icon(
                    Icons.shield,
                    color: ColorPalette.textPrimary(context),
                  ),
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
              ? CachedNetworkImage(
                  imageUrl: equipeExterieur.logoPath!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  errorWidget: (context, error, stackTrace) => Icon(
                    Icons.shield,
                    color: ColorPalette.textPrimary(context),
                  ),
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
      return compactMatchDisplay(
        value: podium.value,
        logoSize: logoSize,
        textStyle: textStyle,
      );
    }
  }

  @override
  Widget buildDetailsLine({
    required BuildContext context,
    required PodiumContext podium,
    bool large = true,
  }) {
    final logoSize = large ? 32.0 : 20.0;
    final textStyle = TextStyle(
      fontSize: large ? 16 : 14,
      fontWeight: large ? FontWeight.bold : FontWeight.normal,
      color: ColorPalette.textPrimary(context),
    );

    if (large) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            equipeDomicile.code ??
                equipeDomicile.nomCourt ??
                equipeDomicile.nom,
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
            equipeId: equipeDomicile.id,
            size: logoSize,
            clickable: false,
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
            equipeId: equipeExterieur.id,
            size: logoSize,
            clickable: false,
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
    } else {
      return compactMatchDisplay(
        logoSize: logoSize,
        textStyle: textStyle,
      );
    }
  }

  int getNbViewers() {
    return mvpVotes.length > notes.length ? mvpVotes.length : notes.length;
  }

  //////////////////// NOTE DU MATCH ////////////////////

  double getNoteMoyenne() {
    if (notes.isEmpty) return -1.0;

    final allNotes = notes.values;
    final somme = allNotes.reduce((a, b) => a + b);
    final moyenne = somme / allNotes.length;

    return moyenne;
  }

  Future<void> noterMatch({
    required String userId,
    required int? note,
  }) async {
    if (note != null) {
      notes[userId] = note;
      RepositoryProvider.matchRepository.noterMatch(id, userId, date, note);
    }
  }

  Future<void> enleverNote({required String userId}) async {
    notes.remove(userId);
    RepositoryProvider.matchRepository.enleverNote(id, userId);
  }

  ///////////////////////// MVP /////////////////////////

  Future<void> voterPourMVP({
    required String userId,
    required String? joueurId,
  }) async {
    if (joueurId != null) {
      mvpVotes[userId] = joueurId;
      await RepositoryProvider.matchRepository
          .voterPourMVP(id, userId, date, joueurId);
    }
  }

  Future<void> enleverVote({required String userId}) async {
    mvpVotes.remove(userId);
    await RepositoryProvider.matchRepository.enleverVote(id, userId);
  }

  Map<String, int> getAllVoteCounts() {
    Map<String, int> voteCounts = <String, int>{};
    for (final playerId in mvpVotes.values) {
      voteCounts[playerId] = (voteCounts[playerId] ?? 0) + 1;
    }
    return voteCounts;
  }

  String? getMvpId() {
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

    return mvpId;
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

  int getPlayerNbButs(String playerId) {
    int count = 0;
    for (But but in [...butsEquipeDomicile, ...butsEquipeExterieur]) {
      if (but.buteur.id == playerId) {
        count++;
      }
    }
    return count;
  }

  int getPlayerNbPassesDe(String playerId) {
    int count = 0;
    for (But but in [...butsEquipeDomicile, ...butsEquipeExterieur]) {
      if (but.passeur?.id == playerId) {
        count++;
      }
    }
    return count;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'liveMinute': liveMinute,
        'extraTime': extraTime,
        'competitionId': competition.id,
        'date': date.toIso8601String(),
        'refereeName': refereeName,
        'stadiumName': stadiumName,
        'scoreEquipeDomicile': scoreEquipeDomicile,
        'scoreEquipeExterieur': scoreEquipeExterieur,
        'equipeDomicileId': equipeDomicile.id,
        'equipeExterieurId': equipeExterieur.id,
        'saison': saison,
        'joueursEquipeDomicile':
            joueursEquipeDomicile.map((j) => j.toJson()).toList(),
        'joueursEquipeExterieur':
            joueursEquipeExterieur.map((j) => j.toJson()).toList(),
        'butsEquipeDomicile':
            butsEquipeDomicile.map((b) => b.toJson()).toList(),
        'butsEquipeExterieur':
            butsEquipeExterieur.map((b) => b.toJson()).toList(),
        'mvpVotes': mvpVotes,
        'notes': notes,
      };

  static Future<MatchModel> fromMatchId(MatchModelId data) async {
    final competition = await RepositoryProvider.competitionRepository
        .fetchCompetitionById(data.competitionId);

    final equipeDom = await RepositoryProvider.equipeRepository
        .fetchEquipeById(data.equipeDomicileId);

    final equipeExt = await RepositoryProvider.equipeRepository
        .fetchEquipeById(data.equipeExterieurId);

    List<MatchJoueur> joueursDom = await Future.wait(
      data.joueursEquipeDomicileId.map(MatchJoueur.fromMatchJoueurId),
    );

    List<MatchJoueur> joueursExt = await Future.wait(
      data.joueursEquipeExterieurId.map(MatchJoueur.fromMatchJoueurId),
    );

    final butsDom = await Future.wait(
      data.butsEquipeDomicileId.map(But.fromButId),
    );

    final butsExt = await Future.wait(
      data.butsEquipeExterieurId.map(But.fromButId),
    );

    return MatchModel(
      id: data.id,
      status: data.status,
      liveMinute: data.liveMinute,
      extraTime: data.extraTime,
      saison: data.saison,
      competition: competition!,
      equipeDomicile: equipeDom!,
      equipeExterieur: equipeExt!,
      date: data.date,
      refereeName: data.refereeName,
      stadiumName: data.stadiumName,
      scoreEquipeDomicile: data.scoreEquipeDomicile,
      scoreEquipeExterieur: data.scoreEquipeExterieur,
      joueursEquipeDomicile: joueursDom,
      joueursEquipeExterieur: joueursExt,
      butsEquipeDomicile: butsDom,
      butsEquipeExterieur: butsExt,
      mvpVotes: data.mvpVotes,
      notes: data.notes,
    );
  }

  @override
  String toString() =>
      '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom} [${status.name}]';
}

class MatchModelId {
  final String id;
  final MatchStatus status;
  final int? liveMinute;
  final int? extraTime;
  final int? saison;
  final String equipeDomicileId;
  final String equipeExterieurId;
  final String competitionId;
  final DateTime date;
  String? refereeName;
  String? stadiumName;
  final int scoreEquipeDomicile;
  final int scoreEquipeExterieur;
  final List<ButId> butsEquipeDomicileId;
  final List<ButId> butsEquipeExterieurId;
  final List<MatchJoueurId> joueursEquipeDomicileId;
  final List<MatchJoueurId> joueursEquipeExterieurId;
  Map<String, String> mvpVotes;
  Map<String, int> notes;

  MatchModelId(
      {required this.id,
      required this.status,
      this.liveMinute,
      this.extraTime,
      this.saison,
      required this.equipeDomicileId,
      required this.equipeExterieurId,
      required this.competitionId,
      required this.date,
      this.refereeName,
      this.stadiumName,
      required this.scoreEquipeDomicile,
      required this.scoreEquipeExterieur,
      required this.joueursEquipeDomicileId,
      required this.joueursEquipeExterieurId,
      List<ButId>? butsEquipeDomicileId,
      List<ButId>? butsEquipeExterieurId,
      Map<String, String>? mvpVotes,
      Map<String, int>? notes})
      : butsEquipeDomicileId = butsEquipeDomicileId ?? [],
        butsEquipeExterieurId = butsEquipeExterieurId ?? [],
        mvpVotes = mvpVotes ?? {},
        notes = notes ?? {};

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'liveMinute': liveMinute,
        'extraTime': extraTime,
        'saison': saison,
        'competitionId': competitionId,
        'date': date,
        'refereeName': refereeName,
        'stadiumName': stadiumName,
        'scoreEquipeDomicile': scoreEquipeDomicile,
        'scoreEquipeExterieur': scoreEquipeExterieur,
        'equipeDomicileId': equipeDomicileId,
        'equipeExterieurId': equipeExterieurId,
        'joueursEquipeDomicile':
            joueursEquipeDomicileId.map((e) => e.toJson()).toList(),
        'joueursEquipeExterieur':
            joueursEquipeExterieurId.map((e) => e.toJson()).toList(),
        'butsEquipeDomicile':
            butsEquipeDomicileId.map((e) => e.toJson()).toList(),
        'butsEquipeExterieur':
            butsEquipeExterieurId.map((e) => e.toJson()).toList(),
        if (mvpVotes.isNotEmpty) 'mvpVotes': mvpVotes,
        if (notes.isNotEmpty) 'notes': notes,
      };

  factory MatchModelId.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final status = MatchStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MatchStatus.scheduled,
    );
    DateTime? date;
    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      date = DateTime.tryParse(json['date']);
    } else {
      date = DateTime.now();
    }

    return MatchModelId(
      id: id,
      status: status,
      competitionId: json['competitionId'],
      equipeDomicileId: json['equipeDomicileId'],
      equipeExterieurId: json['equipeExterieurId'],
      date: date!,
      refereeName: json['refereeName'],
      stadiumName: json['stadiumName'],
      scoreEquipeDomicile: json['scoreEquipeDomicile'] ?? 0,
      scoreEquipeExterieur: json['scoreEquipeExterieur'] ?? 0,
      liveMinute: json['liveMinute'] as int?,
      extraTime: json['extraTime'] as int?,
      saison: json['saison'] as int?,
      joueursEquipeDomicileId: (json['joueursEquipeDomicile'] as List? ?? [])
          .map((e) => MatchJoueurId.fromJson(e))
          .toList(),
      joueursEquipeExterieurId: (json['joueursEquipeExterieur'] as List? ?? [])
          .map((e) => MatchJoueurId.fromJson(e))
          .toList(),
      butsEquipeDomicileId: (json['butsEquipeDomicile'] as List? ?? [])
          .map((e) => ButId.fromJson(e))
          .toList(),
      butsEquipeExterieurId: (json['butsEquipeExterieur'] as List? ?? [])
          .map((e) => ButId.fromJson(e))
          .toList(),
      mvpVotes: parseStringMap(json['mvpVotes']),
      notes: parseIntMap(json['notes']),
    );
  }
}
