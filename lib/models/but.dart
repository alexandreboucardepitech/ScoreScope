import 'package:scorescope/services/repository_provider.dart';

import 'joueur.dart';

enum TypeBut {
  normal,
  penalty,
  owngoal,
}

extension TypeButExt on TypeBut {
  static TypeBut? fromString(String value) {
    switch (value) {
      case 'normal':
        return TypeBut.normal;
      case 'penalty':
        return TypeBut.penalty;
      case 'owngoal':
        return TypeBut.owngoal;
    }
    return null;
  }
}

class But {
  final Joueur buteur;
  final String? minute; // on garde string pour gérer "90+1", "45+2" etc.
  final Joueur? passeur;
  final TypeBut typeBut;

  But({
    required this.buteur,
    this.minute,
    this.passeur,
    this.typeBut = TypeBut.normal,
  });

  Map<String, dynamic> toJson() => {
        'buteur': buteur.toJson(),
        if (minute != null) 'minute': minute,
        if (passeur != null) 'passeur': passeur!.toJson(),
        'typeBut': typeBut.name,
      };

  static Future<But> fromButId(ButId butId) async {
    final buteur = await RepositoryProvider.joueurRepository
        .fetchJoueurById(butId.buteurId);

    Joueur? passeur;

    if (butId.passeurId != null) {
      passeur = await RepositoryProvider.joueurRepository
          .fetchJoueurById(butId.passeurId!);
    }

    return But(
      buteur: buteur!,
      minute: butId.minute,
      passeur: passeur,
      typeBut: butId.typeBut,
    );
  }

  @override
  String toString() => '${buteur.fullName} ($minute\')';
}

class ButId {
  final String buteurId;
  final String? minute;
  final String? passeurId;
  final TypeBut typeBut;

  ButId({
    required this.buteurId,
    this.minute,
    this.passeurId,
    this.typeBut = TypeBut.normal,
  });

  Map<String, dynamic> toJson() => {
        'buteurId': buteurId,
        if (minute != null) 'minute': minute,
        if (passeurId != null) 'passeurId': passeurId,
        'typeBut': typeBut.name,
      };

  factory ButId.fromJson(Map<String, dynamic> json) {
    return ButId(
      buteurId: json['buteurId'],
      minute: json['minute'],
      passeurId: json['passeurId'],
      typeBut: json['typeBut'] != null
          ? TypeButExt.fromString(json['typeBut']) ?? TypeBut.normal
          : TypeBut.normal,
    );
  }
}
