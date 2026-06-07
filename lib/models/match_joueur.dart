import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';

class MatchJoueur {
  final Joueur? joueur;
  final int? number;
  final String? pos;
  final String? grid;
  final bool hasPlayed;
  final bool isStarter;

  MatchJoueur({
    this.joueur,
    this.number,
    this.pos,
    this.grid,
    this.hasPlayed = false,
    this.isStarter = false,
  });

  Map<String, dynamic> toJson() => {
        if (joueur != null) 'joueur': joueur!.toJson(),
        if (number != null) 'number': number,
        if (pos != null) 'pos': pos,
        if (grid != null) 'grid': grid,
        'hasPlayed': hasPlayed,
        'isStarter': isStarter,
      };

  factory MatchJoueur.fromJson(Map<String, dynamic> json) {
    return MatchJoueur(
      joueur: json['joueur'] != null
          ? Joueur.fromJson(json: json['joueur'] as Map<String, dynamic>)
          : null,
      number: json['number'] as int?,
      pos: json['pos'] as String?,
      grid: json['grid'] as String?,
      hasPlayed: json['hasPlayed'] as bool? ?? false,
      isStarter: json['isStarter'] as bool? ?? false,
    );
  }

  static Future<MatchJoueur> fromMatchJoueurId(MatchJoueurId data,
      {Joueur? joueurDejaCharge}) async {
    Joueur? joueur = joueurDejaCharge ??
        await RepositoryProvider.joueurRepository
            .fetchJoueurById(data.joueurId);

    return MatchJoueur(
      joueur: joueur,
      number: data.number,
      pos: data.pos,
      grid: data.grid,
      hasPlayed: data.hasPlayed,
      isStarter: data.isStarter,
    );
  }

  MatchJoueur copyWith({
    Joueur? joueur,
    int? number,
    String? pos,
    String? grid,
    bool? hasPlayed,
  }) {
    return MatchJoueur(
      joueur: joueur ?? this.joueur,
      number: number ?? this.number,
      pos: pos ?? this.pos,
      grid: grid ?? this.grid,
      hasPlayed: hasPlayed ?? this.hasPlayed,
    );
  }
}

class MatchJoueurId {
  final String joueurId;
  final int? number;
  final String? pos;
  final String? grid;
  final bool hasPlayed;
  final bool isStarter;

  MatchJoueurId({
    required this.joueurId,
    this.number,
    this.pos,
    this.grid,
    this.hasPlayed = false,
    this.isStarter = false,
  });

  Map<String, dynamic> toJson() => {
        'joueurId': joueurId,
        if (number != null) 'number': number,
        if (pos != null) 'pos': pos,
        if (grid != null) 'grid': grid,
        'hasPlayed': hasPlayed,
        'isStarter': isStarter,
      };

  factory MatchJoueurId.fromJson(Map<String, dynamic> json) {
    return MatchJoueurId(
      joueurId: json['joueurId'],
      number: json['number'],
      pos: json['pos'],
      grid: json['grid'],
      hasPlayed: json['hasPlayed'],
      isStarter: json['isStarter'] ?? false,
    );
  }

  MatchJoueurId copyWith({
    String? joueurId,
    int? number,
    String? pos,
    String? grid,
    bool? hasPlayed,
    bool? isStarter,
  }) {
    return MatchJoueurId(
      joueurId: joueurId ?? this.joueurId,
      number: number ?? this.number,
      pos: pos ?? this.pos,
      grid: grid ?? this.grid,
      hasPlayed: hasPlayed ?? this.hasPlayed,
      isStarter: isStarter ?? this.isStarter,
    );
  }
}
