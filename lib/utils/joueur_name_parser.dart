import '../models/joueur.dart';

Joueur parseNomJoueur(String input) {
  // On nettoie un peu la chaîne
  final clean = input.trim();

  // Si la chaîne est vide, on renvoie un joueur vide
  if (clean.isEmpty) {
    return Joueur(prenom: '', nom: '', equipeId: '');
  }

  // Cas 2 : format "Prénom Nom"
  final parts = clean.split(' ');
  if (parts.length > 1) {
    final prenom = parts.first;
    final nom = parts.sublist(1).join(' ');
    return Joueur(prenom: prenom, nom: nom, equipeId: '');
  }

  // Cas 3 : un seul mot → on suppose que c’est le nom
  return Joueur(prenom: '', nom: clean, equipeId: '');
}

String capitalizeNomComplet(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+')) // découpe sur les espaces
      .map((mot) =>
          mot.isEmpty ? '' : mot[0].toUpperCase() + mot.substring(1).toLowerCase())
      .join(' ');
}