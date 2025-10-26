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
  final Joueur? mvp;

  Match({
    this.id,
    required this.equipeDomicile,
    required this.equipeExterieur,
    required this.competition,
    required this.date,
    required this.scoreEquipeDomicile,
    required this.scoreEquipeExterieur,
    List<But>? butsEquipeDomicile,
    List<But>? butsEquipeExterieur,
    this.mvp,
  })  : butsEquipeDomicile = butsEquipeDomicile ?? [],
        butsEquipeExterieur = butsEquipeExterieur ?? [];

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'equipeDomicile': equipeDomicile.toJson(),
        'equipeExterieur': equipeExterieur.toJson(),
        'competition': competition,
        'date': date.toIso8601String(),
        'scoreEquipeDomicile': scoreEquipeDomicile,
        'scoreEquipeExterieur': scoreEquipeExterieur,
        'butsEquipeDomicile': butsEquipeDomicile.map((b) => b.toJson()).toList(),
        'butsEquipeExterieur': butsEquipeExterieur.map((b) => b.toJson()).toList(),
        if (mvp != null) 'mvp': mvp,
      };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String?,
        equipeDomicile: Equipe.fromJson(Map<String, dynamic>.from(json['equipeDomicile'] as Map)),
        equipeExterieur: Equipe.fromJson(Map<String, dynamic>.from(json['equipeExterieur'] as Map)),
        competition: json['competition'] as String? ?? '',
        date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
        scoreEquipeDomicile: (json['scoreEquipeDomicile'] as num?)?.toInt() ?? 0,
        scoreEquipeExterieur: (json['scoreEquipeExterieur'] as num?)?.toInt() ?? 0,
        butsEquipeDomicile: (json['butsEquipeDomicile'] as List?)
                ?.map((e) => But.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        butsEquipeExterieur: (json['butsEquipeExterieur'] as List?)
                ?.map((e) => But.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        mvp: json['mvp'] as Joueur?,
      );

  @override
  String toString() => '$competition : ${equipeDomicile.nom} $scoreEquipeDomicile-$scoreEquipeExterieur ${equipeExterieur.nom}';
}
