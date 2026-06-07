import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/get_joueurs_tries_par_nombre_de_votes.dart';
import 'package:scorescope/utils/handle_data/open_bottom_sheet_and_vote_mvp.dart';
import 'package:scorescope/utils/images/getButIcon.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/build_avatar.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/details/player_details_page.dart';
import 'package:scorescope/widgets/match_details_tabs/player_tile.dart';

enum _FormationMode { grid, pos, flat }

class CompositionsTab extends StatefulWidget {
  final MatchModel match;
  final Future<void> Function()? onRefresh;

  const CompositionsTab({
    super.key,
    required this.match,
    this.onRefresh,
  });

  @override
  State<CompositionsTab> createState() => _CompositionsTabState();
}

class _CompositionsTabState extends State<CompositionsTab> {
  MatchModel? localMatch;

  @override
  void initState() {
    super.initState();
    localMatch = widget.match;
  }

  void _updateVotes(String userId, Map<String, dynamic> result) {
    if (localMatch == null) return;
    if (result["joueur"] != null) {
      setState(() {
        localMatch!.voterPourMVP(userId: userId, joueurId: result["joueur"].id);
      });
    } else if (result["enleverVote"] == true) {
      setState(() {
        localMatch!.enleverVote(userId: userId);
      });
    }
  }

