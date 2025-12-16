import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/slow_scroll_physics.dart';
import 'package:scorescope/views/amis/ajout_amis.dart';
import 'package:scorescope/views/amis/notifications.dart';
import 'package:scorescope/widgets/fil_actu_amis/match_regarde_amis_list.dart';

class FilActuAmisView extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const FilActuAmisView({super.key, this.onBackPressed});

  @override
  State<FilActuAmisView> createState() => _FilActuAmisViewState();
}

class _FilActuAmisViewState extends State<FilActuAmisView> {
  final ValueNotifier<int> _pendingRequests = ValueNotifier<int>(0);

  bool _isLoadingFeed = true;
  bool _isFeedError = false;

  final List<UserMatchEntry> _rawEntries = [];
  final List<MatchRegardeAmi> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    _loadFeed();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;

      if (user == null) {
        _pendingRequests.value = 0;
        return;
      }

      final nbPending = await RepositoryProvider.amitieRepository
          .getUserNbPendingFriendRequests(user.uid);

      final nbNotifs = await RepositoryProvider.notificationRepository
          .getNumberNotifications(userId: user.uid);

      if (!mounted) return;

      if (nbPending > 0 || nbNotifs > 0) {
        _pendingRequests.value = nbPending + nbNotifs;
      }
    } catch (e, st) {
      debugPrint("Erreur lors du chargement des demandes : $e\n$st");
    }
  }

  @override
  void dispose() {
    _pendingRequests.dispose();
    super.dispose();
  }

  Widget _notificationsIcon(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _pendingRequests,
      builder: (context, count, child) {
        final bool has = count > 0;
        return Semantics(
          button: true,
          label: 'Demandes d\'amis${has ? ", $count non lues" : ""}',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsView(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications,
                      size: 26, color: ColorPalette.textPrimary(context)),
                  if (has)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorPalette.accent(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6)
                          ],
                          border: Border.all(
                              color: ColorPalette.surface(context)
                                  .withValues(alpha: 0.12)),
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: TextStyle(
                            color: ColorPalette.opposite(context),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddFriendButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            icon: Icon(Icons.person_add, color: ColorPalette.accent(context)),
            label: Text('Ajouter des amis',
                style: TextStyle(color: ColorPalette.accent(context))),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.buttonSecondary(context),
              foregroundColor: ColorPalette.accent(context),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return ColorPalette.highlight(context)
                        .withValues(alpha: 0.14);
                  }
                  return null;
                },
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AjoutAmisView()));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoadingFeed = true;
      _isFeedError = false;
      _rawEntries.clear();
      _entries.clear();
    });

    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;

      if (currentUser == null) {
        setState(() {
          _isLoadingFeed = false;
        });
        return;
      }

      final List<UserMatchEntry> repoEntries = await RepositoryProvider
          .postRepository
          .fetchFriendsMatchesUserData(currentUser.uid);

      if (!mounted) return;

      _rawEntries.addAll(repoEntries);

      final uniqueIds = _rawEntries
          .map((entry) => entry.matchData.matchId)
          .whereType<String>()
          .toSet()
          .toList();

      final matchRepo = RepositoryProvider.matchRepository;
      final futures = uniqueIds.map((id) => matchRepo.fetchMatchById(id));
      final matchesList = await Future.wait(futures);
      if (!mounted) return;

      final Map<String, MatchModel?> matchById = {};
      for (var i = 0; i < uniqueIds.length; i++) {
        matchById[uniqueIds[i]] = matchesList[i];
      }

      final mvpIds = _rawEntries
          .map((entry) => entry.matchData.mvpVoteId)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, String> mvpNameById = {};
      if (mvpIds.isNotEmpty) {
        final joueurRepo = RepositoryProvider.joueurRepository;
        final mvpFutures = mvpIds.map((id) => joueurRepo.fetchJoueurById(id));
        final joueurs = await Future.wait(mvpFutures);
        for (var i = 0; i < mvpIds.length; i++) {
          final joueur = joueurs[i];
          if (joueur != null) {
            mvpNameById[mvpIds[i]] = joueur.fullName;
          }
        }
      }

      final enriched = _rawEntries.map((r) {
        final match = matchById[r.matchData.matchId];
        final mvpName = r.matchData.mvpVoteId != null
            ? mvpNameById[r.matchData.mvpVoteId!]
            : null;
        return MatchRegardeAmi(
          friend: r.user,
          matchData: r.matchData,
          match: match,
          mvpName: mvpName,
        );
      }).toList();

      setState(() {
        _entries.addAll(enriched);
        _isLoadingFeed = false;
      });
    } catch (e, st) {
      debugPrint("Erreur _loadFeed: $e\n$st");
      if (!mounted) return;
      setState(() {
        _isLoadingFeed = false;
        _isFeedError = true;
      });
    }
  }

  Future<void> _refreshFeed() async {
    await _loadFeed();
  }

  Widget _buildFeedContent(BuildContext context) {
    if (_isLoadingFeed) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isFeedError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: ColorPalette.pictureBackground(context)),
            const SizedBox(height: 12),
            Text(
              "Impossible de charger le fil.",
              style: TextStyle(color: ColorPalette.textSecondary(context)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text("Réessayer"),
            )
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined,
                size: 64, color: ColorPalette.pictureBackground(context)),
            const SizedBox(height: 12),
            Text(
              "Aucune activité récente de vos amis.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Invitez des amis pour voir leur activité ici.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: MatchRegardeAmiListView(
        entries: _entries,
        shrinkWrap: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.tileBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarOpacity: 1.0,
        title: Text(
          "Fil d'actu des amis",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: ColorPalette.textPrimary(context),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _notificationsIcon(context)),
        ],
      ),
      body: SingleChildScrollView(
        physics: const SlowScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: ColorPalette.tileBackground(context),
              child: _buildAddFriendButton(context),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ColorPalette.border(context).withValues(alpha: 0.06),
                ),
              ),
              child: _buildFeedContent(context),
            ),
          ],
        ),
      ),
    );
  }
}
