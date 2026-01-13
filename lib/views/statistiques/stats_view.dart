import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/statistiques/loader/stats_generales_loader.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_competitions.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_equipes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_habitudes.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_joueurs.dart';
import 'package:scorescope/widgets/statistiques/onglets/stats_matchs.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _showCards = true;

  void _toggleView() {
    setState(() {
      _showCards = !_showCards;
    });
  }

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
              tooltip: 'Filtrer par date',
            ),
            IconButton(
              icon: Icon(_showCards ? Icons.view_module : Icons.view_list),
              onPressed: _toggleView,
              tooltip: _showCards ? 'Afficher en liste' : 'Afficher en cards',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
              tooltip: "Plus d'options",
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: ColorPalette.accent(context),
            indicatorWeight: 3,
            labelColor: ColorPalette.accent(context),
            unselectedLabelColor: ColorPalette.textPrimary(context),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Global'),
              Tab(text: 'Matchs'),
              Tab(text: 'Équipes'),
              Tab(text: 'Joueurs'),
              Tab(text: 'Compétitions'),
              Tab(text: 'Habitudes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StatsGeneralesLoader(showCards: _showCards),
            StatsMatchsOnglet(showCards: _showCards),
            StatsEquipesOnglet(showCards: _showCards),
            StatsJoueursOnglet(showCards: _showCards),
            StatsCompetitionsOnglet(showCards: _showCards),
            StatsHabitudesOnglet(showCards: _showCards),
          ],
        ),
      ),
    );
  }
}
