import 'package:scorescope/models/equipe.dart';

class Joueur {
  final String? id;
  final String prenom;
  final String nom;
  final Equipe? equipe;
  final Equipe? equipeNationale;
  final String picture;

  Joueur(
      {this.id,
      required this.prenom,
      required this.nom,
      this.equipe,
      this.equipeNationale,
      this.picture = "assets/joueurs/default.png"});

  String get fullName => '$prenom $nom'.trim();

  String get shortName => prenom.isEmpty ? nom : '${prenom[0]}. $nom';

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'prenom': prenom,
        'nom': nom,
        if (equipe != null) 'equipe': equipe,
        if (equipeNationale != null) 'equipeNationale': equipeNationale,
        'picture': picture,
      };

  factory Joueur.fromJson(Map<String, dynamic> json) => Joueur(
        id: json['id'] as String?,
        prenom: json['prenom'] as String? ?? '',
        nom: json['nom'] as String? ?? '',
        equipe: json['equipe'] as Equipe?,
        equipeNationale: json['equipeNationale'] as Equipe?,
        picture: json['picture'] as String? ?? 'assets/joueurs/default.png',
      );

  @override
  String toString() => fullName;
}
