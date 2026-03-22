import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/graph_type.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/stats/team_stats.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/stats/stats_loader.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/statistiques/cards/graph_card.dart';
import 'package:scorescope/widgets/statistiques/cards/podium_card.dart';
import 'package:scorescope/widgets/statistiques/cards/simple_stat_card.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;

  const TeamDetailsPage({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  Equipe? _equipe;
  bool _isLoadingTeam = true;

  TeamStats? _teamStats;
  bool _isLoadingTeamStats = true;

  bool _isPersonalMode = true;

  @override
  void initState() {
    super.initState();
    _loadTeam().then((_) => _loadTeamStats());
  }

  Future<void> _loadTeam() async {
    try {
      final equipe = await RepositoryProvider.equipeRepository
          .fetchEquipeById(widget.teamId);

      setState(() {
        _equipe = equipe;
        _isLoadingTeam = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTeam = false;
      });
    }
  }

  Future<void> _loadTeamStats() async {
    try {
      final stats = await StatsLoader.getTeamStats(_equipe!);

      setState(() {
        _teamStats = stats;
        _isLoadingTeamStats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTeamStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPersonalMode
          ? ColorPalette.surface(context)
          : ColorPalette.background(context),
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
      body: _isLoadingTeam
          ? const Center(child: CircularProgressIndicator())
          : _equipe == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        "Equipe introuvable",
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
        SliverToBoxAdapter(child: _buildModeSwitch()),
        _buildStatsBlock(),
      ],
    );
  }

  Widget _buildStatsBlock() {
    return SliverToBoxAdapter(
      child: _isLoadingTeamStats
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: const Center(child: CircularProgressIndicator()),
            )
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 56),
              decoration: BoxDecoration(
                color: _isPersonalMode
                    ? ColorPalette.surface(context)
                    : ColorPalette.background(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _isPersonalMode
                          ? "Statistiques de mes matchs vus"
                          : "Statistiques globales",
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                        title: _isPersonalMode ? "Matchs vus" : "Matchs joués",
                        value: _isPersonalMode
                            ? _teamStats!.userMatchsJoues.toString()
                            : _teamStats!.matchsJoues.toString(),
                        icon: Icons.sports,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode
                            ? "Différence de buts des matchs vus"
                            : "Différence de buts",
                        value: _isPersonalMode
                            ? _teamStats!.userDifferenceButs.toString()
                            : _teamStats!.differenceButs.toString(),
                        icon: Icons.balance,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode
                            ? "Buts marqués vus"
                            : "Buts marqués",
                        value: _isPersonalMode
                            ? _teamStats!.userButsMarques.toString()
                            : _teamStats!.butsMarques.toString(),
                        icon: Icons.sports_soccer,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode
                            ? "Buts encaissés vus"
                            : "Buts encaissés",
                        value: _isPersonalMode
                            ? _teamStats!.userButsEncaisses.toString()
                            : _teamStats!.butsEncaisses.toString(),
                        icon: Icons.shield,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode
                            ? "Ma note moyenne des matchs"
                            : "Note moyenne des matchs",
                        value: _isPersonalMode
                            ? roundSmart(_teamStats!.userNoteMoyenneMatchs)
                            : roundSmart(_teamStats!.noteMoyenneMatchs),
                        icon: Icons.star,
                      ),
                      if (RepositoryProvider.userRepository.currentUser != null)
                        PodiumCard(
                          title: _isPersonalMode
                              ? "Mon MVP le plus voté"
                              : "MVP le plus voté",
                          items: _isPersonalMode
                              ? _teamStats!.userEluMvp
                              : _teamStats!.eluMvp,
                          user: RepositoryProvider.userRepository.currentUser!,
                        ),
                    ],
                  ),
                  GraphCard(
                    title: _isPersonalMode
                        ? "Ratio victoires/défaites (mes matchs vus)"
                        : "Ratio victoires/défaites",
                    type: GraphType.splitBar,
                    values: _isPersonalMode
                        ? _teamStats!.userRatioVictoiresDefaites
                        : _teamStats!.ratioVictoiresDefaites,
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
            buildTeamLogo(
              context,
              _equipe!.logoPath,
              equipeId: _equipe?.id,
              size: 72,
              clickable: false,
            ),
            const SizedBox(width: 16),
            Text(
              _equipe!.nom,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      height: 52,
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
                padding: const EdgeInsets.all(8),
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
