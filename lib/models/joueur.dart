import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/views/details/player_details_page.dart';

class Joueur extends BasicPodiumDisplayable {
  final String id;
  final String prenom;
  final String nom;
  final String fullName;
  final String equipeId;
  final String? equipeNationaleId;
  final DateTime? dateNaissance;
  final String? nationalite;
  final String picture;

  Joueur({
    required this.id,
    required this.prenom,
    required this.nom,
    String? fullName,
    required this.equipeId,
    this.equipeNationaleId,
    this.dateNaissance,
    this.nationalite,
    this.picture = "assets/joueurs/default.png",
  }) : fullName = fullName ?? '${prenom.split(' ').first} $nom'.trim();

  String get shortName =>
      prenom.isEmpty ? nom : '${prenom[0]}. ${nom.split(' ').first}';

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

  @override
  GestureTapCallback? onTap(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerDetailsPage(playerId: id),
        ),
      );
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'fullName': fullName,
        'equipeId': equipeId,
        if (equipeNationaleId != null) 'equipeNationaleId': equipeNationaleId,
        if (dateNaissance != null) 'dateNaissance': dateNaissance,
        if (nationalite != null) 'nationalite': nationalite,
        'picture': picture,
      };

  factory Joueur.fromJson(
      {required Map<String, dynamic> json, String? joueurId}) {
    DateTime? dateNaissance;
    if (json['dateNaissance'] == null) {
      dateNaissance = null;
    } else if (json['dateNaissance'] is Timestamp) {
      dateNaissance = (json['dateNaissance'] as Timestamp).toDate();
    } else if (json['dateNaissance'] is String) {
      dateNaissance = DateTime.tryParse(json['dateNaissance']);
    } else {
      dateNaissance = null;
    }
    return Joueur(
      id: joueurId ?? json['id'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      dateNaissance: dateNaissance,
      equipeId: json['equipeId'],
      equipeNationaleId: json['equipeNationaleId'] as String?,
      nationalite: json['nationalite'] as String?,
      picture: json['picture'] as String? ?? 'assets/joueurs/default.png',
    );
  }

  @override
  String toString() => fullName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Joueur && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
