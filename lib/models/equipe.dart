import 'package:flutter/material.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/views/details/team_details_page.dart';

class Equipe extends BasicPodiumDisplayable {
  final String id;
  final String nom;
  final String? nomCourt;
  final String? code;
  final String? logoPath;
  final String? couleurPrincipale;
  final String? couleurSecondaire;
  final bool national;

  Equipe({
    required this.id,
    required this.nom,
    this.nomCourt,
    this.code,
    this.logoPath,
    this.couleurPrincipale,
    this.couleurSecondaire,
    this.national = false,
  });

  @override
  String get displayLabel => nomCourt ?? nom;

  @override
  String? get displayImage => logoPath;

  @override
  String? get longDisplayLabel => null;

  @override
  Future<String?> getColor() async {
    return couleurPrincipale;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        if (nomCourt != null) 'nomCourt': nomCourt,
        if (code != null) 'code': code,
        if (logoPath != null) 'logoPath': logoPath,
        if (couleurPrincipale != null) 'couleurPrincipale': couleurPrincipale,
        if (couleurSecondaire != null) 'couleurSecondaire': couleurSecondaire,
        'national': national,
      };

  factory Equipe.fromJson(
          {required Map<String, dynamic> json, String? equipeId}) =>
      Equipe(
        id: equipeId ?? json['id'],
        nom: json['nom'] as String? ?? '',
        nomCourt: json['nomCourt'] as String?,
        code: json['code'] as String?,
        logoPath: json['logoPath'] as String?,
        couleurPrincipale: json['couleurPrincipale'] as String?,
        couleurSecondaire: json['couleurSecondaire'] as String?,
        national: json['national'] as bool? ?? false,
      );

  Equipe copyWith({
    String? id,
    String? nom,
    String? nomCourt,
    String? code,
    String? logoPath,
    String? couleurPrincipale,
    String? couleurSecondaire,
    bool? national,
  }) {
    return Equipe(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      nomCourt: nomCourt ?? this.nomCourt,
      code: code ?? this.code,
      logoPath: logoPath ?? this.logoPath,
      couleurPrincipale: couleurPrincipale ?? this.couleurPrincipale,
      couleurSecondaire: couleurSecondaire ?? this.couleurSecondaire,
      national: national ?? this.national,
    );
  }

  @override
  String toString() => nom;

  @override
  GestureTapCallback? onTap(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeamDetailsPage(teamId: id)),
      );
    };
  }
}
