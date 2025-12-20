import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';

import 'equipe.dart';
import 'but.dart';

enum MatchStatus {
  scheduled,
  live,
  finished,
  postponed,
}

class MatchModel {
  final String id;
  final MatchStatus status; // Nouveau champ
  final String? liveMinute; // Nouveau champ
  final Equipe equipeDomicile;
  final Equipe equipeExterieur;
  final String competition;
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
      required this.status, // Requis
      required this.equipeDomicile,
      required this.equipeExterieur,
      required this.competition,
      required this.date,
      this.liveMinute, // Optionnel
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
      RepositoryProvider.matchRepository.noterMatch(id, userId, note);
    }
  }

  Future<void> enleverNote({required String userId}) async {
    notesDuMatch.remove(userId);
    RepositoryProvider.matchRepository.noterMatch(id, userId, null);
  }

  ///////////////////////// MVP /////////////////////////

  Future<void> voterPourMVP({
    required String userId,
    required String? joueurId,
  }) async {
    if (joueurId != null) {
      mvpVotes[userId] = joueurId;
      RepositoryProvider.matchRepository.voterPourMVP(id, userId, joueurId);
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
        'status': status.name, // Sauvegarde "scheduled", "live", etc.
        'liveMinute': liveMinute,
        'competition': competition,
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
    String statusString = json['status'] as String? ?? 'scheduled';

    MatchStatus status = MatchStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => MatchStatus.scheduled,
    );

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
        competition: json['competition'] as String? ?? '',
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
  }

  @override
  String toString() =>
      '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom} [${status.name}]';
}
