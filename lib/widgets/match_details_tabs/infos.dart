import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/watch_together/friend_item.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/handle_data/open_bottom_sheet_and_vote_mvp.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/match_details_tabs/add_watch_friend_bottom_sheet.dart';
import 'package:scorescope/widgets/match_details_tabs/match_infos_card.dart';
import 'package:scorescope/widgets/match_details_tabs/match_not_started.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_card.dart';
import 'package:scorescope/widgets/match_details_tabs/match_rating_card.dart';
import 'package:scorescope/widgets/match_details_tabs/visionnage_match_card.dart';
import 'package:scorescope/widgets/match_details_tabs/watch_with_friends_card.dart';
import '../../../models/match.dart';

class InfosTab extends StatefulWidget {
  final MatchModel match;
  final int userDataVersion;
  final Future<void> Function()? onRefresh;

  const InfosTab(
      {super.key,
      required this.match,
      this.userDataVersion = 0,
      this.onRefresh});

  @override
  State<InfosTab> createState() => _InfosTabState();
}

class _InfosTabState extends State<InfosTab> {
  List<MvpVoteEntry> _mvpTopPlayers = [];
  Joueur? userVoteMVP;

  int? userVoteNoteMatch;

  bool _noteInitialLoadDone = false;

  bool loadingNote = false;

  final user = RepositoryProvider.userRepository.currentUser;
  List<WatchFriend> _watchFriends = [];

  @override
  void initState() {
    super.initState();
    _loadMvpEtNote();
    _loadWatchFriends();
  }

