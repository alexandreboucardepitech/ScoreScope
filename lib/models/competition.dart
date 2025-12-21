class Competition {
  final String id;
  final String nom;
  final String? logoUrl;
  final int popularite;

  Competition(
      {required this.id, required this.nom, this.logoUrl, this.popularite = 0});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'popularite': popularite,
      };

  factory Competition.fromJson(
      {required Map<String, dynamic> json, String? competitionId}) {
    return Competition(
      id: competitionId ?? json['id'] as String,
      nom: json['nom'] as String,
      logoUrl: json['logoUrl'] as String?,
      popularite: json['popularite'] as int? ?? 0,
    );
  }
}
