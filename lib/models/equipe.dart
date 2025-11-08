class Equipe {
  final String id;
  final String nom;
  final String? code;
  final String? logoPath;

  Equipe({this.id = '1', required this.nom, this.code, this.logoPath});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        if (code != null) 'code': code,
        if (logoPath != null) 'logoPath': logoPath,
      };

  factory Equipe.fromJson({required Map<String, dynamic> json, String? equipeId}) => Equipe(
        id: equipeId ?? json['id'],
        nom: json['nom'] as String? ?? '',
        code: json['code'] as String?,
        logoPath: json['logoPath'] as String?,
      );

  @override
  String toString() => nom;
}
