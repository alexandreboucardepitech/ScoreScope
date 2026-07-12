import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';
import 'package:scorescope/utils/handle_data/profile_stats.dart';
import 'package:scorescope/utils/string/get_friendship_action_snackbar_message.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/users/can_access_private_infos.dart';
import 'package:scorescope/views/details/team_details_page.dart';
import 'package:scorescope/views/profile/options_view.dart';
import 'package:scorescope/views/statistiques/stats_view.dart';
import 'package:scorescope/widgets/profile/equipes_preferees.dart';
import 'package:scorescope/widgets/profile/header.dart';
import 'package:scorescope/widgets/profile/matchs_favoris.dart';
import 'package:scorescope/widgets/profile/matchs_regardes.dart';
import 'package:scorescope/widgets/profile/profile_scrolled_title.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/views/profile/all_matches_history_view.dart';

class ProfileView extends StatefulWidget {
  final AppUser user;
  final VoidCallback? onBackPressed;

  const ProfileView({super.key, required this.user, this.onBackPressed});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final IAppUserRepository userRepository = RepositoryProvider.userRepository;
  final IAmitieRepository amitieRepository =
      RepositoryProvider.amitieRepository;

  AppUser? currentUser;
  bool _isLoadingCurrentUser = true;

  AppUser? _displayedUser;

  /// Un seul flag pour tous les compteurs et listes de matchs.
  /// Remplace _isLoadingMatchUserData, _isLoadingMatchsRegardes,
  /// _isLoadingMatchsFavoris, _isLoadingNbMatchsRegardes, _isLoadingNbButs,
  /// _isLoadingEquipesPreferees.
  bool _isLoadingStats = true;

  bool _isLoadingNbAmis = true;
  bool _isLoadingFriendship = true;

  bool _isScrolled = false;

  List<String>? userEquipesPrefereesId;
  List<String>? userMatchsRegardesId;
  List<String>? userMatchsFavorisId;
  int? userNbMatchsRegardes;
  int? userNbButs;
  int? userNbAmis;

  /// Documents match bruts (indexés par matchId) issus de loadProfileStats.
  /// Passés à EquipesPreferees pour calculer le nb de matchs par équipe
  /// en mémoire, sans requête Firestore supplémentaire.
  Map<String, Map<String, dynamic>> _matchesData = {};

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _equipesKey = GlobalKey();
  final GlobalKey _matchsRegardesKey = GlobalKey();
  final GlobalKey _matchsFavorisKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 0;

  final double headerTopPadding = 56;

  Amitie? friendship;
  bool _isPerformingFriendAction = false;

  @override
  void initState() {
    super.initState();

    _displayedUser = widget.user;
    _init();

    _scrollController.addListener(() {
      final isScrolledNow = _scrollController.offset > _headerHeight;
      if (isScrolledNow != _isScrolled) {
        setState(() => _isScrolled = isScrolledNow);
      }
    });

    // première mesure après le premier frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scheduleUpdateHeaderHeight());
  }

