class Joueur {
  final String? id;
  final String prenom;
  final String nom;

  Joueur({this.id, required this.prenom, required this.nom});

  String get fullName {
    final combined = '$prenom $nom'.trim();
    return combined.isEmpty ? (nom.isEmpty ? 'Inconnu' : nom) : combined;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'prenom': prenom,
        'nom': nom,
      };

  factory Joueur.fromJson(Map<String, dynamic> json) => Joueur(
        id: json['id'] as String?,
        prenom: json['prenom'] as String? ?? '',
        nom: json['nom'] as String? ?? '',
      );

  @override
  String toString() => fullName;
}