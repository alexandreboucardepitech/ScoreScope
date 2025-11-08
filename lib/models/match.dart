import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/Web/Web_joueur_repository.dart';
import 'package:scorescope/services/web/web_equipe_repository.dart';

import 'equipe.dart';
import 'but.dart';

class Match {
  final String? id;
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

  Match(
      {this.id,
      required this.equipeDomicile,
      required this.equipeExterieur,
      required this.competition,
      required this.date,
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

  double getNoteMoyenne() {
    if (notesDuMatch.isEmpty) return -1.0;

    final notes = notesDuMatch.values;
    final somme = notes.reduce((a, b) => a + b);
    final moyenne = somme / notes.length;

    return moyenne;
  }

  void noterMatch({required String userId, required int? note}) {
    if (note != null) notesDuMatch[userId] = note;
  }

  void voterPourMVP({required String userId, required String? joueurId}) {
    if (joueurId != null) mvpVotes[userId] = joueurId;
  }

  void enleverVote({required String userId}) {
    mvpVotes.remove(userId);
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
    voteCounts.forEach((playerId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        mvpId = playerId;
      }
    });

    if (mvpId == null) return null;

    return await WebJoueurRepository().fetchJoueurById(mvpId!);
  }

  int getNbVotesById(String id) {
    Map<String, int> voteCounts = getAllVoteCounts();
    return voteCounts[id] ?? 0;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
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

  static Future<Match> fromJson({required Map<String, dynamic> json, String? matchId}) async {
    final equipeDomicile =
        await WebEquipeRepository().fetchEquipeById(json['equipeDomicileId']);
    final equipeExterieur =
        await WebEquipeRepository().fetchEquipeById(json['equipeExterieurId']);

    final joueursDomicile = <Joueur>[];
    for (final id in (json['joueursEquipeDomicileId'] as List? ?? [])) {
      final joueur = await WebJoueurRepository().fetchJoueurById(id);
      if (joueur != null) joueursDomicile.add(joueur);
    }

    final joueursExterieur = <Joueur>[];
    for (final id in (json['joueursEquipeExterieurId'] as List? ?? [])) {
      final joueur = await WebJoueurRepository().fetchJoueurById(id);
      if (joueur != null) joueursExterieur.add(joueur);
    }

    Future<List<But>> reconstructButs(List<dynamic>? butsList) async {
      if (butsList == null) return [];

      final buts = <But>[];
      for (final b in butsList) {
        final joueurId = b['buteurId'] as String?;
        Joueur? joueur;
        if (joueurId != null) {
          joueur = await WebJoueurRepository().fetchJoueurById(joueurId);
        }
        if (joueur != null) {
          buts.add(But(buteur: joueur, minute: b['minute']));
        }
      }
      return buts;
    }

    return Match(
      id: matchId ?? json['id'],
      competition: json['competition'] as String? ?? '',
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(
              json['date'] as String? ?? DateTime.now().toIso8601String()),
      scoreEquipeDomicile: (json['scoreEquipeDomicile'] as num?)?.toInt() ?? 0,
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
    )
      ..mvpVotes = Map<String, String>.from(json['mvpVotes'] ?? {})
      ..notesDuMatch = Map<String, int>.from(
          (json['notesDuMatch'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, (v as num).toInt())));
  }

  @override
  String toString() =>
      '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom}';
}