  @override
  void didUpdateWidget(covariant ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scheduleUpdateHeaderHeight());
  }

  // helper pour demander re-mesure après un setState
  void _setStateAndRemeasure(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scheduleUpdateHeaderHeight());
  }

  void _scheduleUpdateHeaderHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _headerKey.currentContext;
      if (ctx == null) return;
      final render = ctx.findRenderObject();
      if (render is! RenderBox) return;
      if (!render.hasSize) return;

      // measured = hauteur du contenu (padding inclus)
      final double measured = render.size.height;
      final double topPadding = MediaQuery.of(context).padding.top;

      final double desired =
          measured + kToolbarHeight + topPadding - headerTopPadding;

      if ((desired - _headerHeight).abs() > 1.0) {
        setState(() {
          _headerHeight = desired;
        });
      }
    });
  }

  Future<void> _init() async {
    await _loadCurrentUser();
    _loadProfileData();
  }

  Future<void> _loadCurrentUser() async {
    _setStateAndRemeasure(() => _isLoadingCurrentUser = true);
    try {
      final user = await userRepository.getCurrentUser();
      _setStateAndRemeasure(() {
        currentUser = user;
        _isLoadingCurrentUser = false;
      });
      await _loadFriendship();
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() {
        currentUser = null;
        _isLoadingCurrentUser = false;
      });
    }
  }

  Future<void> _loadFriendship() async {
    _setStateAndRemeasure(() => _isLoadingFriendship = true);
    if (_displayedUser?.uid == currentUser?.uid) {
      _setStateAndRemeasure(() => friendship = null);
      return;
    }

    try {
      final Amitie? rel = await amitieRepository.friendshipByUsersId(
          _displayedUser!.uid, currentUser!.uid);
      if (!mounted) return;
      _setStateAndRemeasure(() {
        friendship = rel;
        _isLoadingFriendship = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() {
        friendship = null;
        _isLoadingFriendship = false;
      });
    }
  }

  void _loadProfileData() {
    final uid = _displayedUser?.uid ?? widget.user.uid;
    final bool onlyPublic = uid != currentUser?.uid;

    // Les equipesPrefereesId sont déjà dans _displayedUser (issu de widget.user
    // ou rechargé après édition de profil) : pas de lecture Firestore séparée.
    _setStateAndRemeasure(() {
      userEquipesPrefereesId =
          _displayedUser?.equipesPrefereesId ?? widget.user.equipesPrefereesId;
    });

    _loadStats(uid, onlyPublic);
    _loadUserNbAmis(uid);
  }

  /// Charge toutes les données dépendant de matchUserData en un seul appel :
  /// nbMatchsRegardes, nbButs, matchsRegardesId, matchsFavorisId,
  /// allMatchUserData et matchesData (pour les équipes préférées).
  Future<void> _loadStats(String uid, bool onlyPublic) async {
    _setStateAndRemeasure(() => _isLoadingStats = true);
    try {
      final ProfileStats stats = await userRepository.loadProfileStats(
        userId: uid,
        onlyPublic: onlyPublic,
      );
      if (!mounted) return;

      final base = _displayedUser ?? widget.user;
      final updatedUser = AppUser(
        uid: base.uid,
        email: base.email,
        displayName: base.displayName,
        bio: base.bio,
        photoUrl: base.photoUrl,
        createdAt: base.createdAt,
        equipesPrefereesId: base.equipesPrefereesId,
        competitionsPrefereesId: base.competitionsPrefereesId,
        private: base.private,
        matchsUserData: stats.allMatchUserData,
      );

      _setStateAndRemeasure(() {
        _displayedUser = updatedUser;
        userMatchsRegardesId = stats.matchsRegardesId;
        userMatchsFavorisId = stats.matchsFavorisId;
        userNbMatchsRegardes = stats.nbMatchsRegardes;
        userNbButs = stats.nbButs;
        _matchesData = stats.matchesData;
        _isLoadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadUserNbAmis(String uid) async {
    _setStateAndRemeasure(() => _isLoadingNbAmis = true);
    try {
      final nbAmis = await amitieRepository.getUserNbAmis(uid);
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userNbAmis = nbAmis;
        _isLoadingNbAmis = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingNbAmis = false);
    }
  }

  Future<void> _handleFriendAction(String action) async {
    if (currentUser == null) return;

    if (action == 'profileEdited') {
      final user = await RepositoryProvider.userRepository
          .fetchUserById(_displayedUser?.uid ?? widget.user.uid);
      setState(() {
        _displayedUser = user;
        _loadProfileData();
      });
      return;
    }

    if (_isPerformingFriendAction) return;

    _setStateAndRemeasure(() {
      _isPerformingFriendAction = true;
    });

    try {
      switch (action) {
        case 'send':
          await amitieRepository.sendFriendRequest(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
          break;
        case 'cancel':
          await amitieRepository.removeFriend(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
          break;
        case 'accept':
          await amitieRepository.acceptFriendRequest(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
          break;
        case 'remove':
          await amitieRepository.removeFriend(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
        case 'block':
          await amitieRepository.blockUser(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
          break;
        case 'unblock':
          await amitieRepository.unblockUser(
            currentUser!.uid,
            _displayedUser?.uid ?? widget.user.uid,
          );
          break;
      }

      await _loadFriendship();
      await _loadUserNbAmis(
        _displayedUser?.uid ?? widget.user.uid,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getFriendshipActionSnackbarMessage(action)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate.erreurLorsDeLActionSurLUtilisateur),
        ),
      );
    } finally {
      if (mounted) {
        _setStateAndRemeasure(() {
          _isPerformingFriendAction = false;
        });
      }
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTeamTap(String teamId, String teamName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailsPage(teamId: teamId),
      ),
    );
  }

  void _confirmBlockUser() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          translate.bloquerX(widget.user.displayName),
          style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        content: Text(
          translate.voulezVousBloquerX(widget.user.displayName),
          style:
              TextStyle(color: ColorPalette.textPrimary(context), fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              translate.annuler,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              if (currentUser != null && _displayedUser != null) {
                await RepositoryProvider.amitieRepository
                    .blockUser(currentUser!.uid, _displayedUser!.uid);
              }
              Navigator.of(context).pop();
            },
            child: Text(
              translate.bloquer,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
    setState(() {
      _init();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.user.uid == currentUser?.uid;
    final userToUse = _displayedUser ?? widget.user;

    final bool matchsRegardesLoading = _isLoadingStats;
    final bool matchsFavorisLoading = _isLoadingStats;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (widget.onBackPressed != null) {
            widget.onBackPressed!();
          } else {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          physics: canAccessPrivateInfos(
            friendship: friendship,
            userToAccessInfos: userToUse,
            isMe: isMe,
          )
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: _headerHeight > 0 ? _headerHeight - 50 : 380,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Navigator.of(context).canPop()
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    : null,
              ),
              leadingWidth: 40,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    // key utilisé pour mesurer la taille réelle du header
                    key: _headerKey,
                    padding: EdgeInsets.only(
                      top: headerTopPadding,
                      left: 16,
                      right: 16,
                    ),
                    child: _isLoadingCurrentUser
                        ? const HeaderShimmer()
                        : Header(
                            user: userToUse,
                            isMe: isMe,
                            isLoadingNbMatchsRegardes: _isLoadingStats,
                            userNbMatchsRegardes: userNbMatchsRegardes,
                            isLoadingNbButs: _isLoadingStats,
                            userNbButs: userNbButs,
                            isLoadingNbAmis: _isLoadingNbAmis,
                            userNbAmis: userNbAmis,
                            friendship: friendship,
                            currentUser: currentUser,
                            isPerformingFriendAction: _isPerformingFriendAction,
                            onActionRequested: (action) =>
                                _handleFriendAction(action),
                            onStatusChanged: (newStatus) {
                              _loadUserNbAmis(
                                  _displayedUser?.uid ?? widget.user.uid);
                            },
                            onContentReady: () {
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _scheduleUpdateHeaderHeight());
                            },
                          ),
                  ),
                ),
              ),
              centerTitle: true,
              backgroundColor: ColorPalette.background(context),
              title: _isScrolled
                  ? ProfileScrolledTitle(
                      username: userToUse.displayName,
                      nbAmis: userNbAmis?.toString() ?? '0',
                      nbButs: userNbButs?.toString() ?? '0',
                      nbMatchs: userNbMatchsRegardes?.toString() ?? '0',
                    )
                  : null,
              actions: [
                if (_isLoadingCurrentUser)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        ColorPalette.textPrimary(context),
                      ),
                    ),
                  )
                else ...[
                  if (isMe && !_isScrolled)
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: ColorPalette.textPrimary(context),
                      ),
                      onPressed: () {
                        if (currentUser != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OptionsView(
                                currentUser: currentUser!,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  if (!isMe &&
                      !_isScrolled &&
                      canAccessPrivateInfos(
                        friendship: friendship,
                        userToAccessInfos: userToUse,
                        isMe: isMe,
                      ))
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StatsView(user: userToUse),
                          ),
                        );
                      },
                    ),
                  if (!isMe && !_isScrolled)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: ColorPalette.textPrimary(context),
                      ),
                      onSelected: (value) {},
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: _confirmBlockUser,
                          value: 'bloquer',
                          child: Text(
                            translate.bloquer,
                            style: TextStyle(
                              color: ColorPalette.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
            if (canAccessPrivateInfos(
              friendship: friendship,
              userToAccessInfos: userToUse,
              isMe: isMe,
            ))
              SliverToBoxAdapter(
                child: Container(
                  color: ColorPalette.background(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextButton(
                          onPressed: () => _scrollToSection(_equipesKey),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              translate.equipesPreferees,
                              style: TextStyle(
                                color: ColorPalette.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextButton(
                          onPressed: () => _scrollToSection(_matchsRegardesKey),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              translate.derniersMatchs,
                              style: TextStyle(
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextButton(
                          onPressed: () => _scrollToSection(_matchsFavorisKey),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              translate.matchsFavoris,
                              style: TextStyle(
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          body: Container(
            color: ColorPalette.background(context),
            child: (canAccessPrivateInfos(
                      friendship: friendship,
                      userToAccessInfos: userToUse,
                      isMe: isMe,
                    ) ||
                    _isLoadingFriendship)
                ? RefreshIndicator(
                    color: ColorPalette.accent(context),
                    backgroundColor: ColorPalette.background(context),
                    onRefresh: _init,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      children: [
                        EquipesPreferees(
                          key: _equipesKey,
                          teamsId: userEquipesPrefereesId,
                          user: userToUse,
                          isMe: isMe,
                          matchesData: _matchesData,
                          onTeamTap: _onTeamTap,
                        ),
                        const Divider(height: 32),
                        MatchsRegardes(
                          key: _matchsRegardesKey,
                          matchesId: userMatchsRegardesId,
                          isLoading: matchsRegardesLoading,
                          user: userToUse,
                          onVoirPlus: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AllMatchesHistoryView(
                                  user: userToUse,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 32),
                        MatchsFavoris(
                          key: _matchsFavorisKey,
                          matchsFavorisId: userMatchsFavorisId,
                          isLoading: matchsFavorisLoading,
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Container(
                            width: 300,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorPalette.border(context),
                                width: 5,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: ColorPalette.accent(context),
                                  size: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  translate.ceCompteEstPrive,
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  translate.ajoutezCetAmiPourSuivreSonActualite,
                                  style: TextStyle(
                                    color: ColorPalette.textSecondary(context),
                                    fontSize: 12,
                                  ),
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
      ),
    );
  }
}
