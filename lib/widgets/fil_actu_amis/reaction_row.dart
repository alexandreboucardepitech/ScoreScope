import 'package:flutter/material.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/fil_actu_amis/emojis/emoji_picker.dart';
import 'package:scorescope/views/profile/profile.dart';

const double _avatarSize = 30.0;
const double _avatarSizeExpanded = 36.0;
const double _avatarOverlap = 12.0;

bool currentUserReactedWith(
  String emoji,
  String? currentUserId,
  MatchUserData matchUserData,
) {
  if (currentUserId == null) return false;
  final map = matchUserData.reactionsUserToEmojiMap();
  return map[currentUserId]?.contains(emoji) ?? false;
}

class ReactionRow extends StatefulWidget {
  final MatchUserData matchUserData;
  final String? currentUserId;
  final Future<void> Function(String emoji) onToggle;
  final bool loading;
  final bool expanded;

  const ReactionRow({
    required this.matchUserData,
    required this.onToggle,
    this.currentUserId,
    this.loading = false,
    this.expanded = false,
    super.key,
  });

  @override
  State<ReactionRow> createState() => _ReactionRowState();
}

class _ReactionRowState extends State<ReactionRow> {
  final List<String> _recentEmojis = [];
  final Map<String, AppUser?> _localUserCache = {};

  Future<void> _ensureUsersLoadedForEmoji(String emoji) async {
    final ids = _userIdsForEmoji(emoji);
    final toLoad = ids
        .where(
          (id) => !_localUserCache.containsKey(id),
        )
        .toList();
    if (toLoad.isEmpty) return;

    for (final id in toLoad) {
      try {
        final user = await RepositoryProvider.userRepository.fetchUserById(id);
        _localUserCache[id] = user;
      } catch (_) {
        _localUserCache[id] = null;
      }
    }
    if (mounted) setState(() {});
  }

  List<String> _userIdsForEmoji(String emoji) {
    return widget.matchUserData.reactions
        .where((r) => r.emoji == emoji)
        .map((r) => r.userId)
        .toList();
  }

