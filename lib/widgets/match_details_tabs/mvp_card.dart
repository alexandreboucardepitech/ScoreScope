import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/build_avatar.dart';
import 'package:scorescope/utils/ui/gradient_button.dart';
import 'package:scorescope/views/details/player_details_page.dart';
import '../../models/joueur.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class MvpVoteEntry {
  final Joueur joueur;
  final Equipe? equipe;
  final int voteCount;
  final double percentage;

  const MvpVoteEntry({
    required this.joueur,
    this.equipe,
    required this.voteCount,
    required this.percentage,
  });
}

class MvpCard extends StatelessWidget {
  final List<MvpVoteEntry> topPlayers;
  final Joueur? userVote;
  final VoidCallback? onVotePressed;

  const MvpCard({
    super.key,
    this.topPlayers = const [],
    this.userVote,
    this.onVotePressed,
  });

  bool get _hasUserVoted => userVote != null;

  bool _isUserVote(String joueurId) => userVote?.id == joueurId;

  bool get _userVoteShownInPodium =>
      userVote == null || topPlayers.any((e) => e.joueur.id == userVote!.id);

  @override
  Widget build(BuildContext context) {
    final hasPlayers = topPlayers.isNotEmpty;

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    translate.mvpDuMatch,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.textPrimary(context),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!hasPlayers) ...[
              Row(
                children: [
                  buildAvatar(player: null, context: context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate.aucunMvpElu,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          translate.soisLePremierAVoter,
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorPalette.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _VoteButton(
                    hasVoted: _hasUserVoted,
                    onPressed: onVotePressed,
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _TopPlayerRow(
                      entry: topPlayers[0],
                      isUserVote: _isUserVote(topPlayers[0].joueur.id),
                    ),
                  ),
                  _VoteButton(
                    hasVoted: _hasUserVoted,
                    onPressed: onVotePressed,
                  ),
                ],
              ),
              if (topPlayers.length >= 2)
                _PodiumRow(
                  rank: 2,
                  entry: topPlayers[1],
                  isUserVote: _isUserVote(topPlayers[1].joueur.id),
                ),
              if (topPlayers.length >= 3)
                _PodiumRow(
                  rank: 3,
                  entry: topPlayers[2],
                  isUserVote: _isUserVote(topPlayers[2].joueur.id),
                ),
              if (!_userVoteShownInPodium) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      size: 14,
                      color: ColorPalette.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${translate.votreVote} : ${userVote!.fullName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorPalette.textSecondary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TopPlayerRow extends StatelessWidget {
  final MvpVoteEntry entry;
  final bool isUserVote;

  const _TopPlayerRow({required this.entry, required this.isUserVote});

  @override
  Widget build(BuildContext context) {
    final voteLabel =
        '${entry.percentage.toStringAsFixed(0)}% · ${translate.xVoteX(entry.voteCount.toString(), entry.voteCount > 1 ? 's' : '')}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerDetailsPage(playerId: entry.joueur.id),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildAvatar(player: entry.joueur, context: context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.joueur.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isUserVote
                              ? ColorPalette.accent(context)
                              : ColorPalette.textAccent(context),
                        ),
                      ),
                    ),
                    if (isUserVote) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.how_to_vote,
                        size: 18,
                        color: ColorPalette.success(context),
                      ),
                    ],
                  ],
                ),
                if (entry.equipe != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      buildTeamLogo(context, entry.equipe!.logoPath,
                          clickable: false, size: 18),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        entry.equipe!.nom,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  voteLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumRow extends StatelessWidget {
  final int rank;
  final MvpVoteEntry entry;
  final bool isUserVote;

  const _PodiumRow({
    required this.rank,
    required this.entry,
    required this.isUserVote,
  });

  @override
  Widget build(BuildContext context) {
    final medal = rank == 2 ? '🥈' : '🥉';
    final voteLabel =
        '${entry.percentage.toStringAsFixed(0)}% · ${translate.xVoteX(entry.voteCount.toString(), entry.voteCount > 1 ? 's' : '')}';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.joueur.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isUserVote ? FontWeight.w600 : FontWeight.normal,
                      color: isUserVote
                          ? ColorPalette.accent(context)
                          : ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
                if (isUserVote) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.how_to_vote,
                    size: 18,
                    color: ColorPalette.success(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            voteLabel,
            style: TextStyle(
              fontSize: 12,
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final bool hasVoted;
  final VoidCallback? onPressed;

  const _VoteButton({required this.hasVoted, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final accent = ColorPalette.accent(context);

    if (hasVoted) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh, size: 16),
        label: Text(translate.changer),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return GradientButton(
      onPressed: onPressed,
      icon: Icons.how_to_vote,
      label: translate.voter,
    );
  }
}
