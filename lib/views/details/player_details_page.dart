import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/statistiques/cards/simple_stat_card.dart';

class PlayerDetailsPage extends StatefulWidget {
  final String playerId;

  const PlayerDetailsPage({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerDetailsPage> createState() => _PlayerDetailsPageState();
}

class _PlayerDetailsPageState extends State<PlayerDetailsPage> {
  Joueur? _joueur;
  bool _isLoading = true;

  bool _isPersonalMode = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    try {
      final joueur = await RepositoryProvider.joueurRepository
          .fetchJoueurById(widget.playerId);

      setState(() {
        _joueur = joueur;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPersonalMode
          ? ColorPalette.surfaceSecondary(context)
          : ColorPalette.surface(context),
      appBar: AppBar(
        backgroundColor: _isPersonalMode
            ? ColorPalette.surfaceSecondary(context)
            : ColorPalette.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _joueur == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        "Joueur introuvable",
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: _buildModeSwitch()),
        _buildStatsBlock(),
      ],
    );
  }

  Widget _buildStatsBlock() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 56),
        decoration: BoxDecoration(
          color: _isPersonalMode
              ? ColorPalette.surface(context)
              : ColorPalette.background(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isPersonalMode ? "Mes statistiques" : "Statistiques globales",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                SimpleStatCard(
                  title: "Matchs vus",
                  value: _isPersonalMode ? "12" : "482",
                  icon: Icons.sports_soccer,
                ),
                SimpleStatCard(
                  title: "Note moyenne",
                  value: _isPersonalMode ? "7.8" : "7.4",
                  icon: Icons.star,
                ),
                SimpleStatCard(
                  title: "MVP votés",
                  value: _isPersonalMode ? "9" : "315",
                  icon: Icons.emoji_events,
                ),
                SimpleStatCard(
                  title: "Victoires vues",
                  value: _isPersonalMode ? "8" : "290",
                  icon: Icons.trending_up,
                ),
                SimpleStatCard(
                  title: "Buts vus",
                  value: _isPersonalMode ? "15" : "1120",
                  icon: Icons.sports,
                ),
                SimpleStatCard(
                  title: "Compétitions",
                  value: _isPersonalMode ? "3" : "18",
                  icon: Icons.public,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: _isPersonalMode
            ? ColorPalette.surfaceSecondary(context)
            : ColorPalette.surface(context),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColorPalette.pictureBackground(context),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  _joueur!.picture,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _joueur!.fullName,
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder(
                    future: RepositoryProvider.equipeRepository
                        .fetchEquipeById(_joueur!.equipeId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          "Chargement...",
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                            fontSize: 14,
                          ),
                        );
                      }

                      final equipe = snapshot.data!;
                      return Text(
                        equipe.nom,
                        style: TextStyle(
                          color: ColorPalette.textSecondary(context),
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _isPersonalMode
            ? ColorPalette.surfaceSecondary(context)
            : ColorPalette.surface(context),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment:
                _isPersonalMode ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isPersonalMode
                        ? ColorPalette.accent(context)
                        : ColorPalette.surfaceSecondary(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSwitchSide(
                title: "Mes stats",
                selected: _isPersonalMode,
                onTap: () {
                  if (!_isPersonalMode) {
                    setState(() => _isPersonalMode = true);
                  }
                },
              ),
              _buildSwitchSide(
                title: "Global",
                selected: !_isPersonalMode,
                onTap: () {
                  if (_isPersonalMode) {
                    setState(() => _isPersonalMode = false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSide({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? ColorPalette.opposite(context)
                  : ColorPalette.textSecondary(context),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
