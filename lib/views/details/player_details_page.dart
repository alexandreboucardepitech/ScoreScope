import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/stats/player_stats.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/date/calculate_age.dart';
import 'package:scorescope/utils/stats/stats_loader.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/details/team_details_page.dart';
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
  bool _isLoadingPlayer = true;

  Equipe? _equipe;
  bool _isLoadingEquipe = true;

  Equipe? _country;
  bool _isLoadingCountry = true;

  PlayerStats? _playerStats;
  bool _isLoadingPlayerStats = true;

  bool _isPersonalMode = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer().then((_) {
      _loadEquipe();
      _loadCountry();
      _loadPlayerStats();
    });
  }

  Future<void> _loadPlayer() async {
    try {
      final joueur = await RepositoryProvider.joueurRepository
          .fetchJoueurById(widget.playerId);

      setState(() {
        _joueur = joueur;
        _isLoadingPlayer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPlayer = false;
      });
    }
  }

  Future<void> _loadEquipe() async {
    try {
      Equipe? equipe = await RepositoryProvider.equipeRepository
          .fetchEquipeById(_joueur!.equipeId);

      setState(() {
        _equipe = equipe;
        _isLoadingEquipe = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEquipe = false;
      });
    }
  }

  Future<void> _loadCountry() async {
    try {
      if (_joueur!.equipeNationaleId != null) {
        Equipe? country = await RepositoryProvider.equipeRepository
            .fetchEquipeById(_joueur!.equipeNationaleId!);

        if (!mounted) return;
        setState(() {
          _country = country;
          _isLoadingCountry = false;
        });
        return;
      } else if (_joueur!.nationalite != null) {
        List<Equipe> country = await RepositoryProvider.equipeRepository
            .searchEquipes(_joueur!.nationalite!);
        if (!mounted) return;
        if (country.isNotEmpty) {
          setState(() {
            _country = country[0];
            _isLoadingCountry = false;
          });
          return;
        }
        setState(() {
          _country = null;
          _isLoadingCountry = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCountry = false;
      });
    }
  }

  Future<void> _loadPlayerStats() async {
    try {
      final stats = await StatsLoader.getPlayerStats(_joueur!);

      setState(() {
        _playerStats = stats;
        _isLoadingPlayerStats = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur lors de la récupération des stats du joueur : $e'),
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() {
        _isLoadingPlayerStats = false;
        _playerStats = PlayerStats(
            matchsJoues: 0,
            butsMarques: 0,
            eluMvp: 0,
            votesMvp: 0,
            userMatchsJoues: 0,
            userButsMarques: 0,
            userEluMvp: 0,
            userVotesMvp: 0);
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
      body: _isLoadingPlayer
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
        SliverToBoxAdapter(child: _buildModeSwitch()),
        _buildStatsBlock(),
      ],
    );
  }

  Widget _buildStatsBlock() {
    return SliverToBoxAdapter(
      child: _isLoadingPlayerStats
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
                            ? _playerStats!.userMatchsJoues.toString()
                            : _playerStats!.matchsJoues.toString(),
                        icon: Icons.sports,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode ? "Buts vus" : "Buts marqués",
                        value: _isPersonalMode
                            ? _playerStats!.userButsMarques.toString()
                            : _playerStats!.butsMarques.toString(),
                        icon: Icons.sports_soccer,
                      ),
                      SimpleStatCard(
                        title: _isPersonalMode ? "Mes votes MVP" : "Votes MVP",
                        value: _isPersonalMode
                            ? _playerStats!.userVotesMvp.toString()
                            : _playerStats!.votesMvp.toString(),
                        icon: Icons.how_to_vote,
                      ),
                      SimpleStatCard(
                        title: "Élu MVP",
                        value: _isPersonalMode
                            ? _playerStats!.userEluMvp.toString()
                            : _playerStats!.eluMvp.toString(),
                        icon: Icons.star,
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
                child: Image.network(
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${_joueur!.prenom} ${_joueur!.nom}",
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _isLoadingEquipe && _isLoadingCountry
                          ? Text(
                              "Chargement...",
                              style: TextStyle(
                                color: ColorPalette.textSecondary(context),
                                fontSize: 14,
                              ),
                            )
                          : _equipe == null && _country == null
                              ? const SizedBox.shrink()
                              : _equipe != null
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TeamDetailsPage(
                                                    teamId: _equipe!.id),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          if (_equipe!.logoPath != null) ...[
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Image.network(
                                                _equipe!.logoPath!,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            _equipe!.nom,
                                            style: TextStyle(
                                              color: ColorPalette.textSecondary(
                                                  context),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                      const SizedBox(width: 6),
                      _country != null
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TeamDetailsPage(teamId: _country!.id),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  if (_country!.logoPath != null) ...[
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Image.network(
                                        _country!.logoPath!,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  if (_joueur!.dateNaissance != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "${calculateAge(_joueur!.dateNaissance!)} ans",
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ' - ',
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMMM yyyy', 'fr_FR')
                              .format(_joueur!.dateNaissance!),
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
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
