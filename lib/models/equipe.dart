class Equipe {
  final String? id;
  final String nom;
  final String? code; // optionnel : abbréviation, ex "PSG"

  Equipe({this.id, required this.nom, this.code});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nom': nom,
        if (code != null) 'code': code,
      };

  factory Equipe.fromJson(Map<String, dynamic> json) => Equipe(
        id: json['id'] as String?,
        nom: json['nom'] as String? ?? '',
        code: json['code'] as String?,
      );

  @override
  String toString() => nom;
}
