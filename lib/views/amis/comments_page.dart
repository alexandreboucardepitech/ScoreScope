import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:scorescope/widgets/fil_actu_amis/comments/comment_input_field.dart';
import 'package:scorescope/widgets/fil_actu_amis/reaction_row.dart';
import 'package:scorescope/widgets/fil_actu_amis/match_regarde_ami_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  /// Mode A : données complètes déjà chargées
  final MatchRegardeAmi? entry;

  /// Mode B : navigation légère (notifications)
  final String? matchId;
  final String? ownerUserId;

  final Map<String, AppUser?> userCache;

  const CommentsPage({
    super.key,
    this.entry,
    this.matchId,
    this.ownerUserId,
    this.userCache = const {},
  }) : assert(
          entry != null || (matchId != null && ownerUserId != null),
          'Either entry or matchId + ownerUserId must be provided',
        );

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  MatchRegardeAmi? _entry;
  MatchUserData? _matchData;

  List<Commentaire> _comments = [];
  final Map<String, AppUser?> _userCache = {};

  bool _isLoading = false;
  bool _loadingReactionOp = false;
  bool _hasError = false;

  String? _currentUserId;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    _userCache.addAll(widget.userCache);
    _initCurrentUser();

    if (widget.entry != null) {
      _initFromEntry(widget.entry!);
    } else {
      _loadEntryFromIds();
    }
  }

  void _initFromEntry(MatchRegardeAmi entry) {
    _entry = entry;
    _matchData = entry.matchData;
    _comments = List.from(entry.matchData.comments);
    _refreshCommentsAndReactions();
  }

  Future<void> _loadEntryFromIds() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userRepo = RepositoryProvider.userRepository;
      final matchRepo = RepositoryProvider.matchRepository;
      final joueurRepo = RepositoryProvider.joueurRepository;

      final owner = await userRepo.fetchUserById(widget.ownerUserId!);
      final matchData = await userRepo.fetchUserMatchUserData(
        widget.ownerUserId!,
        widget.matchId!,
      );
      final match = await matchRepo.fetchMatchById(widget.matchId!);

      String? mvpName;
      if (matchData?.mvpVoteId != null) {
        final joueur = await joueurRepo.fetchJoueurById(matchData!.mvpVoteId!);
        mvpName = joueur?.fullName;
      }

      if (!mounted) return;

      _entry = MatchRegardeAmi(
        friend: owner!,
        matchData: matchData!,
        match: match,
        mvpName: mvpName,
      );

      _matchData = matchData;
      _comments = List.from(matchData.comments);

      await _refreshCommentsAndReactions();

      setState(() {
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint("Erreur CommentsPage: $e\n$st");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _initCurrentUser() async {
    try {
      final current = await RepositoryProvider.userRepository.getCurrentUser();
      _currentUserId = current?.uid;
    } catch (_) {
      _currentUserId = null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _refreshCommentsAndReactions() async {
    if (_entry == null || _matchData == null) return;

    final ownerUserId = _entry!.friend.uid;
    final matchId = _matchData!.matchId;

    try {
      final reactions = await RepositoryProvider.postRepository.fetchReactions(
        ownerUserId: ownerUserId,
        matchId: matchId,
        limit: 50,
      );

      final comments = await RepositoryProvider.postRepository.fetchComments(
        ownerUserId: ownerUserId,
        matchId: matchId,
        limit: 1000,
      );

      _matchData!.reactions = List.from(reactions);
      _comments = List.from(comments);

      for (final c in _comments) {
        if (!_userCache.containsKey(c.authorId)) {
          try {
            final user = await RepositoryProvider.userRepository
                .fetchUserById(c.authorId);
            _userCache[c.authorId] = user;
          } catch (_) {
            _userCache[c.authorId] = null;
          }
        }
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleReaction(String emoji) async {
    if (_currentUserId == null ||
        _loadingReactionOp ||
        _entry == null ||
        _matchData == null) return;

    setState(() => _loadingReactionOp = true);

    final ownerUserId = _entry!.friend.uid;
    final matchId = _matchData!.matchId;

    try {
      final existingForEmoji = _matchData!.reactions
          .where((r) => r.userId == _currentUserId && r.emoji == emoji)
          .toList();

      if (existingForEmoji.isNotEmpty) {
        await RepositoryProvider.postRepository.deleteReaction(
          ownerUserId: ownerUserId,
          matchId: matchId,
          authorId: _currentUserId!,
          emoji: emoji,
        );
      } else {
        await RepositoryProvider.postRepository.addReaction(
          ownerUserId: ownerUserId,
          matchId: matchId,
          authorId: _currentUserId!,
          emoji: emoji,
        );
      }

      await _refreshCommentsAndReactions();
    } finally {
      if (mounted) setState(() => _loadingReactionOp = false);
    }
  }

  Widget _buildCommentItem(BuildContext context, Commentaire c, int index) {
    final user = _userCache[c.authorId];
    final bgColor = index.isEven
        ? ColorPalette.tileBackground(context)
        : ColorPalette.listHeader(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              if (user == null) return;
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileView(
                    user: user,
                    onBackPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              );
              if (result == true) {
                await _refreshCommentsAndReactions();
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.border(context),
                image: user?.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user!.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: user?.photoUrl == null
                  ? Text(
                      user?.displayName?.characters.first.toUpperCase() ?? '?',
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.displayName ?? c.authorId,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.textPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(
                        c.createdAt,
                        locale: 'fr',
                      ),
                      style: TextStyle(
                        color: ColorPalette.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.text,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _entry == null || _matchData == null) {
      return const Scaffold(
        body: Center(child: Text("Erreur de chargement")),
      );
    }

    final ownerUserId = _entry!.friend.uid;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Détails"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final visibleHeight = constraints.maxHeight;
            final minHeight = visibleHeight + bottomInset;

            return SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: minHeight < 0 ? 0 : minHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 8),
                          child: MatchRegardeAmiCard(
                            entry: _entry!,
                            matchDetails: _entry!.match != null,
                            showInteractions: false,
                          ),
                        ),
                        Divider(color: ColorPalette.border(context), height: 1),
                        ReactionRow(
                          key: ValueKey(_matchData!.reactions.length),
                          matchUserData: _matchData!,
                          currentUserId: _currentUserId,
                          loading: _loadingReactionOp,
                          onToggle: _toggleReaction,
                          expanded: true,
                        ),
                        Divider(color: ColorPalette.border(context), height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(
                            "Commentaires",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: ColorPalette.textPrimary(context),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        if (_comments.isNotEmpty)
                          ...List<Widget>.generate(_comments.length * 2 - 1,
                              (i) {
                            if (i.isOdd) {
                              return Divider(
                                height: 1,
                                color: ColorPalette.border(context),
                              );
                            } else {
                              final index = i ~/ 2;
                              final c = _comments[index];
                              return _buildCommentItem(context, c, index);
                            }
                          })
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              "Pas encore de commentaires",
                              style: TextStyle(
                                color: ColorPalette.textSecondary(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: CommentInputField(
                          ownerUserId: ownerUserId,
                          matchId: _matchData!.matchId,
                          refreshComments: _refreshCommentsAndReactions,
                          defaultIsWriting: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
