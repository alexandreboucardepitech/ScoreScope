import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_details_tabs/infos.dart';
import '../models/match.dart';
import '../utils/string/get_lignes_buteurs.dart';

class MatchDetailsPage extends StatefulWidget {
  final Match match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavori = false;
  bool _isUpdatingFavori = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavoriStatus();
  }

  Future<void> _loadFavoriStatus() async {
    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        final favori = await RepositoryProvider.userRepository
            .isMatchFavori(currentUser.uid, widget.match.id);
        if (!mounted) return;
        setState(() => _isFavori = favori);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavori() async {
    if (_isUpdatingFavori) return;
    setState(() => _isUpdatingFavori = true);

    final newFavori = !_isFavori;

    try {
      AppUser? currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        await RepositoryProvider.userRepository
            .matchFavori(widget.match.id, currentUser.uid, newFavori);
      }
      setState(() {
        _isFavori = newFavori;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavori ? 'Match ajouté aux favoris' : 'Match retiré des favoris',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // erreur lors de la mise à jour
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du favori'),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() => _isUpdatingFavori = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double toolbarHeight = 50;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: toolbarHeight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.opposite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // bouton favori
          IconButton(
            icon: _isUpdatingFavori
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.opposite(context),
                    ),
                  )
                : Icon(
                    _isFavori ? Icons.favorite : Icons.favorite_border,
                    color: _isFavori
                        ? ColorPalette.accent(context)
                        : ColorPalette.opposite(context),
                  ),
            onPressed: _toggleFavori,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ColorPalette.opposite(context)),
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'partager',
                child: Text(
                  'Partager',
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: ColorPalette.background(context),
            padding:
                EdgeInsets.fromLTRB(16, statusBarHeight + toolbarHeight, 16, 0),
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
                                Text(
                                  widget.match.equipeDomicile.nom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${widget.match.scoreEquipeDomicile} - ${widget.match.scoreEquipeExterieur}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context),
                              ),
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
                                Text(
                                  widget.match.equipeExterieur.nom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
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
                                  .map(
                                    (line) => Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            ColorPalette.textSecondary(context),
                                      ),
                                    ),
                                  )
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
                                  .map(
                                    (line) => Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            ColorPalette.textSecondary(context),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  indicatorColor: ColorPalette.accent(context),
                  labelColor: ColorPalette.textAccent(context),
                  unselectedLabelColor: ColorPalette.textPrimary(context),
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
