import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/slow_scroll_physics.dart';
import 'package:scorescope/views/amis/ajout_amis.dart';
import 'package:scorescope/views/amis/notifications.dart';
import 'package:scorescope/widgets/fil_actu_amis/match_regarde_amis_list.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class FilActuAmisView extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationsSeen;

  const FilActuAmisView({
    super.key,
    this.onBackPressed,
    this.onNotificationsSeen,
  });

  @override
  State<FilActuAmisView> createState() => _FilActuAmisViewState();
}

class _FilActuAmisViewState extends State<FilActuAmisView> {
  final ValueNotifier<int> _pendingRequests = ValueNotifier<int>(0);

  bool _isLoadingFeed = true;
  bool _isFeedError = false;

  final List<MatchRegardeAmi> _allEntries = [];

  static const int _pageSize = 20;
  int _displayedCount = _pageSize;
  bool get _hasMore => _displayedCount < _allEntries.length;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPendingRequests();
    _loadFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pendingRequests.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      _maybeLoadMore();
    }
  }

  void _maybeLoadMore() {
    if (_hasMore) {
      setState(() {
        _displayedCount =
            (_displayedCount + _pageSize).clamp(0, _allEntries.length);
      });
    }
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
      _pendingRequests.value = nbPending + nbNotifs;
    } catch (e, st) {
      debugPrint("Erreur lors du chargement des demandes : $e\n$st");
    }
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoadingFeed = true;
      _isFeedError = false;
      _allEntries.clear();
      _displayedCount = _pageSize;
    });

    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;

      if (currentUser == null) {
        setState(() => _isLoadingFeed = false);
        return;
      }

      final rawEntries = await RepositoryProvider.postRepository
          .fetchFriendsMatchesUserData(
        userId: currentUser.uid,
        onlyPublic: true,
        daysLimit: 14,
      );
      if (!mounted) return;

      final entries = rawEntries
          .map(
            (r) => MatchRegardeAmi(
              friend: r.user,
              matchData: r.matchData,
              match: null,
              mvpName: null,
            ),
          )
          .toList();

      setState(() {
        _allEntries.addAll(entries);
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

  Future<void> _refreshFeed() async => _loadFeed();

  Widget _notificationsIcon(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _pendingRequests,
      builder: (context, count, child) {
        final bool has = count > 0;
        return Semantics(
          button: true,
          label: translate.demandesDAmis,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              HapticFeedback.selectionClick();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              );
              _loadPendingRequests();
              widget.onNotificationsSeen?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications,
                    size: 26,
                    color: ColorPalette.textPrimary(context),
                  ),
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
                              blurRadius: 6,
                            )
                          ],
                          border: Border.all(
                            color: ColorPalette.surface(context)
                                .withValues(alpha: 0.12),
                          ),
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
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          icon: Icon(Icons.person_add, color: ColorPalette.accent(context)),
          label: Text(
            translate.ajouterDesAmis,
            style: TextStyle(color: ColorPalette.accent(context)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.buttonSecondary(context),
            foregroundColor: ColorPalette.accent(context),
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
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
              context,
              MaterialPageRoute(builder: (_) => AjoutAmisView()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedContent(BuildContext context) {
    if (_isLoadingFeed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isFeedError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48,
                  color: ColorPalette.pictureBackground(context)),
              const SizedBox(height: 12),
              Text(
                translate.impossibleDeChargerLeFil,
                style:
                    TextStyle(color: ColorPalette.textSecondary(context)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadFeed,
                child: Text(
                  translate.reessayer,
                  style: TextStyle(
                      color: ColorPalette.textPrimary(context)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_allEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_outlined,
                  size: 64, color: ColorPalette.accent(context)),
              const SizedBox(height: 12),
              Text(
                translate.aucuneActiviteRecenteDeVosAmis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorPalette.textSecondary(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                translate.invitezDesAmisPourVoirLeurActiviteIci,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: ColorPalette.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayed = _allEntries.take(_displayedCount).toList();

    return Column(
      children: [
        MatchRegardeAmiListView(
          entries: displayed,
          shrinkWrap: true,
        ),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: ColorPalette.accent(context),
                ),
              ),
            ),
          ),
        if (!_hasMore && _allEntries.length > _pageSize)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text(
              translate.xPostsCharges(_allEntries.length.toString()),
              style: TextStyle(
                fontSize: 12,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),
      ],
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
        title: Row(
          children: [
            AppLogos.logoTransparent(context, size: 32),
            const SizedBox(width: 8),
            Text(
              translate.filDActuDesAmis,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _notificationsIcon(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: ColorPalette.accent(context),
        backgroundColor: ColorPalette.background(context),
        onRefresh: _refreshFeed,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const SlowScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: ColorPalette.tileBackground(context),
                child: _buildAddFriendButton(context),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFeedContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
