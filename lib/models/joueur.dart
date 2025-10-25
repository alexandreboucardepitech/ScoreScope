import 'package:scorescope/models/equipe.dart';

class Joueur {
  final String? id;
  final String prenom;
  final String nom;
  final Equipe? equipe;
  final Equipe? equipeNationale;

  Joueur({this.id, required this.prenom, required this.nom, this.equipe, this.equipeNationale});

  String get fullName {
    return '$prenom $nom'.trim();
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'prenom': prenom,
        'nom': nom,
        if (equipe != null) 'equipe': equipe,
        if (equipeNationale != null) 'equipeNationale': equipeNationale,
      };

  factory Joueur.fromJson(Map<String, dynamic> json) => Joueur(
        id: json['id'] as String?,
        prenom: json['prenom'] as String? ?? '',
        nom: json['nom'] as String? ?? '',
        equipe: json['equipe'] as Equipe?,
        equipeNationale: json['equipeNationale'] as Equipe?,
      );

  @override
  String toString() => fullName;
}