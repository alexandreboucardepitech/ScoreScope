import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';

class Joueur extends BasicPodiumDisplayable {
  final String? id;
  final String prenom;
  final String nom;
  final String equipeId;
  final String? equipeNationaleId;
  final String picture;

  Joueur(
      {required this.id,
      required this.prenom,
      required this.nom,
      required this.equipeId,
      this.equipeNationaleId,
      this.picture = "assets/joueurs/default.png"});

  String get fullName => '$prenom $nom'.trim();

  String get shortName => prenom.isEmpty ? nom : '${prenom[0]}. $nom';

  @override
  String get displayLabel => shortName;

  @override
  String? get displayImage => picture;

  @override
  String? get longDisplayLabel => fullName;

  @override
  Future<String?> getColor() async {
    Equipe? equipe =
        await RepositoryProvider.equipeRepository.fetchEquipeById(equipeId);
    if (equipe != null) {
      return equipe.couleurPrincipale;
    } else {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'prenom': prenom,
        'nom': nom,
        'equipeId': equipeId,
        if (equipeNationaleId != null) 'equipeNationaleId': equipeNationaleId,
        'picture': picture,
      };

  factory Joueur.fromJson(
          {required Map<String, dynamic> json, String? joueurId}) =>
      Joueur(
        id: joueurId ?? json['id'],
        prenom: json['prenom'] as String? ?? '',
        nom: json['nom'] as String? ?? '',
        equipeId: json['equipeId'],
        equipeNationaleId: json['equipeNationaleId'] as String?,
        picture: json['picture'] as String? ?? 'assets/joueurs/default.png',
      );

  @override
  String toString() => fullName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Joueur && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
