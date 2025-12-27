import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_competitions.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_equipes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_generales.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_habitudes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_joueurs.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_matchs.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: ColorPalette.background(context),
        appBar: AppBar(
          backgroundColor: ColorPalette.tileBackground(context),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Mes statistiques',
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(
            color: ColorPalette.textPrimary(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.view_module),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            padding: EdgeInsets.zero,
            indicatorColor: ColorPalette.accent(context),
            indicatorWeight: 3,
            labelColor: ColorPalette.accent(context),
            unselectedLabelColor: ColorPalette.textPrimary(context),
            labelPadding: EdgeInsets.symmetric(horizontal: 12.0),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Global'),
              Tab(text: 'Matchs'),
              Tab(text: 'Équipes'),
              Tab(text: 'Joueurs'),
              Tab(text: 'Compétitions'),
              Tab(text: 'Habitudes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StatsGeneralesOnglet(),
            StatsMatchsOnglet(),
            StatsEquipesOnglet(),
            StatsJoueursOnglet(),
            StatsCompetitionsOnglet(),
            StatsHabitudesOnglet(),
          ],
        ),
      ),
    );
  }
}
