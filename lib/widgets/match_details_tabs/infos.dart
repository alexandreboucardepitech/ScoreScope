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
  Joueur? currentMvp;
  Joueur? userVoteMVP;
  int? userVoteNoteMatch;
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
        currentMvp = null;
      });
      _loadMvpEtNote();
    }
  }

  Future<void> _loadMvpEtNote() async {
    if (!mounted) return;

    Joueur? loadedCurrentMvp;
    Joueur? loadedUserVoteMVP;
    int? loadedUserNote;

    try {
      loadedCurrentMvp = await widget.match.getMvp();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final match = await RepositoryProvider.matchRepository
            .fetchMatchById(widget.match.id);

        if (match != null) {
          final userVoteId = match.mvpVotes[firebaseUser.uid];

          if (userVoteId != null) {
            loadedUserVoteMVP =
                await RepositoryProvider.joueurRepository.fetchJoueurById(
              userVoteId,
            );
          }

          loadedUserNote = match.notes[firebaseUser.uid];
        }
      }

      if (!mounted) return;

      setState(() {
        currentMvp = loadedCurrentMvp;
        userVoteMVP = loadedUserVoteMVP;
        userVoteNoteMatch = loadedUserNote;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement du MVP ou du vote utilisateur: $e');

      if (!mounted) return;

      setState(() {
        currentMvp = loadedCurrentMvp;
        userVoteMVP = null;
        userVoteNoteMatch = null;
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

    setState(() {
      _watchFriends = result;
    });
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

    final friendships =
        await RepositoryProvider.amitieRepository.fetchFriendshipsForUser(
      userId: ownerId,
    );

    final existingWatchTogether =
        await RepositoryProvider.watchTogetherRepository.getFriendsWatchedWith(
      ownerId,
      matchId,
    );

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
      builder: (_) {
        return AddWatchFriendBottomSheet(
          matchId: matchId,
          ownerId: ownerId,
          friends: friendItems,
        );
      },
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
            child: Text(
              'Annuler',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
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
    Joueur? joueurVote = await openBottomSheetAndVoteMVP(
      context: context,
      match: widget.match,
      initialUserVote: userVoteMVP,
    );
    userVoteMVP = joueurVote;
    await _reloadAll();
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
                : BoxConstraints(minHeight: 0),
            child: widget.match.isScheduled
                ? Align(
                    alignment: Alignment.topCenter,
                    child: MatchNotStarted(
                      onNotificationsChanged: (value) async {
                        AppUser? currentUser =
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
                      MatchRatingCard(
                        noteMoyenne: widget.match.getNoteMoyenne(),
                        userVote: userVoteNoteMatch,
                        onCancelled: (cancelled) async {
                          if (!cancelled) return;
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          widget.match.enleverNote(userId: uid);
                          userVoteNoteMatch = 0;
                          await _reloadAll();
                        },
                        onConfirm: (valeurConfirmee) async {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          widget.match
                              .noterMatch(userId: uid, note: valeurConfirmee);
                          userVoteNoteMatch = valeurConfirmee;
                          await _reloadAll();
                        },
                      ),
                      const SizedBox(height: 12),
                      MvpCard(
                        mvp: currentMvp,
                        userVote: userVoteMVP,
                        onVotePressed: voteMVP,
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: VisionnageMatchCard(
                                match: widget.match,
                              ),
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
