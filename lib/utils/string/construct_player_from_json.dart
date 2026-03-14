import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/get_first_and_last_name.dart';
import 'package:scorescope/utils/string/is_country.dart';

Future<Map<String, int?>> getPlayerTeamId(List<dynamic> playerTeams) async {
  int? club;
  int? backupClub;
  int? nation;
  for (dynamic team in playerTeams) {
    int? teamId = team['team']['id'];
    String? teamName = team['team']['name'];
    if (teamName != null && isCountry(teamName)) {
      nation = teamId;
    } else if (teamName != null && isCountry(teamName) == false) {
      backupClub = club;
      club = teamId;
    }
  }
  if (club != null && playerTeams.length > 1) {
    Equipe? equipeExistante =
        await RepositoryProvider.equipeRepository.fetchEquipeById(
      club.toString(),
    );
    if (equipeExistante == null) {
      club = null;
      if (backupClub != null) {
        Equipe? equipeBackupExistante =
            await RepositoryProvider.equipeRepository.fetchEquipeById(
          backupClub.toString(),
        );
        if (equipeBackupExistante != null) {
          club = int.tryParse(equipeBackupExistante.id);
        }
      }
    }
  }
  return {"club": club, "nation": nation};
}

Future<Joueur> constructPlayerFromJson(Map<String, dynamic> player,
    List<dynamic> playerTeams, String equipeId) async {
  String id = player['id'].toString();
  String? prenom = player['firstname'];
  String? nom = player['lastname'];
  String? fullName = player['name'];
  String? nationalite = player['nationality'];
  DateTime? dateNaissance = DateTime.tryParse(player['birth']?['date'] ?? '');
  String picture = player['photo'];
  Map<String, String> nomComplet = getFirstAndLastName(prenom, nom, fullName);
  if (fullName != null) {
    fullName = fullName.replaceAll('&apos;', "'");
  }
  Map<String, int?> teams = await getPlayerTeamId(playerTeams);
  String? club = teams["club"]?.toString();
  String? nation = teams["nation"]?.toString();
  final newJoueur = Joueur(
    id: id,
    prenom: nomComplet["prenom"]!,
    nom: nomComplet["nom"]!,
    fullName: fullName,
    equipeId: club ?? equipeId,
    equipeNationaleId: nation,
    dateNaissance: dateNaissance,
    nationalite: nationalite,
    picture: picture,
  );
  return newJoueur;
}