  @override
  void didUpdateWidget(covariant InfosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userDataVersion != oldWidget.userDataVersion) {
      setState(() {
        userVoteMVP = null;
        userVoteNoteMatch = null;
        _mvpTopPlayers = [];
        _noteInitialLoadDone = false;
      });
      _loadMvpEtNote();
    }
  }

  Future<void> _loadMvpEtNote() async {
    if (!mounted) return;

    final isInitialLoad = !_noteInitialLoadDone;

    if (isInitialLoad) {
      setState(() => loadingNote = true);
    }

    Joueur? loadedUserVoteMVP;
    int? loadedUserNote;
    List<MvpVoteEntry> loadedTopPlayers = [];

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final match = await RepositoryProvider.matchRepository
            .fetchMatchById(widget.match.id);

        if (match != null) {
          final userVoteId = match.mvpVotes[firebaseUser.uid];
          if (userVoteId != null) {
            loadedUserVoteMVP = await RepositoryProvider.joueurRepository
                .fetchJoueurById(userVoteId);
          }

          if (isInitialLoad) {
            loadedUserNote = match.notes[firebaseUser.uid];
          }

          final voteCountMap = <String, int>{};
          for (final joueurId in match.mvpVotes.values) {
            voteCountMap[joueurId] = (voteCountMap[joueurId] ?? 0) + 1;
          }
          final totalVotes =
              voteCountMap.values.fold<int>(0, (sum, v) => sum + v);

          final sorted = voteCountMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          for (final entry in sorted.take(3)) {
            final joueur = await RepositoryProvider.joueurRepository
                .fetchJoueurById(entry.key);
            if (joueur == null) continue;

            Equipe? equipe;
            try {
              equipe = await RepositoryProvider.equipeRepository
                  .fetchEquipeById(joueur.equipeId);
            } catch (_) {
              equipe = null;
            }

            loadedTopPlayers.add(MvpVoteEntry(
              joueur: joueur,
              equipe: equipe,
              voteCount: entry.value,
              percentage: totalVotes > 0 ? entry.value / totalVotes * 100 : 0.0,
            ));
          }
        }
      }

      if (!mounted) return;

      setState(() {
        userVoteMVP = loadedUserVoteMVP;
        if (isInitialLoad) {
          userVoteNoteMatch = loadedUserNote;
          _noteInitialLoadDone = true;
        }
        _mvpTopPlayers = loadedTopPlayers;
        loadingNote = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement MVP/note : $e');
      if (!mounted) return;
      setState(() {
        userVoteMVP = null;
        if (isInitialLoad) {
          userVoteNoteMatch = null;
          _noteInitialLoadDone = true;
        }
        _mvpTopPlayers = [];
        loadingNote = false;
      });
    }
  }

  Future<void> _loadWatchFriends() async {
    if (user == null) return;

    final friends = await RepositoryProvider.amitieRepository
        .fetchFriendsForUser(user!.uid);
    final watchedDocs = await RepositoryProvider.watchTogetherRepository
        .getFriendsWatchedWith(user!.uid, widget.match.id);
    final friendsMap = {for (var friend in friends) friend.uid: friend};

    final List<WatchFriend> result = [];
    for (final doc in watchedDocs) {
      final friendUser = friendsMap[doc.friendId];
      if (friendUser != null) {
        result.add(
          WatchFriend(
            user: friendUser,
            status: doc.status == "accepted"
                ? WatchStatus.accepted
                : WatchStatus.pending,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => _watchFriends = result);
  }

  Future<void> _reloadAll() async {
    await Future.wait([
      _loadMvpEtNote(),
      _loadWatchFriends(),
    ]);
  }

  Future<void> _onAddFriend({
    required BuildContext context,
    required String matchId,
    required Equipe equipeDomicile,
    required Equipe equipeExterieur,
  }) async {
    if (user == null) return;

    final ownerId = user!.uid;
    final friendships = await RepositoryProvider.amitieRepository
        .fetchFriendshipsForUser(userId: ownerId);
    final existingWatchTogether = await RepositoryProvider
        .watchTogetherRepository
        .getFriendsWatchedWith(ownerId, matchId);
    final invitedFriendIds =
        existingWatchTogether.map((e) => e.friendId).toSet();

    final List<FriendItem> friendItems = [];
    for (final friendship in friendships) {
      final friendId = friendship.firstUserId == ownerId
          ? friendship.secondUserId
          : friendship.firstUserId;
      final friend =
          await RepositoryProvider.userRepository.fetchUserById(friendId);
      if (friend == null) continue;

      List<Equipe> equipesPrefereesMatch = [];
      if (friend.equipesPrefereesId.contains(equipeDomicile.id)) {
        equipesPrefereesMatch.add(equipeDomicile);
      }
      if (friend.equipesPrefereesId.contains(equipeExterieur.id)) {
        equipesPrefereesMatch.add(equipeExterieur);
      }

      friendItems.add(
        FriendItem(
          user: friend,
          friendshipDate: friendship.createdAt,
          alreadyInvited: invitedFriendIds.contains(friendId),
          equipesPreferees: equipesPrefereesMatch,
        ),
      );
    }

    friendItems.sort((a, b) {
      if (a.equipesPreferees.length != b.equipesPreferees.length) {
        return a.equipesPreferees.length > b.equipesPreferees.length ? 1 : -1;
      }
      return b.friendshipDate.compareTo(a.friendshipDate);
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.surface(context),
      builder: (_) => AddWatchFriendBottomSheet(
        matchId: matchId,
        ownerId: ownerId,
        friends: friendItems,
      ),
    );

    await _reloadAll();
  }

  Future<void> _onRemoveFriend(AppUser friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Supprimer ${friend.displayName} ?",
          style: TextStyle(
            color: ColorPalette.textAccent(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Voulez-vous supprimer ${friend.displayName} des amis qui ont regardé le match avec vous ?",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler',
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Confirmer',
              style: TextStyle(
                color: ColorPalette.textAccent(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == false) return;

    final currentUser =
        await RepositoryProvider.userRepository.getCurrentUser();
    if (currentUser == null) return;

    await RepositoryProvider.watchTogetherRepository.removeWatchTogether(
      ownerId: currentUser.uid,
      friendId: friend.uid,
      matchId: widget.match.id,
    );
    await RepositoryProvider.notificationRepository
        .notifyWatchTogetherInvitationDeleted(
      ownerUserId: friend.uid,
      matchId: widget.match.id,
      authorId: currentUser.uid,
    );

    await _reloadAll();
  }

  void voteMVP() async {
    final Map<String, dynamic> result = await openBottomSheetAndVoteMVP(
      context: context,
      match: widget.match,
      initialUserVote: userVoteMVP,
    );
    userVoteMVP = result["joueur"];
    await _reloadAll();
  }

  int? get _noteCount {
    final valid =
        widget.match.notes.values.whereType<int>().where((n) => n >= 0).toList();
    return valid.isEmpty ? null : valid.length;
  }

  int? get _noteMin {
    final valid =
        widget.match.notes.values.whereType<int>().where((n) => n >= 0).toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a < b ? a : b);
  }

  int? get _noteMax {
    final valid =
        widget.match.notes.values.whereType<int>().where((n) => n >= 0).toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        color: ColorPalette.accent(context),
        backgroundColor: ColorPalette.background(context),
        onRefresh: widget.onRefresh ?? () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: widget.match.isScheduled
                ? BoxConstraints(minHeight: MediaQuery.of(context).size.height)
                : const BoxConstraints(minHeight: 0),
            child: widget.match.isScheduled
                ? Align(
                    alignment: Alignment.topCenter,
                    child: MatchNotStarted(
                      onNotificationsChanged: (value) async {
                        final currentUser =
                            RepositoryProvider.userRepository.currentUser;
                        if (currentUser != null) {
                          await RepositoryProvider.userRepository
                              .updateMatchNotifications(
                            matchId: widget.match.id,
                            userId: currentUser.uid,
                            matchDate: widget.match.date,
                            activateNotifications: value,
                          );
                        }
                      },
                      matchId: widget.match.id,
                    ),
                  )
                : Column(
                    children: [
                      loadingNote
                          ? const MatchRatingCardShimmer()
                          : MatchRatingCard(
                              noteMoyenne: widget.match.getNoteMoyenne(),
                              userVote: userVoteNoteMatch,
                              noteCount: _noteCount,
                              noteMin: _noteMin,
                              noteMax: _noteMax,
                              onCancelled: (cancelled) async {
                                if (!cancelled) return;
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                setState(() => userVoteNoteMatch = null);
                                widget.match.enleverNote(userId: uid);
                                await _reloadAll();
                              },
                              onConfirm: (valeurConfirmee) async {
                                if (valeurConfirmee == null) return;
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                setState(
                                    () => userVoteNoteMatch = valeurConfirmee);
                                widget.match.noterMatch(
                                  userId: uid,
                                  note: valeurConfirmee,
                                );
                                await _reloadAll();
                              },
                            ),
                      const SizedBox(height: 12),
                      MvpCard(
                        topPlayers: _mvpTopPlayers,
                        userVote: userVoteMVP,
                        onVotePressed: voteMVP,
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: VisionnageMatchCard(match: widget.match),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: MatchInfosCard(match: widget.match),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (user != null)
                        WatchWithFriendsCard(
                          friends: _watchFriends,
                          onRemoveFriend: _onRemoveFriend,
                          onAddFriend: () {
                            _onAddFriend(
                              context: context,
                              matchId: widget.match.id,
                              equipeDomicile: widget.match.equipeDomicile,
                              equipeExterieur: widget.match.equipeExterieur,
                            );
                          },
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
