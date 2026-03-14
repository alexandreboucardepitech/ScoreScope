import '../../models/joueur.dart';

Joueur parseNomJoueur(String input) {
  final clean = input.trim();

  if (clean.isEmpty) {
    return Joueur(
      prenom: '',
      nom: '',
      equipeId: '',
      id: "0",
      dateNaissance: DateTime(2000, 01, 01),
      nationalite: '',
    );
  }

  final parts = clean.split(' ');
  if (parts.length > 1) {
    final prenom = parts.first;
    final nom = parts.sublist(1).join(' ');
    return Joueur(
      prenom: prenom,
      nom: nom,
      equipeId: '',
      id: "0",
      dateNaissance: DateTime(2000, 01, 01),
      nationalite: '',
    );
  }

  return Joueur(
    prenom: '',
    nom: clean,
    equipeId: '',
    id: "0",
    dateNaissance: DateTime(2000, 01, 01),
    nationalite: '',
  );
}

String capitalizeNomComplet(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .map((mot) => mot.isEmpty
          ? ''
          : mot[0].toUpperCase() + mot.substring(1).toLowerCase())
      .join(' ');
}
