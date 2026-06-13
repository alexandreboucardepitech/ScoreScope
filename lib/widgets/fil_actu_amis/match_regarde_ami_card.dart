import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/reaction.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/app_cache.dart';
import 'package:scorescope/utils/string/build_post_display_name.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/display_prolongations_penaltys.dart';
import 'package:scorescope/views/details/match_details_page.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:scorescope/widgets/fil_actu_amis/comments/comment_input_field.dart';
import 'package:scorescope/views/amis/comments_page.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'reaction_row.dart';
import 'comments/comments_preview.dart';

class MatchRegardeAmiCard extends StatefulWidget {
  final MatchRegardeAmi entry;
  final bool matchDetails;
  final bool showInteractions;

  const MatchRegardeAmiCard({
    super.key,
    required this.entry,
    this.matchDetails = true,
    this.showInteractions = true,
  });

  @override
  State<MatchRegardeAmiCard> createState() => _MatchRegardeAmiCardState();
}

class _MatchRegardeAmiCardState extends State<MatchRegardeAmiCard>
    with TickerProviderStateMixin {
  late MatchRegardeAmi entry;
  late final MatchUserData matchData;

  bool _isLoadingMatchData = false;

  String? _currentUserId;
  bool _loadingReactionOp = false;
  List<AppUser> _watchTogetherUsers = [];
  bool _expandWatchTogether = false;

  late final AnimationController _controller;
  late final Animation<double> _arrowAnim;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  final Map<String, AppUser?> _userCache = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _arrowAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    entry = widget.entry;
    matchData = entry.matchData;

    if (entry.match == null) {
      _isLoadingMatchData = true;
      _pulseController.repeat(reverse: true);
      _loadMatchData();
    }

    if (widget.showInteractions) {
      _initLocalState();
    } else {
      _initCurrentUserOnly();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadMatchData() async {
    final String? matchId = matchData.matchId;
    if (matchId == null) {
      if (mounted) setState(() => _isLoadingMatchData = false);
      return;
    }
    try {
      MatchModel? match = AppCache.getMatch(matchId);
      if (match == null) {
        match =
            await RepositoryProvider.matchRepository.fetchMatchById(matchId);
        if (match != null) AppCache.setMatch(matchId, match);
      }

      String? mvpName;
      final mvpId = matchData.mvpVoteId;
      if (mvpId != null) {
        mvpName = AppCache.getJoueurName(mvpId);
        if (mvpName == null) {
          final joueur =
              await RepositoryProvider.joueurRepository.fetchJoueurById(mvpId);
          if (joueur != null) {
            mvpName = joueur.fullName;
            AppCache.setJoueurName(mvpId, mvpName);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        entry = MatchRegardeAmi(
          friend: entry.friend,
          matchData: entry.matchData,
          match: match,
          mvpName: mvpName,
        );
        _isLoadingMatchData = false;
        _pulseController.stop();
      });
    } catch (e) {
      debugPrint('_loadMatchData error: $e');
      if (mounted) {
        setState(() {
          _isLoadingMatchData = false;
          _pulseController.stop();
        });
      }
    }
  }

  Future<void> _initCurrentUserOnly() async {
    try {
      final current = await RepositoryProvider.userRepository.getCurrentUser();
      _currentUserId = current?.uid;
    } catch (_) {
      _currentUserId = null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _initWatchTogether() async {
    final list = await RepositoryProvider.watchTogetherRepository
        .getFriendsWatchedWith(widget.entry.friend.uid, matchData.matchId);
    final ids = list
        .where((w) => w.status == 'accepted')
        .map((w) => w.friendId)
        .toList();
    final users = <AppUser>[];
    for (final id in ids) {
      final u = await RepositoryProvider.userRepository.fetchUserById(id);
      if (u != null) users.add(u);
    }
    _watchTogetherUsers = users;
  }

  Future<void> _initLocalState() async {
    await _initCurrentUserOnly();
    await _initWatchTogether();
    await _refreshCommentsAndReactions(commentsLimit: 3);
  }

  Future<void> _refreshCommentsAndReactions({int? commentsLimit}) async {
    if (!mounted) return;
    setState(() {});
    final ownerId = entry.friend.uid;
    final matchId = matchData.matchId;
    try {
      final reactions = await RepositoryProvider.postRepository.fetchReactions(
        ownerUserId: ownerId,
        matchId: matchId,
        limit: 100,
        removeBlockedUsersReactions: true,
      );
      final comments = await RepositoryProvider.postRepository.fetchComments(
        ownerUserId: ownerId,
        matchId: matchId,
        limit: commentsLimit,
        removeBlockedUsersComments: true,
      );
      matchData.reactions = List<Reaction>.from(reactions);
      matchData.comments = List<Commentaire>.from(comments);
      for (final c in matchData.comments) {
        if (!_userCache.containsKey(c.authorId)) {
          try {
            _userCache[c.authorId] = await RepositoryProvider.userRepository
                .fetchUserById(c.authorId);
          } catch (_) {
            _userCache[c.authorId] = null;
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleReaction(String emoji) async {
    if (_currentUserId == null || _loadingReactionOp) return;
    setState(() => _loadingReactionOp = true);
    final ownerId = entry.friend.uid;
    final matchId = matchData.matchId;
    final myId = _currentUserId!;
    try {
      final existingForEmoji = matchData.reactions
          .where((r) => r.userId == myId && r.emoji == emoji)
          .toList();
      if (existingForEmoji.isNotEmpty) {
        await RepositoryProvider.postRepository.deleteReaction(
          ownerUserId: ownerId,
          matchId: matchId,
          authorId: myId,
          emoji: emoji,
        );
      } else {
        await RepositoryProvider.postRepository.addReaction(
          ownerUserId: ownerId,
          matchId: matchId,
          authorId: myId,
          emoji: emoji,
        );
      }
      await _refreshCommentsAndReactions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réaction : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingReactionOp = false);
    }
  }

  String _formatMatchDate(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  Widget _avatarCircle(AppUser user, {double size = 28}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.pictureBackground(context),
        border: Border.all(color: ColorPalette.border(context), width: 2),
      ),
      child: ClipOval(
        child: user.photoUrl != null
            ? CachedNetworkImage(
                imageUrl: user.photoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialsText(user, size),
              )
            : _initialsText(user, size),
      ),
    );
  }

  Widget _initialsText(AppUser user, double size) {
    return Center(
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontWeight: FontWeight.w800,
          fontSize: size * 0.45,
        ),
      ),
    );
  }

  Widget _buildUsersStack(AppUser friend) {
    final allUsers = [friend, ..._watchTogetherUsers];
    final displayUsers = allUsers.take(4).toList();
    const double avatarSize = 32;
    final double overlap = avatarSize * 0.4;
    return SizedBox(
      width: avatarSize + (displayUsers.length - 1) * overlap,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = displayUsers.length - 1; i >= 0; i--)
            Positioned(
              left: i * overlap,
              child: _avatarCircle(displayUsers[i], size: avatarSize),
            ),
        ],
      ),
    );
  }

  Color _pulseColor({required bool emphase}) {
    final Color from = emphase
        ? ColorPalette.pictureBackground(context)
        : ColorPalette.tileBackground(context);
    final Color to = emphase
        ? ColorPalette.border(context)
        : ColorPalette.pictureBackground(context);
    return Color.lerp(from, to, _pulseAnim.value)!;
  }

  Widget _pulse({
    required double height,
    required double width,
    double radius = 6,
    bool emphase = false,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _pulseColor(emphase: emphase),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _skeletonDivider() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        height: 1,
        color: _pulseColor(emphase: false),
      ),
    );
  }

  Widget _skeletonVertDivider() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        width: 1,
        height: 60,
        color: _pulseColor(emphase: false),
      ),
    );
  }

  Widget _skeletonTeamColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pulse(height: 36, width: 36, radius: 10, emphase: true),
        const SizedBox(height: 6),
        _pulse(height: 11, width: 72, emphase: false),
      ],
    );
  }

  Widget _skeletonScore() {
    return Column(
      children: [
        _pulse(height: 22, width: 56, radius: 6, emphase: true),
        const SizedBox(height: 6),
        _pulse(height: 10, width: 88, emphase: false),
      ],
    );
  }

  Widget _skeletonEmojiColumn() {
    return Column(
      children: [
        _pulse(height: 40, width: 40, radius: 20, emphase: true),
        const SizedBox(height: 6),
        _pulse(height: 11, width: 52, emphase: false),
      ],
    );
  }

  Widget _buildMatchSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorPalette.tileBackground(context),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: ColorPalette.border(context), width: 3),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: _skeletonTeamColumn())),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _skeletonScore(),
              ),
              Expanded(child: Center(child: _skeletonTeamColumn())),
            ],
          ),
          const SizedBox(height: 12),
          _skeletonDivider(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: _skeletonEmojiColumn())),
              _skeletonVertDivider(),
              Expanded(child: Center(child: _skeletonEmojiColumn())),
            ],
          ),
          const SizedBox(height: 14),
          _skeletonDivider(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pulse(height: 16, width: 16, radius: 8, emphase: true),
              const SizedBox(width: 8),
              _pulse(height: 13, width: 90, emphase: false),
              const SizedBox(width: 6),
              _pulse(height: 13, width: 110, emphase: true),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> afficherCommentaire() {
    return [
      const SizedBox(height: 12),
      Divider(color: ColorPalette.border(context), height: 1),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 14,
              color: ColorPalette.textSecondary(context),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              matchData.commentaire!,
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final friend = entry.friend;
    final MatchModel? match = entry.match;
    final String relativeTime = matchData.watchedAt != null
        ? timeago.format(matchData.watchedAt!, locale: 'fr')
        : '';
    final Equipe? home = match?.equipeDomicile;
    final Equipe? away = match?.equipeExterieur;

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (_watchTogetherUsers.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileView(
                        user: friend,
                        onBackPressed: () => Navigator.pop(context)),
                  ),
                );
              } else {
                setState(() => _expandWatchTogether = true);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_expandWatchTogether) ...[
                  _buildUsersStack(friend),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDisplayNameText(
                          friend, _watchTogetherUsers, context),
                      if (relativeTime.isNotEmpty)
                        Text(
                          relativeTime,
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_watchTogetherUsers.isNotEmpty)
                  IconButton(
                    splashRadius: 20,
                    icon: RotationTransition(
                      turns: _arrowAnim,
                      child: Icon(Icons.expand_more,
                          color: ColorPalette.accent(context)),
                    ),
                    onPressed: () {
                      setState(() {
                        _expandWatchTogether = !_expandWatchTogether;
                        _expandWatchTogether
                            ? _controller.forward()
                            : _controller.reverse();
                      });
                    },
                  ),
              ],
            ),
          ),
          if (_expandWatchTogether)
            for (final user in [friend, ..._watchTogetherUsers]) ...[
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileView(
                        user: user,
                        onBackPressed: () => Navigator.pop(context)),
                  ),
                ),
                child: Row(
                  children: [
                    _avatarCircle(user, size: 36),
                    const SizedBox(width: 10),
                    Text(user.displayName,
                        style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          const SizedBox(height: 10),
          if (widget.matchDetails) ...[
            if (_isLoadingMatchData)
              _buildMatchSkeleton()
            else
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (match != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MatchDetailsPage(match: match)),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ColorPalette.tileBackground(context),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                        border: Border.all(
                            color: ColorPalette.border(context), width: 3),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (match != null &&
                              home != null &&
                              away != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (home.logoPath != null)
                                        CachedNetworkImage(
                                          imageUrl: home.logoPath!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.contain,
                                          errorWidget: (_, __, ___) => Icon(
                                              Icons.shield,
                                              size: 20,
                                              color: ColorPalette.textPrimary(
                                                  context)),
                                        ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(home.nom,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: ColorPalette.textPrimary(
                                                    context))),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                      ...displayProlongationsPenaltys(
                                        match: match,
                                        context: context,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatMatchDate(match.date),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: ColorPalette.textSecondary(
                                              context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (away.logoPath != null)
                                        CachedNetworkImage(
                                          imageUrl: away.logoPath!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.contain,
                                          errorWidget: (_, __, ___) => Icon(
                                              Icons.shield,
                                              size: 20,
                                              color: ColorPalette.textPrimary(
                                                  context)),
                                        ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(away.nom,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: ColorPalette.textPrimary(
                                                    context))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(
                                color: ColorPalette.border(context), height: 1),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      matchData.note != null
                                          ? getReactionEmoji(matchData.note!)
                                          : '😐',
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                    Text(
                                      matchData.note != null
                                          ? '${matchData.note}/10'
                                          : '${translate.nonNote}/10',
                                      style: TextStyle(
                                          color: ColorPalette.accent(context),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 60,
                                  color: ColorPalette.border(context)),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      matchData.visionnageMatch.emoji.isNotEmpty
                                          ? matchData.visionnageMatch.emoji
                                          : '❓',
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                    Text(
                                      matchData.visionnageMatch.label.isNotEmpty
                                          ? matchData.visionnageMatch.label
                                          : '?',
                                      style: TextStyle(
                                          color: ColorPalette.accent(context),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                              color: ColorPalette.border(context), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.how_to_vote,
                                  size: 18,
                                  color: ColorPalette.accentVariant(context)),
                              const SizedBox(width: 8),
                              Text(translate.votePourMvp + ' : ',
                                  style: TextStyle(
                                      color: ColorPalette.textPrimary(context),
                                      fontWeight: FontWeight.bold)),
                              Flexible(
                                child: Text(
                                  entry.mvpName != null &&
                                          entry.mvpName!.isNotEmpty
                                      ? entry.mvpName!
                                      : translate.pasDeVotePourLeMvp,
                                  style: TextStyle(
                                    color: entry.mvpName != null &&
                                            entry.mvpName!.isNotEmpty
                                        ? ColorPalette.accent(context)
                                        : ColorPalette.textSecondary(context),
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (matchData.commentaire != null &&
                              matchData.commentaire!.isNotEmpty)
                            ...afficherCommentaire(),
                        ],
                      ),
                    ),
                  ),
                  if (matchData.favourite)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(Icons.star,
                          size: 24, color: ColorPalette.accent(context)),
                    ),
                ],
              ),
          ] else ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: match != null
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MatchDetailsPage(match: match)))
                      : null,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: ColorPalette.tileBackground(context),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                      border: Border.all(
                          color: ColorPalette.border(context), width: 3),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    matchData.note != null
                                        ? getReactionEmoji(matchData.note!)
                                        : '😐',
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                  Text(
                                    matchData.note != null
                                        ? '${matchData.note}/10'
                                        : '${translate.nonNote}/10',
                                    style: TextStyle(
                                        color: ColorPalette.accent(context),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 60,
                                color: ColorPalette.border(context)),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    matchData.visionnageMatch.emoji.isNotEmpty
                                        ? matchData.visionnageMatch.emoji
                                        : '❓',
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                  Text(
                                    matchData.visionnageMatch.label.isNotEmpty
                                        ? matchData.visionnageMatch.label
                                        : '?',
                                    style: TextStyle(
                                        color: ColorPalette.accent(context),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: ColorPalette.border(context), height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.how_to_vote,
                                size: 18,
                                color: ColorPalette.accentVariant(context)),
                            const SizedBox(width: 8),
                            Text(translate.votePourMvp + ' :',
                                style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                    fontWeight: FontWeight.bold)),
                            Flexible(
                              child: Text(
                                entry.mvpName != null &&
                                        entry.mvpName!.isNotEmpty
                                    ? entry.mvpName!
                                    : translate.pasDeVotePourLeMvp,
                                style: TextStyle(
                                  color: entry.mvpName != null &&
                                          entry.mvpName!.isNotEmpty
                                      ? ColorPalette.accent(context)
                                      : ColorPalette.textSecondary(context),
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (matchData.commentaire != null &&
                            matchData.commentaire!.isNotEmpty)
                          ...afficherCommentaire(),
                      ],
                    ),
                  ),
                ),
                if (matchData.favourite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.star,
                        size: 24, color: ColorPalette.accent(context)),
                  ),
              ],
            ),
          ],
          if (widget.showInteractions) ...[
            ReactionRow(
              matchUserData: matchData,
              currentUserId: _currentUserId,
              loading: _loadingReactionOp,
              onToggle: _toggleReaction,
            ),
            if (matchData.comments.isEmpty)
              CommentInputField(
                ownerUserId: entry.friend.uid,
                matchId: matchData.matchId,
                refreshComments: _refreshCommentsAndReactions,
              ),
            if (matchData.comments.isNotEmpty)
              CommentsPreview(
                comments: matchData.comments,
                userCache: _userCache,
                onSeeAll: () async {
                  final changed = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CommentsPage(entry: entry, userCache: _userCache),
                    ),
                  );
                  if (changed == true) {
                    await _refreshCommentsAndReactions(commentsLimit: 3);
                    setState(() {});
                  }
                },
                onProfileUpdated: () async {
                  await _refreshCommentsAndReactions(commentsLimit: 3);
                },
              ),
          ],
        ],
      ),
    );

    if (match != null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  CommentsPage(entry: entry, userCache: _userCache)),
        ),
        child: cardContent,
      );
    }
    return cardContent;
  }
}
