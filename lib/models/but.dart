import 'package:scorescope/services/repository_provider.dart';

import 'joueur.dart';

class But {
  final Joueur buteur;
  final String? minute; // on garde string pour gérer "90+1", "45+2" etc.
  final Joueur? passeur;

  But({
    required this.buteur,
    this.minute,
    this.passeur,
  });

  Map<String, dynamic> toJson() => {
        'buteur': buteur.toJson(),
        if (minute != null) 'minute': minute,
        if (passeur != null) 'passeur': passeur!.toJson(),
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
    );
  }

  @override
  String toString() => '${buteur.fullName} ($minute\')';
}

class ButId {
  final String buteurId;
  final String? minute;
  final String? passeurId;

  ButId({
    required this.buteurId,
    this.minute,
    this.passeurId,
  });

  Map<String, dynamic> toJson() => {
        'buteurId': buteurId,
        if (minute != null) 'minute': minute,
        if (passeurId != null) 'passeurId': passeurId,
      };

  factory ButId.fromJson(Map<String, dynamic> json) {
    return ButId(
      buteurId: json['buteurId'],
      minute: json['minute'],
      passeurId: json['passeurId'],
    );
  }
}
