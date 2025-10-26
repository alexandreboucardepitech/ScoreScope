import 'package:flutter/material.dart';
import 'package:scorescope/widgets/match_details_tabs/infos.dart';
import '../models/match.dart';
import '../utils/get_lignes_buteurs.dart';

class MatchDetailsPage extends StatefulWidget {
  final Match match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 onglets
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // si tu as modifié toolbarHeight ailleurs, remplace par la même valeur
    const double toolbarHeight = 50; // valeur que tu avais dans l'appBar

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: toolbarHeight,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {},
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'partager', child: Text('Partager')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green.shade400,
            padding: EdgeInsets.fromLTRB(
                16,
                statusBarHeight + toolbarHeight,
                16,
                0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // logos + score (réduis si besoin)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                        widget.match.equipeDomicile.logoPath!,
                                        fit: BoxFit.contain)),
                                const SizedBox(height: 6),
                                Text(widget.match.equipeDomicile.nom,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${widget.match.scoreEquipeDomicile} - ${widget.match.scoreEquipeExterieur}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                        widget.match.equipeExterieur.logoPath!,
                                        fit: BoxFit.contain)),
                                const SizedBox(height: 6),
                                Text(widget.match.equipeExterieur.nom,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // buteurs (texte compact)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bloc domicile
                          SizedBox(
                            width: 160, // largeur fixe pour la colonne domicile
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: getLignesButeurs(
                                      buts: widget.match.butsEquipeDomicile,
                                      domicile: true,
                                      fullName: false)
                                  .map((line) => Text(line,
                                      style: const TextStyle(fontSize: 12)))
                                  .toList(),
                            ),
                          ),

                          // Bloc score / ballon
                          SizedBox(
                            width: 40, // largeur fixe du bloc central
                            child: Column(
                              children: const [
                                Icon(Icons.sports_soccer, size: 14),
                                SizedBox(height: 4),
                                // Tu peux mettre le score ici si tu veux
                              ],
                            ),
                          ),

                          // Bloc extérieur
                          SizedBox(
                            width:
                                160, // largeur fixe pour la colonne extérieur
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: getLignesButeurs(
                                      buts: widget.match.butsEquipeExterieur,
                                      domicile: false,
                                      fullName: false)
                                  .map((line) => Text(line,
                                      style: const TextStyle(fontSize: 12)))
                                  .toList(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // --- TabBar collée juste en dessous du bloc central ---
                // Comme tout est dans la même Column (mainAxisSize.min), la hauteur totale
                // du Container est : contenu central + hauteur du TabBar.
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: "Infos"),
                    Tab(text: "Stats"),
                    Tab(text: "Comments"),
                  ],
                ),
              ],
            ),
          ),

          // --- Contenu dessous (tab views) ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InfosTab(match: widget.match),
                Center(child: Text("Contenu Statistiques")),
                Center(child: Text("Contenu Commentaires")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
