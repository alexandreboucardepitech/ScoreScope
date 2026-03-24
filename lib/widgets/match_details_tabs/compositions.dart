import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/open_bottom_sheet_and_vote_mvp.dart';
import 'package:scorescope/utils/ui/build_avatar.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/details/player_details_page.dart';

class CompositionsTab extends StatefulWidget {
  final MatchModel match;

  const CompositionsTab({
    super.key,
    required this.match,
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

  void _updateVotes(String userId, String? playerSelectedId) {
    if (localMatch == null) return;
    if (playerSelectedId != null) {
      setState(() {
        localMatch!.voterPourMVP(userId: userId, joueurId: playerSelectedId);
      });
    } else {
      setState(() {
        localMatch!.enleverVote(userId: userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> votesCount =
        localMatch?.getAllVoteCounts() ?? widget.match.getAllVoteCounts();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _buildTeamSection(
                  context,
                  teamName: widget.match.equipeDomicile.nom,
                  logoUrl: widget.match.equipeDomicile.logoPath,
                  joueurs: widget.match.joueursEquipeDomicile,
                  votesCount: votesCount,
                  isReversed: false,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: ColorPalette.divider(context),
                ),
                const SizedBox(height: 4),
                _buildTeamSection(
                  context,
                  teamName: widget.match.equipeExterieur.nom,
                  logoUrl: widget.match.equipeExterieur.logoPath,
                  joueurs: widget.match.joueursEquipeExterieur,
                  votesCount: votesCount,
                  isReversed: true,
                ),
                const SizedBox(height: 24),
              ],
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
    required List<MatchJoueur> joueurs,
    required Map<String, int> votesCount,
    required bool isReversed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isReversed) _buildTeamHeader(context, teamName, logoUrl, true),
        const SizedBox(height: 16),
        FormationView(
          joueurs: joueurs,
          isReversed: isReversed,
          votesCount: votesCount,
          match: localMatch ?? widget.match,
          onLocalUpdate: _updateVotes,
        ),
        if (isReversed) _buildTeamHeader(context, teamName, logoUrl, false),
      ],
    );
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
          Container(
            height: 1,
            color: ColorPalette.divider(context),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (logoUrl != null)
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(logoUrl),
                  backgroundColor: Colors.transparent,
                ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
        if (lineUnder)
          Container(
            height: 1,
            color: ColorPalette.divider(context),
          ),
      ],
    );
  }
}

class FormationView extends StatelessWidget {
  final List<MatchJoueur> joueurs;
  final bool isReversed;
  final Map<String, int> votesCount;
  final MatchModel match;
  final Function(String userId, String? playerId) onLocalUpdate;

  const FormationView({
    super.key,
    required this.joueurs,
    this.isReversed = false,
    required this.votesCount,
    required this.match,
    required this.onLocalUpdate,
  });

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

  @override
  Widget build(BuildContext context) {
    final rows = _groupByRow();
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
            children: rowPlayers.map((j) {
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
}

class PlayerWidget extends StatefulWidget {
  final MatchJoueur matchJoueur;
  final int nbVotes;
  final MatchModel match;
  final Function(String userId, String? playerId) onLocalUpdate;

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
    if (widget.matchJoueur.joueur?.id == null) return;

    final result = await RepositoryProvider.joueurRepository
        .fetchJoueurById(widget.matchJoueur.joueur!.id);

    if (mounted) {
      setState(() {
        joueur = result;
        isLoading = false;
      });
    }
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

    final shortName = joueur?.nom ?? "?";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          onTap: () async {
            if (user != null) {
              final selectedPlayer = await openBottomSheetAndVoteMVP(
                context: context,
                match: widget.match,
                preselectedPlayer: joueur,
                initialUserVote: null,
              );
              widget.onLocalUpdate(user.uid, selectedPlayer?.id);
            }
          },
          onLongPress: () {
            if (joueur != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerDetailsPage(playerId: joueur!.id),
                ),
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: buildAvatar(player: joueur, context: context),
              ),
              Positioned(
                bottom: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.match.mvpVotes[user?.uid] == joueur?.id
                        ? ColorPalette.accent(context)
                        : ColorPalette.surface(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.nbVotes.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        )
      ],
    );
  }
}
