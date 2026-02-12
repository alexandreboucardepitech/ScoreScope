import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/views/statistiques/stats_view.dart';
import 'package:scorescope/widgets/profile/equipes_preferees.dart';
import 'package:scorescope/widgets/profile/header.dart';
import 'package:scorescope/widgets/profile/matchs_favoris.dart';
import 'package:scorescope/widgets/profile/matchs_regardes.dart';
import 'package:scorescope/widgets/profile/profile_scrolled_title.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

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
  bool _isLoadingMatchUserData = true;

  bool _isLoadingEquipesPreferees = true;
  bool _isLoadingMatchsRegardes = true;
  bool _isLoadingMatchsFavoris = true;
  bool _isLoadingNbMatchsRegardes = true;
  bool _isLoadingNbButs = true;
  bool _isLoadingNbAmis = true;

  bool _isScrolled = false;

  List<String>? userEquipesPrefereesId;
  List<String>? userMatchsRegardesId;
  List<String>? userMatchsFavorisId;
  int? userNbMatchsRegardes;
  int? userNbButs;
  int? userNbAmis;

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
      if (!mounted) return;
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
    if (widget.user.uid == currentUser?.uid) {
      _setStateAndRemeasure(() => friendship = null);
      return;
    }

    try {
      final Amitie? rel = await amitieRepository.friendshipByUsersId(
          widget.user.uid, currentUser!.uid);
      if (!mounted) return;
      _setStateAndRemeasure(() {
        friendship = rel;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() {
        friendship = null;
      });
    }
  }

  void _loadProfileData() {
    final uid = widget.user.uid;
    _loadTeams(uid);
    _loadMatchsRegardes(uid);
    _loadFavoris(uid);
    _loadUserNbMatchsRegardes(uid);
    _loadUserNbButs(uid);
    _loadUserNbAmis(uid);

    _loadMatchUserData(uid);
  }

  Future<void> _loadMatchUserData(String uid) async {
    _setStateAndRemeasure(() => _isLoadingMatchUserData = true);
    try {
      final List<MatchUserData> data =
          await userRepository.fetchUserAllMatchUserData(
              userId: uid, onlyPublic: uid != currentUser?.uid);

      if (!mounted) return;

      final base = widget.user;
      final updatedUser = AppUser(
        uid: base.uid,
        email: base.email,
        displayName: base.displayName,
        bio: base.bio,
        photoUrl: base.photoUrl,
        createdAt: base.createdAt,
        equipesPrefereesId: base.equipesPrefereesId,
        matchsUserData: data,
      );

      _setStateAndRemeasure(() {
        _displayedUser = updatedUser;
        _isLoadingMatchUserData = false;
      });
    } catch (e) {
      if (!mounted) return;
      _setStateAndRemeasure(() {
        _displayedUser = widget.user;
        _isLoadingMatchUserData = false;
      });
    }
  }

  Future<void> _loadTeams(String uid) async {
    _setStateAndRemeasure(() => _isLoadingEquipesPreferees = true);
    try {
      final teams = await userRepository.getUserEquipesPrefereesId(uid);
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userEquipesPrefereesId = teams;
        _isLoadingEquipesPreferees = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingEquipesPreferees = false);
    }
  }

  Future<void> _loadMatchsRegardes(String uid) async {
    _setStateAndRemeasure(() => _isLoadingMatchsRegardes = true);
    try {
      final matchs = await userRepository.getUserMatchsRegardesId(
        userId: uid,
        onlyPublic: uid != currentUser?.uid,
      );
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userMatchsRegardesId = matchs;
        _isLoadingMatchsRegardes = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingMatchsRegardes = false);
    }
  }

  Future<void> _loadFavoris(String uid) async {
    _setStateAndRemeasure(() => _isLoadingMatchsFavoris = true);
    try {
      final favs = await userRepository.getUserMatchsFavorisId(
        uid,
        uid != currentUser?.uid,
      );
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userMatchsFavorisId = favs;
        _isLoadingMatchsFavoris = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingMatchsFavoris = false);
    }
  }

  Future<void> _loadUserNbMatchsRegardes(String uid) async {
    _setStateAndRemeasure(() => _isLoadingNbMatchsRegardes = true);
    try {
      final nbMatchs = await userRepository.getUserNbMatchsRegardes(
        uid,
        uid != currentUser?.uid,
      );
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userNbMatchsRegardes = nbMatchs;
        _isLoadingNbMatchsRegardes = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingNbMatchsRegardes = false);
    }
  }

  Future<void> _loadUserNbButs(String uid) async {
    _setStateAndRemeasure(() => _isLoadingNbButs = true);
    try {
      final nbButs = await userRepository.getUserNbButs(
        uid,
        uid != currentUser?.uid,
      );
      if (!mounted) return;
      _setStateAndRemeasure(() {
        userNbButs = nbButs;
        _isLoadingNbButs = false;
      });
    } catch (_) {
      if (!mounted) return;
      _setStateAndRemeasure(() => _isLoadingNbButs = false);
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
    if (_isPerformingFriendAction) return;

    _setStateAndRemeasure(() {
      _isPerformingFriendAction = true;
    });

    try {
      switch (action) {
        case 'send':
          await amitieRepository.sendFriendRequest(
              currentUser!.uid, widget.user.uid);
          break;
        case 'cancel':
          await amitieRepository.removeFriend(
              currentUser!.uid, widget.user.uid);
          break;
        case 'accept':
          await amitieRepository.acceptFriendRequest(
              currentUser!.uid, widget.user.uid);
          break;
        case 'remove':
          await amitieRepository.removeFriend(
              currentUser!.uid, widget.user.uid);
          break;
      }

      await _loadFriendship();
      await _loadUserNbAmis(widget.user.uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getSnackbarMessage(action))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de l'action sur l'utilisateur.")),
      );
    } finally {
      if (mounted) {
        _setStateAndRemeasure(() {
          _isPerformingFriendAction = false;
        });
      }
    }
  }

  String _getSnackbarMessage(String action) {
    switch (action) {
      case 'send':
        return "Demande d'ami envoyée avec succès!";
      case 'cancel':
        return "Demande d'ami annulée avec succès!";
      case 'accept':
        return "Demande acceptée !";
      case 'remove':
        return "Ami retiré avec succès!";
      default:
        return "Action effectuée avec succès!";
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.user.uid == currentUser?.uid;
    final userToUse = _displayedUser ?? widget.user;

    final bool equipesLoading = _isLoadingEquipesPreferees;

    final bool matchsRegardesLoading =
        _isLoadingMatchsRegardes || _isLoadingMatchUserData;

    final bool matchsFavorisLoading = _isLoadingMatchsFavoris;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.onBackPressed != null) {
          widget.onBackPressed!();
        }
      },
      child: Scaffold(
        body: NestedScrollView(
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
                            isLoadingNbMatchsRegardes:
                                _isLoadingNbMatchsRegardes ||
                                    _isLoadingMatchUserData,
                            userNbMatchsRegardes: userNbMatchsRegardes,
                            isLoadingNbButs:
                                _isLoadingNbButs || _isLoadingMatchUserData,
                            userNbButs: userNbButs,
                            isLoadingNbAmis:
                                _isLoadingNbAmis || _isLoadingMatchUserData,
                            userNbAmis: userNbAmis,
                            friendship: friendship,
                            currentUserId: currentUser?.uid,
                            isPerformingFriendAction: _isPerformingFriendAction,
                            onActionRequested: (action) =>
                                _handleFriendAction(action),
                            onStatusChanged: (newStatus) {
                              _loadUserNbAmis(widget.user.uid);
                            },
                            onContentReady: () {
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _scheduleUpdateHeaderHeight());
                            },
                          ),
                  ),
                ),
              ),
              title: _isScrolled
                  ? ProfileScrolledTitle(
                      username: userToUse.displayName,
                      nbAmis: userNbAmis?.toString() ?? '0',
                      nbButs: userNbButs?.toString() ?? '0',
                      nbMatchs: userNbMatchsRegardes?.toString() ?? '0',
                    )
                  : null,
              actions: [
                if (isMe && !_isScrolled)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                if (!isMe && !_isScrolled)
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StatsView(user: widget.user),
                        ),
                      );
                    },
                  ),
              ],
            ),
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
                            'Équipes préférées',
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
                            'Derniers matchs',
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
                            'Matchs favoris',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EquipesPreferees(
                    teamsId: userEquipesPrefereesId,
                    user: userToUse,
                    isMe: isMe,
                    isLoading: equipesLoading,
                  ),
                  const Divider(height: 32),
                  MatchsRegardes(
                    matchesId: userMatchsRegardesId,
                    isLoading: matchsRegardesLoading,
                    user: userToUse,
                  ),
                  const Divider(height: 32),
                  MatchsFavoris(
                    matchsFavorisId: userMatchsFavorisId,
                    isLoading: matchsFavorisLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
