import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/services/repositories/i_amitie_repository.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/profile/equipes_preferees.dart';
import 'package:scorescope/widgets/profile/profile_action.dart';
import 'package:scorescope/widgets/profile/matchs_favoris.dart';
import 'package:scorescope/widgets/profile/matchs_regardes.dart';
import 'package:scorescope/widgets/profile/profile_scrolled_title.dart';
import 'package:scorescope/widgets/profile/stat_tile.dart';
import 'package:shimmer/shimmer.dart';
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

  Amitie? friendship;
  bool _isPerformingFriendAction = false;

  @override
  void initState() {
    super.initState();

    _displayedUser = widget.user;

    _loadCurrentUser();

    _loadProfileData();

    double headerHeightTemp = 300;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _headerKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        setState(() {
          _headerHeight = box.size.height;
          headerHeightTemp = box.size.height;
        });
      }
      _scrollController.addListener(() {
        final isScrolledNow = _scrollController.offset > headerHeightTemp;
        if (isScrolledNow != _isScrolled) {
          setState(() => _isScrolled = isScrolledNow);
        }
      });
    });
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoadingCurrentUser = true);
    try {
      final user = await userRepository.getCurrentUser();
      if (!mounted) return;
      setState(() {
        currentUser = user;
        _isLoadingCurrentUser = false;
      });
      await _loadFriendship();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        currentUser = null;
        _isLoadingCurrentUser = false;
      });
    }
  }

  Future<void> _loadFriendship() async {
    if (widget.user.uid == currentUser?.uid) {
      setState(() {
        friendship = null;
      });
      return;
    }

    try {
      final Amitie? rel = await amitieRepository.friendshipByUsersId(
          widget.user.uid, currentUser!.uid);
      if (!mounted) return;
      setState(() {
        friendship = rel;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
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
    setState(() => _isLoadingMatchUserData = true);
    try {
      final List<MatchUserData> data =
          await userRepository.fetchUserMatchUserData(uid);

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

      setState(() {
        _displayedUser = updatedUser;
        _isLoadingMatchUserData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _displayedUser = widget.user;
        _isLoadingMatchUserData = false;
      });
    }
  }

  Future<void> _loadTeams(String uid) async {
    setState(() => _isLoadingEquipesPreferees = true);
    try {
      final teams = await userRepository.getUserEquipesPrefereesId(uid);
      if (!mounted) return;
      setState(() {
        userEquipesPrefereesId = teams;
        _isLoadingEquipesPreferees = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingEquipesPreferees = false);
    }
  }

  Future<void> _loadMatchsRegardes(String uid) async {
    setState(() => _isLoadingMatchsRegardes = true);
    try {
      final matchs = await userRepository.getUserMatchsRegardesId(uid);
      if (!mounted) return;
      setState(() {
        userMatchsRegardesId = matchs;
        _isLoadingMatchsRegardes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMatchsRegardes = false);
    }
  }

  Future<void> _loadFavoris(String uid) async {
    setState(() => _isLoadingMatchsFavoris = true);
    try {
      final favs = await userRepository.getUserMatchsFavorisId(uid);
      if (!mounted) return;
      setState(() {
        userMatchsFavorisId = favs;
        _isLoadingMatchsFavoris = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMatchsFavoris = false);
    }
  }

  Future<void> _loadUserNbMatchsRegardes(String uid) async {
    setState(() => _isLoadingNbMatchsRegardes = true);
    try {
      final nbMatchs = await userRepository.getUserNbMatchsRegardes(uid);
      if (!mounted) return;
      setState(() {
        userNbMatchsRegardes = nbMatchs;
        _isLoadingNbMatchsRegardes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingNbMatchsRegardes = false);
    }
  }

  Future<void> _loadUserNbButs(String uid) async {
    setState(() => _isLoadingNbButs = true);
    try {
      final nbButs = await userRepository.getUserNbButs(uid);
      if (!mounted) return;
      setState(() {
        userNbButs = nbButs;
        _isLoadingNbButs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingNbButs = false);
    }
  }

  Future<void> _loadUserNbAmis(String uid) async {
    setState(() => _isLoadingNbAmis = true);
    try {
      final nbAmis = await amitieRepository.getUserNbAmis(uid);
      if (!mounted) return;
      setState(() {
        userNbAmis = nbAmis;
        _isLoadingNbAmis = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingNbAmis = false);
    }
  }

  Future<void> _handleFriendAction(String action) async {
    if (currentUser == null) return;
    if (_isPerformingFriendAction) return;

    setState(() {
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
      if (!mounted) return;
      setState(() {
        _isPerformingFriendAction = false;
      });
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

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.onBackPressed != null) {
          widget.onBackPressed!(); // revient à l'onglet 0
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: _headerHeight > 0 ? _headerHeight : 300,
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
                background: Padding(
                  key: _headerKey,
                  padding: const EdgeInsets.only(
                      top: 48, left: 16, right: 16, bottom: 16),
                  child: _isLoadingCurrentUser
                      ? const _HeaderShimmer()
                      : _Header(
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
                            setState(() {
                              _loadUserNbAmis(widget.user.uid);
                            });
                          },
                        ),
                ),
              ),
              title: _isScrolled
                  ? ProfileScrolledTitle(
                      username: userToUse.displayName ?? 'Utilisateur',
                      nbAmis: userNbAmis?.toString() ?? '0',
                      nbButs: userNbButs?.toString() ?? '0',
                      nbMatchs: userNbMatchsRegardes?.toString() ?? '0',
                    )
                  : null,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: _equipesKey,
                    child: EquipesPreferees(
                      teamsId: userEquipesPrefereesId,
                      user: userToUse,
                      isLoading: _isLoadingEquipesPreferees,
                    ),
                  ),
                  const Divider(height: 32),
                  Container(
                    key: _matchsRegardesKey,
                    child: MatchsRegardes(
                      matchesId: userMatchsRegardesId,
                      isLoading:
                          _isLoadingMatchsRegardes || _isLoadingMatchUserData,
                      user: userToUse,
                    ),
                  ),
                  const Divider(height: 32),
                  Container(
                    key: _matchsFavorisKey,
                    child: MatchsFavoris(
                      matchsFavorisId: userMatchsFavorisId,
                      isLoading: _isLoadingMatchsFavoris,
                    ),
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

class _Header extends StatelessWidget {
  final AppUser user;
  final bool isMe;
  final bool isLoadingNbMatchsRegardes;
  final int? userNbMatchsRegardes;
  final bool isLoadingNbButs;
  final int? userNbButs;
  final bool isLoadingNbAmis;
  final int? userNbAmis;
  final Function(String)? onStatusChanged;
  final Amitie? friendship;
  final String? currentUserId;
  final bool isPerformingFriendAction;
  final void Function(String action)? onActionRequested;

  const _Header({
    required this.user,
    required this.isMe,
    this.isLoadingNbMatchsRegardes = false,
    this.userNbMatchsRegardes,
    this.isLoadingNbButs = false,
    this.userNbButs,
    this.isLoadingNbAmis = false,
    this.userNbAmis,
    this.onStatusChanged,
    this.friendship,
    this.currentUserId,
    this.isPerformingFriendAction = false,
    this.onActionRequested,
  });

  @override
  Widget build(BuildContext context) {
    const double statsLabelHeight = 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child:
              user.photoUrl == null && (user.displayName?.isNotEmpty ?? false)
                  ? Text(user.displayName!.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          fontSize: 36,
                          color: ColorPalette.textAccent(context)))
                  : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName ?? 'Utilisateur',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.textPrimary(context),
              ),
        ),
        const SizedBox(height: 6),
        if (user.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(user.bio!,
                style: TextStyle(
                    fontSize: 14, color: ColorPalette.textSecondary(context)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        const SizedBox(height: 10),
        ProfileAction(
          amitie: friendship,
          user: user,
          isMe: isMe,
          currentUserId: currentUserId,
          onActionRequested:
              isPerformingFriendAction ? null : onActionRequested,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ProfileStatTile(
                  label: 'Amis',
                  labelHeight: statsLabelHeight,
                  valueWidget: isLoadingNbAmis
                      ? const _ShimmerBox(width: 24, height: 12)
                      : Text(userNbAmis?.toString() ?? '0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.textPrimary(context))),
                ),
              ),
            ),
            ProfileStatTile(
              label: 'Matchs',
              labelHeight: statsLabelHeight,
              valueWidget: isLoadingNbMatchsRegardes
                  ? const _ShimmerBox(width: 24, height: 12)
                  : Text(userNbMatchsRegardes?.toString() ?? '0',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.textPrimary(context))),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ProfileStatTile(
                  label: 'Buts',
                  labelHeight: statsLabelHeight,
                  valueWidget: isLoadingNbButs
                      ? const _ShimmerBox(width: 24, height: 12)
                      : Text(userNbButs?.toString() ?? '0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.textPrimary(context))),
                ),
              ),
            ),
          ],
        ),
        Flexible(child: const SizedBox(height: 160)),
      ],
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ColorPalette.shimmerPrimary(context),
        highlightColor: ColorPalette.shimmerSecondary(context),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorPalette.surface(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: ColorPalette.surface(context),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 150,
                        color: ColorPalette.surface(context),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 62,
                            height: 40,
                            color: ColorPalette.surface(context),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorPalette.shimmerPrimary(context),
      highlightColor: ColorPalette.shimmerSecondary(context),
      child: Container(
        width: width,
        height: height,
        color: ColorPalette.surface(context),
      ),
    );
  }
}
