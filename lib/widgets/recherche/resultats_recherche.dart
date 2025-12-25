import 'package:flutter/material.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/match_details.dart';
import 'package:scorescope/widgets/recherche/resultats_section.dart';

class ResultatsRecherche extends StatelessWidget {
  final ResultatsRechercheModel resultats;

  const ResultatsRecherche({
    super.key,
    required this.resultats,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        ResultatsSection<MatchModel>(
          title: "Matchs",
          items: resultats.matchs,
          itemBuilder: (match) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: match.competition.logoUrl != null
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(match.competition.logoUrl!,
                        fit: BoxFit.contain),
                  )
                : const Icon(Icons.sports_soccer),
            title: Text(
              '${match.equipeDomicile.nomCourt ?? match.equipeDomicile.nom}'
              ' ${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur} '
              '${match.equipeExterieur.nomCourt ?? match.equipeExterieur.nom}',
            ),
            subtitle: Text(match.competition.nom),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsPage(match: match),
                ),
              );
            },
          ),
        ),
        ResultatsSection<Equipe>(
          title: "Équipes",
          items: resultats.equipes,
          itemBuilder: (equipe) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: buildTeamLogo(context, equipe.logoPath,
                isFavorite:
                    resultats.user?.equipesPrefereesId.contains(equipe.id) ??
                        false),
            title: Text(equipe.nom),
            onTap: () {},
          ),
        ),
        ResultatsSection<Competition>(
          title: "Compétitions",
          items: resultats.competitions,
          itemBuilder: (competition) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: competition.logoUrl != null
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child:
                        Image.asset(competition.logoUrl!, fit: BoxFit.contain),
                  )
                : const Icon(Icons.emoji_events_outlined),
            title: Text(competition.nom),
            onTap: () {},
          ),
        ),
        ResultatsSection<Joueur>(
          title: "Joueurs",
          items: resultats.joueurs,
          itemBuilder: (joueur) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(
              width: 32,
              height: 32,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: ColorPalette.pictureBackground(context),
                backgroundImage: joueur.picture.startsWith('http')
                    ? NetworkImage(joueur.picture) as ImageProvider
                    : AssetImage(joueur.picture),
              ),
            ),
            title: Text(joueur.fullName),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