  void _openEmojiPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.tileBackground(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      )),
      builder: (ctx) {
        return EmojiPickerSheet(
          recent: _recentEmojis,
          onPick: (e) => Navigator.of(ctx).pop(e),
        );
      },
    );

    if (selected != null) {
      await widget.onToggle(selected);
      setState(() {
        _recentEmojis.remove(selected);
        _recentEmojis.insert(0, selected);
        if (_recentEmojis.length > 20) _recentEmojis.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous avez ajouté la réaction $selected'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expanded) {
      return _buildExpandedReactions(context);
    } else {
      return _buildCompactReactions(context);
    }
  }

  Widget _buildCompactReactions(BuildContext context) {
    final counts = widget.matchUserData.countsReactions();

    final defaultEmojis = ['🔥', '😮', '😭', '👀'];
    final defaultEntries = defaultEmojis
        .map(
          (e) => MapEntry(e, counts[e] ?? 0),
        )
        .toList();

    final custom = counts.keys
        .where(
          (k) => !defaultEmojis.contains(k),
        )
        .toList();
    custom.sort(
      (a, b) => (counts[b] ?? 0) - (counts[a] ?? 0),
    );

    final entries = [
      ...defaultEntries,
      ...custom.map(
        (e) => MapEntry(e, counts[e] ?? 0),
      )
    ];

    const double loaderMaxWidth = 18.0;
    const double gap = 8.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 2),
                        for (final e in entries)
                          _CompactReactionChip(
                            emoji: e.key,
                            count: e.value,
                            active: currentUserReactedWith(e.key,
                                widget.currentUserId, widget.matchUserData),
                            onTap: () async {
                              await widget.onToggle(e.key);
                              setState(() {
                                _recentEmojis.remove(e.key);
                                _recentEmojis.insert(0, e.key);
                                if (_recentEmojis.length > 20) {
                                  _recentEmojis.removeLast();
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.loading ? null : _openEmojiPicker,
                  child: Container(
                    width: 40,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorPalette.tileBackground(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ColorPalette.border(context),
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: gap),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: widget.loading ? loaderMaxWidth : 0,
            height: loaderMaxWidth,
            child: widget.loading
                ? const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedReactions(BuildContext context) {
    final counts = widget.matchUserData.countsReactions();

    final entries = counts.entries.toList()
      ..sort(
        (a, b) => (b.value).compareTo(a.value),
      );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 6),
                for (final e in entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: _EmojiInlineItem(
                      emoji: e.key,
                      count: e.value,
                      localUserCache: _localUserCache,
                      fetchUserIdsForEmoji: () => _userIdsForEmoji(e.key),
                      loadUsersForEmoji: () =>
                          _ensureUsersLoadedForEmoji(e.key),
                      onToggle: (emoji) async {
                        await widget.onToggle(emoji);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Vous avez ${currentUserReactedWith(emoji, widget.currentUserId, widget.matchUserData) ? 'supprimé' : 'ajouté'} la réaction $emoji'),
                          ),
                        );
                        setState(() {});
                      },
                      currentUserId: widget.currentUserId,
                      matchUserData: widget.matchUserData,
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.loading ? null : _openEmojiPicker,
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorPalette.tileSelected(context),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: ColorPalette.border(context),
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 22,
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: widget.loading ? 18 : 0,
            child: widget.loading
                ? const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CompactReactionChip extends StatelessWidget {
  final String emoji;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  const _CompactReactionChip({
    required this.emoji,
    required this.count,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: active
              ? ColorPalette.accent(context)
              : ColorPalette.tileBackground(context),
          border: Border.all(
            color: active
                ? ColorPalette.accent(context)
                : ColorPalette.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              count == 0 ? "+" : count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active
                    ? ColorPalette.textPrimary(context)
                    : ColorPalette.textSecondary(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EmojiInlineItem extends StatefulWidget {
  final String emoji;
  final int count;
  final Map<String, AppUser?> localUserCache;
  final List<String> Function() fetchUserIdsForEmoji;
  final Future<void> Function() loadUsersForEmoji;
  final Future<void> Function(String emoji) onToggle;
  final String? currentUserId;
  final MatchUserData matchUserData;

  const _EmojiInlineItem({
    required this.emoji,
    required this.count,
    required this.localUserCache,
    required this.fetchUserIdsForEmoji,
    required this.loadUsersForEmoji,
    required this.onToggle,
    required this.currentUserId,
    required this.matchUserData,
  });

  @override
  State<_EmojiInlineItem> createState() => _EmojiInlineItemState();
}

class _EmojiInlineItemState extends State<_EmojiInlineItem> {
  late List<String> _userIds;
  bool _expanded = false;

  static const double _emojiBoxSize = 64.0;
  static const double _emojiFontSize = 40.0;

  @override
  void initState() {
    super.initState();
    _userIds = widget.fetchUserIdsForEmoji();
    widget.loadUsersForEmoji();
  }

  Future<void> _toggleExpanded() async {
    final newVal = !_expanded;
    if (newVal) {
      await widget.loadUsersForEmoji();
      _userIds = widget.fetchUserIdsForEmoji();
    }
    setState(() {
      _expanded = newVal;
    });
  }

  Future<void> _addReaction() async {
    await widget.onToggle(widget.emoji);
    _userIds = widget.fetchUserIdsForEmoji();
    if (mounted) setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous avez ajouté la réaction ${widget.emoji}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayStackIds = _userIds.take(4).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          onLongPress: () async {
            await widget.onToggle(widget.emoji);
            _userIds = widget.fetchUserIdsForEmoji();
            if (mounted) setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Vous avez ${currentUserReactedWith(widget.emoji, widget.currentUserId, widget.matchUserData) ? 'supprimé' : 'ajouté'} la réaction ${widget.emoji}'),
              ),
            );
          },
          child: SizedBox(
            width: _emojiBoxSize,
            height: _emojiBoxSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: _emojiFontSize),
                  ),
                ),
                if (_expanded &&
                    currentUserReactedWith(
                          widget.emoji,
                          widget.currentUserId,
                          widget.matchUserData,
                        ) ==
                        false)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: _addReaction,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: ColorPalette.tileBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: ColorPalette.border(context)),
                        ),
                        child: Icon(Icons.add,
                            size: 14, color: ColorPalette.textAccent(context)),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _expanded
                        ? Container(
                            key: ValueKey(
                                'count_${widget.emoji}_${widget.count}'),
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorPalette.tileBackground(context),
                              shape:
                                  BoxShape.circle, // forme circulaire parfaite
                              border: Border.all(
                                  color: ColorPalette.border(context)),
                            ),
                            child: Text(
                              widget.count.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: ColorPalette.textAccent(context),
                              ),
                            ),
                          )
                        : SizedBox(
                            key: ValueKey(
                                'stack_${widget.emoji}_${displayStackIds.length}'),
                            width: _avatarSize +
                                (displayStackIds.length - 1) * _avatarOverlap,
                            height: _avatarSize,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (var i = 0; i < displayStackIds.length; i++)
                                  Positioned(
                                    right: (displayStackIds.length - 1 - i) *
                                        _avatarOverlap,
                                    child: _avatarCircle(
                                        widget
                                            .localUserCache[displayStackIds[i]],
                                        size: _avatarSize),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildInlineAvatarsRow(context),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
        ),
      ],
    );
  }

  Widget _buildInlineAvatarsRow(BuildContext context) {
    _userIds = widget.fetchUserIdsForEmoji();
    final ids = _userIds;
    if (ids.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final uid in ids)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: _inlineAvatarEntry(uid),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inlineAvatarEntry(String uid) {
    final user = widget.localUserCache[uid];
    final displayName = user?.displayName ?? "Utilisateur";
    return GestureDetector(
      onTap: () async {
        final currentUser =
            await RepositoryProvider.userRepository.getCurrentUser();
        if (currentUser != null && uid == currentUser.uid) {
          await widget.onToggle(widget.emoji);
          _userIds = widget.fetchUserIdsForEmoji();
          if (mounted) setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vous avez supprimé la réaction ${widget.emoji}'),
            ),
          );
          return;
        }
        final profile = widget.localUserCache[uid];
        if (profile != null && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileView(
                user: profile,
                onBackPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _avatarCircle(user, size: _avatarSizeExpanded),
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle(AppUser? user, {double size = _avatarSize}) {
    if (user != null && user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(user.photoUrl!), fit: BoxFit.cover),
          border: Border.all(color: ColorPalette.border(context), width: 1),
        ),
      );
    }
    final initial = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName![0].toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.border(context),
        border: Border.all(color: ColorPalette.border(context), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
