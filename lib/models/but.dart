import 'joueur.dart';

class But {
  final String? id;
  final Joueur buteur;
  final String? minute; // on garde string pour gérer "90+1", "45+2" etc.

  But({this.id, required this.buteur, this.minute});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'buteur': buteur.toJson(),
        if (minute != null) 'minute': minute,
      };

  factory But.fromJson(Map<String, dynamic> json) => But(
        id: json['id'] as String?,
        buteur: Joueur.fromJson(Map<String, dynamic>.from(json['buteur'] as Map)),
        minute: json['minute'] as String?,
      );

  @override
  String toString() => '${buteur.fullName} ($minute\')';
}