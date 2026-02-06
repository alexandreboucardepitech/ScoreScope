import 'package:scorescope/models/util/basic_podium_displayable.dart';

class Equipe extends BasicPodiumDisplayable {
  final String id;
  final String nom;
  final String? nomCourt;
  final String? code;
  final String? logoPath;
  final String? couleurPrincipale;
  final String? couleurSecondaire;

  Equipe(
      {required this.id,
      required this.nom,
      this.nomCourt,
      this.code,
      this.logoPath,
      this.couleurPrincipale,
      this.couleurSecondaire});

  @override
  String get displayLabel => nomCourt ?? nom;

  @override
  String? get displayImage => logoPath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        if (nomCourt != null) 'nomCourt': nomCourt,
        if (code != null) 'code': code,
        if (logoPath != null) 'logoPath': logoPath,
        if (couleurPrincipale != null) 'couleurPrincipale': couleurPrincipale,
        if (couleurSecondaire != null) 'couleurSecondaire': couleurSecondaire,
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
      );

  @override
  String toString() => nom;
}
