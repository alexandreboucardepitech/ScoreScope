import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';

class MatchJoueur {
  final Joueur joueur;
  final int? number;
  final String? pos;
  final String? grid;
  final bool hasPlayed;

  MatchJoueur({
    required this.joueur,
    this.number,
    this.pos,
    this.grid,
    this.hasPlayed = false,
  });

  Map<String, dynamic> toJson() => {
        'joueur': joueur.toJson(),
        if (number != null) 'number': number,
        if (pos != null) 'pos': pos,
        if (grid != null) 'grid': grid,
        'hasPlayed': hasPlayed,
      };

  static Future<MatchJoueur> fromMatchJoueurId(MatchJoueurId data) async {
    final joueur = await RepositoryProvider.joueurRepository
        .fetchJoueurById(data.joueurId);

    if (joueur == null) {
      throw Exception("Le joueur ${data.joueurId} n'existe pas.");
    }

    return MatchJoueur(
      joueur: joueur,
      number: data.number,
      pos: data.pos,
      grid: data.grid,
      hasPlayed: data.hasPlayed,
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

  MatchJoueurId({
    required this.joueurId,
    this.number,
    this.pos,
    this.grid,
    this.hasPlayed = false,
  });

  Map<String, dynamic> toJson() => {
        'joueurId': joueurId,
        if (number != null) 'number': number,
        if (pos != null) 'pos': pos,
        if (grid != null) 'grid': grid,
        'hasPlayed': hasPlayed,
      };

  factory MatchJoueurId.fromJson(Map<String, dynamic> json) {
    return MatchJoueurId(
      joueurId: json['joueurId'],
      number: json['number'],
      pos: json['pos'],
      grid: json['grid'],
      hasPlayed: json['hasPlayed'],
    );
  }

  MatchJoueurId copyWith({
    String? joueurId,
    int? number,
    String? pos,
    String? grid,
    bool? hasPlayed,
  }) {
    return MatchJoueurId(
      joueurId: joueurId ?? this.joueurId,
      number: number ?? this.number,
      pos: pos ?? this.pos,
      grid: grid ?? this.grid,
      hasPlayed: hasPlayed ?? this.hasPlayed,
    );
  }
}
