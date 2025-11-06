import 'package:scorescope/models/joueur.dart';

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
  Joueur?
      mvp; // à changer : actuellement c'est le vote actuel de l'utilisateur mais ça ne doit pas être stocké là
  Map<Joueur, int> mvpVotes;
  Map<String, int> notesDuMatch;

  Match({
    this.id,
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
    this.mvp,
  })  : butsEquipeDomicile = butsEquipeDomicile ?? [],
        butsEquipeExterieur = butsEquipeExterieur ?? [],
        mvpVotes = {
          for (final j in [...joueursEquipeDomicile, ...joueursEquipeExterieur])
            j: 0,
          if (mvp != null) mvp: 1,
        },
        notesDuMatch = {};

  double getNoteMoyenne() {
    if (notesDuMatch.isEmpty) return -1.0;

    final notes = notesDuMatch.values;
    final somme = notes.reduce((a, b) => a + b);
    final moyenne = somme / notes.length;

    return moyenne;
  }

  void noterMatch({required String username, required int? note}) {
    if (note != null) notesDuMatch[username] = note;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'equipeDomicile': equipeDomicile.toJson(),
        'equipeExterieur': equipeExterieur.toJson(),
        'competition': competition,
        'date': date.toIso8601String(),
        'scoreEquipeDomicile': scoreEquipeDomicile,
        'scoreEquipeExterieur': scoreEquipeExterieur,
        'joueursEquipeDomicile':
            joueursEquipeDomicile.map((j) => j.toJson()).toList(),
        'joueursEquipeExterieur':
            joueursEquipeExterieur.map((j) => j.toJson()).toList(),
        'butsEquipeDomicile':
            butsEquipeDomicile.map((b) => b.toJson()).toList(),
        'butsEquipeExterieur':
            butsEquipeExterieur.map((b) => b.toJson()).toList(),
        if (mvp != null) 'mvp': mvp!.toJson(),
        'mvpVotes': mvpVotes.map((joueur, votes) => MapEntry(joueur.id, votes)),
        'notesDuMatch':
            notesDuMatch.map((username, note) => MapEntry(username, note)),
      };

  factory Match.fromJson(Map<String, dynamic> json) {
    final joueursDomicile = (json['joueursEquipeDomicile'] as List?)
            ?.map((j) => Joueur.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList() ??
        [];

    final joueursExterieur = (json['joueursEquipeExterieur'] as List?)
            ?.map((j) => Joueur.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList() ??
        [];

    // --- reconstruction des votes MVP ---
    final rawVotes = Map<String, dynamic>.from(json['mvpVotes'] ?? {});
    final allPlayers = [...joueursDomicile, ...joueursExterieur];
    final mvpVotes = <Joueur, int>{};

    for (final entry in rawVotes.entries) {
      final matching = allPlayers.where((j) => j.id == entry.key);
      if (matching.isNotEmpty) {
        final joueur = matching.first;
        mvpVotes[joueur] = (entry.value as num).toInt();
      }
    }

    // --- reconstruction des notes du match ---
    final rawNotes = Map<String, dynamic>.from(json['notesDuMatch'] ?? {});
    final notesDuMatch = rawNotes.map(
      (username, note) => MapEntry(username, (note as num).toInt()),
    );

    return Match(
      id: json['id'] as String?,
      equipeDomicile: Equipe.fromJson(
          Map<String, dynamic>.from(json['equipeDomicile'] as Map)),
      equipeExterieur: Equipe.fromJson(
          Map<String, dynamic>.from(json['equipeExterieur'] as Map)),
      competition: json['competition'] as String? ?? '',
      date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String()),
      scoreEquipeDomicile: (json['scoreEquipeDomicile'] as num?)?.toInt() ?? 0,
      scoreEquipeExterieur:
          (json['scoreEquipeExterieur'] as num?)?.toInt() ?? 0,
      joueursEquipeDomicile: joueursDomicile,
      joueursEquipeExterieur: joueursExterieur,
      butsEquipeDomicile: (json['butsEquipeDomicile'] as List?)
              ?.map((e) => But.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      butsEquipeExterieur: (json['butsEquipeExterieur'] as List?)
              ?.map((e) => But.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      mvp: json['mvp'] != null
          ? Joueur.fromJson(Map<String, dynamic>.from(json['mvp'] as Map))
          : null,
    )
      ..mvpVotes = mvpVotes
      ..notesDuMatch = notesDuMatch;
  }

  @override
  String toString() =>
      '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom}';
}