  ({List<MatchJoueur> titulaires, List<MatchJoueur> remplacants})
      _separerJoueurs(List<MatchJoueur> joueurs) {
    return (
      titulaires: joueurs.where((j) => j.isStarter == true).toList(),
      remplacants: joueurs.where((j) => j.isStarter == false).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MatchModel match = localMatch ?? widget.match;
    final Map<String, int> votesCount = match.getAllVoteCounts();

    if (match.joueursEquipeDomicile.isEmpty ||
        match.joueursEquipeExterieur.isEmpty) {
      return Center(
        child: Text(
          translate.laCompositionNEstPasEncoreDisponible,
          style: TextStyle(
            fontSize: 16,
            color: ColorPalette.textAccent(context),
          ),
        ),
      );
    }

    final domicile = _separerJoueurs(match.joueursEquipeDomicile);
    final exterieur = _separerJoueurs(match.joueursEquipeExterieur);

    final bool hasRemplacants =
        domicile.remplacants.isNotEmpty || exterieur.remplacants.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh ?? () async {},
          color: ColorPalette.accent(context),
          backgroundColor: ColorPalette.background(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _buildTeamSection(
                    context,
                    teamName: widget.match.equipeDomicile.nom,
                    logoUrl: widget.match.equipeDomicile.logoPath,
                    titulaires: domicile.titulaires,
                    votesCount: votesCount,
                    isReversed: false,
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: ColorPalette.divider(context)),
                  const SizedBox(height: 4),
                  _buildTeamSection(
                    context,
                    teamName: widget.match.equipeExterieur.nom,
                    logoUrl: widget.match.equipeExterieur.logoPath,
                    titulaires: exterieur.titulaires,
                    votesCount: votesCount,
                    isReversed: true,
                  ),
                  if (hasRemplacants)
                    ..._buildTeamsLists(
                      domicileRemplacants: domicile.remplacants,
                      exterieurRemplacants: exterieur.remplacants,
                    ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamSection(
    BuildContext context, {
    required String teamName,
    String? logoUrl,
    required List<MatchJoueur> titulaires,
    required Map<String, int> votesCount,
    required bool isReversed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isReversed) _buildTeamHeader(context, teamName, logoUrl, true),
        const SizedBox(height: 16),
        FormationView(
          joueurs: titulaires,
          isReversed: isReversed,
          votesCount: votesCount,
          match: localMatch ?? widget.match,
          onLocalUpdate: _updateVotes,
        ),
        if (isReversed) _buildTeamHeader(context, teamName, logoUrl, false),
      ],
    );
  }

  List<Widget> _buildTeamsLists({
    required List<MatchJoueur> domicileRemplacants,
    required List<MatchJoueur> exterieurRemplacants,
  }) {
    final List<MatchJoueur> joueursDomicileTries =
        getJoueursTriesParNombreDeVotes(
      domicileRemplacants,
      widget.match,
    ).where((j) => j.joueur != null).toList();

    final List<MatchJoueur> joueursExterieurTries =
        getJoueursTriesParNombreDeVotes(
      exterieurRemplacants,
      widget.match,
    ).where((j) => j.joueur != null).toList();

    if (joueursDomicileTries.isEmpty && joueursExterieurTries.isEmpty) {
      return [const SizedBox.shrink()];
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            translate.remplacants,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTeamHeader(
                    context,
                    widget.match.equipeDomicile.nomCourt ??
                        widget.match.equipeDomicile.nom,
                    widget.match.equipeDomicile.logoPath,
                    true,
                  ),
                  ...joueursDomicileTries.map((player) => playerTile(
                        joueur: player.joueur!,
                        onTap: () async {
                          final AppUser? user =
                              RepositoryProvider.userRepository.currentUser;
                          if (user != null &&
                              widget.match.isScheduled == false) {
                            final Map<String, dynamic> result =
                                await openBottomSheetAndVoteMVP(
                              context: context,
                              match: widget.match,
                              preselectedPlayer: player.joueur,
                              initialUserVote: null,
                            );
                            _updateVotes(user.uid, result);
                          }
                        },
                        context: context,
                        match: widget.match,
                        isUserVote: false,
                      )),
                ],
              ),
            ),
            Container(width: 1, color: ColorPalette.surface(context)),
            Expanded(
              child: Column(
                children: [
                  _buildTeamHeader(
                    context,
                    widget.match.equipeExterieur.nomCourt ??
                        widget.match.equipeExterieur.nom,
                    widget.match.equipeExterieur.logoPath,
                    true,
                  ),
                  ...joueursExterieurTries.map((player) => playerTile(
                        joueur: player.joueur!,
                        onTap: () async {
                          final AppUser? user =
                              RepositoryProvider.userRepository.currentUser;
                          if (user != null &&
                              widget.match.isScheduled == false) {
                            final Map<String, dynamic> result =
                                await openBottomSheetAndVoteMVP(
                              context: context,
                              match: widget.match,
                              preselectedPlayer: player.joueur,
                              initialUserVote: null,
                            );
                            _updateVotes(user.uid, result);
                          } else if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerDetailsPage(
                                    playerId: player.joueur!.id),
                              ),
                            );
                          }
                        },
                        context: context,
                        match: widget.match,
                        isUserVote: false,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildTeamHeader(
    BuildContext context,
    String name,
    String? logoUrl,
    bool lineUnder,
  ) {
    return Column(
      children: [
        if (!lineUnder)
          Container(height: 1, color: ColorPalette.divider(context)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (logoUrl != null)
                CachedNetworkImage(imageUrl: logoUrl, width: 32, height: 32),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textAccent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (lineUnder)
          Container(height: 1, color: ColorPalette.divider(context)),
      ],
    );
  }
}

class FormationView extends StatelessWidget {
  final List<MatchJoueur> joueurs;
  final bool isReversed;
  final Map<String, int> votesCount;
  final MatchModel match;
  final Function(String userId, Map<String, dynamic> result) onLocalUpdate;

  const FormationView({
    super.key,
    required this.joueurs,
    this.isReversed = false,
    required this.votesCount,
    required this.match,
    required this.onLocalUpdate,
  });

  _FormationMode _detectMode() {
    if (joueurs.any((j) => j.grid != null)) {
      // Mode A seulement si les 11 sont là
      if (joueurs.where((j) => j.grid != null).length == 11) {
        return _FormationMode.grid;
      }
      return _FormationMode.flat;
    }
    if (joueurs.any((j) => j.pos != null)) return _FormationMode.pos;
    return _FormationMode.flat;
  }

  Map<int, List<MatchJoueur>> _groupByRow() {
    final Map<int, List<MatchJoueur>> rows = {};
    for (var j in joueurs) {
      if (j.grid == null) continue;
      final parts = j.grid!.split(":");
      final row = int.tryParse(parts[0]) ?? 0;
      rows.putIfAbsent(row, () => []).add(j);
    }
    return rows;
  }

  Map<int, List<MatchJoueur>> _groupByPos() {
    const posOrder = {'G': 0, 'D': 1, 'M': 2, 'A': 3, 'F': 3};
    final Map<int, List<MatchJoueur>> rows = {};
    for (var j in joueurs) {
      final rowIndex = posOrder[j.pos] ?? 4;
      rows.putIfAbsent(rowIndex, () => []).add(j);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _detectMode();

    if (mode == _FormationMode.flat) {
      return _buildFlatList(context);
    }

    final rows = mode == _FormationMode.grid ? _groupByRow() : _groupByPos();
    final sortedKeys = rows.keys.toList()..sort();
    final displayKeys = isReversed ? sortedKeys.reversed.toList() : sortedKeys;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: displayKeys.map((rowKey) {
        final rowPlayers = rows[rowKey]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowPlayers.reversed.map((j) {
              return Expanded(
                child: PlayerWidget(
                  matchJoueur: j,
                  nbVotes: votesCount[j.joueur?.id] ?? 0,
                  match: match,
                  onLocalUpdate: onLocalUpdate,
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlatList(BuildContext context) {
    List<MatchJoueur> joueursTries =
        getJoueursTriesParNombreDeVotes(joueurs, match);
    return Column(
      children: joueursTries.map((j) {
        if (j.joueur == null) return const SizedBox.shrink();
        return playerTile(
          joueur: j.joueur!,
          onTap: () {},
          context: context,
          match: match,
          isUserVote: false,
          afficherPos: true,
        );
      }).toList(),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final MatchJoueur matchJoueur;
  final int nbVotes;
  final MatchModel match;
  final Function(String userId, Map<String, dynamic> result) onLocalUpdate;

  const PlayerWidget({
    super.key,
    required this.matchJoueur,
    this.nbVotes = 0,
    required this.match,
    required this.onLocalUpdate,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  Joueur? joueur;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoueur();
  }

  Future<void> _loadJoueur() async {
    if (widget.matchJoueur.joueur?.id == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final result = await RepositoryProvider.joueurRepository
        .fetchJoueurById(widget.matchJoueur.joueur!.id);

    if (mounted) {
      setState(() {
        joueur = result;
        isLoading = false;
      });
    }
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required Icon icon,
    required int value,
    bool isHighlighted = false,
    bool isGold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isGold
            ? ColorPalette.warning(context)
            : isHighlighted
                ? ColorPalette.accent(context)
                : ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 2),
          Text(
            value.toString(),
            style: TextStyle(
              color: isGold ? Colors.black : ColorPalette.textPrimary(context),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = RepositoryProvider.userRepository.currentUser;

    if (isLoading) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (joueur == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: buildAvatar(player: null, context: context),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 75,
            child: Text(
              widget.matchJoueur.number != null
                  ? "#${widget.matchJoueur.number}"
                  : "?",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),
        ],
      );
    }

    final shortName = joueur!.fullName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          onTap: () async {
            if (user != null && widget.match.isScheduled == false) {
              final Map<String, dynamic> result =
                  await openBottomSheetAndVoteMVP(
                context: context,
                match: widget.match,
                preselectedPlayer: joueur,
                initialUserVote: null,
              );
              widget.onLocalUpdate(user.uid, result);
            } else if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerDetailsPage(playerId: joueur!.id),
                ),
              );
            }
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerDetailsPage(playerId: joueur!.id),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: buildAvatar(player: joueur, context: context),
              ),
              if (widget.match.getPlayerNbButs(joueur!.id) > 0)
                Positioned(
                  bottom: 0,
                  right: -10,
                  child: _buildStatBadge(
                    context,
                    icon: getButIcon(joueur!.id, widget.match, context),
                    value: widget.match.getPlayerNbButs(joueur!.id),
                    isHighlighted: true,
                  ),
                ),
              if (widget.match.getPlayerNbPassesDe(joueur!.id) > 0)
                Positioned(
                  bottom: 0,
                  left: -10,
                  child: _buildStatBadge(
                    context,
                    icon: Icon(
                      Icons.adjust,
                      size: 10,
                      color: ColorPalette.textPrimary(context),
                    ),
                    value: widget.match.getPlayerNbPassesDe(joueur!.id),
                    isHighlighted: true,
                  ),
                ),
              Positioned(
                top: -3,
                right: -10,
                child: _buildStatBadge(
                  context,
                  icon: Icon(
                    Icons.star,
                    size: 10,
                    color: (widget.match.getMvpId() == joueur!.id)
                        ? Colors.black
                        : ColorPalette.textPrimary(context),
                  ),
                  value: widget.nbVotes,
                  isHighlighted: widget.match.mvpVotes[user?.uid] == joueur!.id,
                  isGold: widget.match.getMvpId() == joueur!.id,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 75,
          child: Text(
            shortName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
