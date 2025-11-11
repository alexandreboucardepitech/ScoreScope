import 'package:flutter/material.dart';
import 'package:scorescope/widgets/profile/equipes_preferees.dart';
import 'package:scorescope/widgets/profile/matchs_favoris.dart';
import 'package:scorescope/widgets/profile/matchs_regardes.dart';
import 'package:scorescope/widgets/profile/profile_scrolled_title.dart';
import 'package:scorescope/widgets/profile/stat_tile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

class ProfileView extends StatefulWidget {
  final AppUser user;
  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final IAppUserRepository userRepository = RepositoryProvider.userRepository;
  AppUser? currentUser;
  bool _isLoadingUser = true;

  bool _isLoadingEquipesPreferees = true;
  bool _isLoadingMatchsRegardes = true;
  bool _isLoadingMatchsFavoris = true;
  bool _isLoadingNbMatchsRegardes = true;
  bool _isLoadingNbButs = true;

  List<String>? userEquipesPrefereesId;
  List<String>? userMatchsRegardesId;
  List<String>? userMatchsFavorisId;
  int? userNbMatchsRegardes;
  int? userNbButs;

  // ScrollController pour scroll vers sections
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _equipesKey = GlobalKey();
  final GlobalKey _matchsRegardesKey = GlobalKey();
  final GlobalKey _matchsFavorisKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _headerKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        setState(() {
          _headerHeight = box.size.height;
        });
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await userRepository.getCurrentUser();
      if (!mounted) return;
      setState(() {
        currentUser = user;
        _isLoadingUser = false;
      });

      if (user != null) {
        _loadTeams(user.uid);
        _loadMatchsRegardes(user.uid);
        _loadFavoris(user.uid);
        _loadUserNbMatchsRegardes(user.uid);
        _loadUserNbButs(user.uid);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _loadTeams(String uid) async {
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
  Widget build(BuildContext context) {
    final bool isMe = widget.user.uid == currentUser?.uid;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: _headerHeight > 0 ? _headerHeight : 300,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            leadingWidth: 40,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(
                    top: 48, left: 16, right: 16, bottom: 16),
                child: _isLoadingUser
                    ? const _HeaderShimmer()
                    : _Header(
                        user: widget.user,
                        isMe: isMe,
                        isLoadingNbMatchsRegardes: _isLoadingNbMatchsRegardes,
                        userNbMatchsRegardes: userNbMatchsRegardes,
                        isLoadingNbButs: _isLoadingNbButs,
                        userNbButs: userNbButs,
                      ),
              ),
            ),
            title: innerBoxIsScrolled
                ? ProfileScrolledTitle(
                    username: widget.user.displayName ?? 'Utilisateur',
                    nbAmis: 'PAS FAIT',
                    nbButs: userNbButs?.toString() ?? '0',
                    nbMatchs: userNbMatchsRegardes?.toString() ?? '0',
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => _scrollToSection(_equipesKey),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Équipes préférées'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: () => _scrollToSection(_matchsRegardesKey),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Derniers matchs'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: () => _scrollToSection(_matchsFavorisKey),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Matchs favoris'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                key: _equipesKey,
                child: EquipesPreferees(
                  teamsId: userEquipesPrefereesId,
                  user: widget.user,
                  isLoading: _isLoadingEquipesPreferees,
                ),
              ),
              const Divider(height: 32),
              Container(
                key: _matchsRegardesKey,
                child: MatchsRegardes(
                  matchesId: userMatchsRegardesId,
                  isLoading: _isLoadingMatchsRegardes,
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
              const SizedBox(height: 24),
            ],
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

  const _Header({
    required this.user,
    required this.isMe,
    this.isLoadingNbMatchsRegardes = false,
    this.userNbMatchsRegardes,
    this.isLoadingNbButs = false,
    this.userNbButs,
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
                  ? Text(
                      user.displayName!.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                user.displayName ?? 'Utilisateur',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4),
            if (!isMe)
              _FriendBadge(isFriend: false), // TODO: remplacer par vrai état
          ],
        ),
        const SizedBox(height: 6),
        if (user.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              user.bio!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: ProfileStatTile(
                label: 'Amis',
                labelHeight: statsLabelHeight,
                valueWidget: const Text(
                  'PAS FAIT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Flexible(
              child: ProfileStatTile(
                label: 'Matchs',
                labelHeight: statsLabelHeight,
                valueWidget: isLoadingNbMatchsRegardes
                    ? const _ShimmerBox(width: 24, height: 12)
                    : Text(
                        userNbMatchsRegardes?.toString() ?? '0',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            Flexible(
              child: ProfileStatTile(
                label: 'Buts',
                labelHeight: statsLabelHeight,
                valueWidget: isLoadingNbButs
                    ? const _ShimmerBox(width: 24, height: 12)
                    : Text(
                        userNbButs?.toString() ?? '0',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 20,
                          width: double.infinity,
                          color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 150, color: Colors.white),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(width: 62, height: 40, color: Colors.white),
                          const SizedBox(width: 8),
                          Container(width: 62, height: 40, color: Colors.white),
                          const SizedBox(width: 8),
                          Container(width: 62, height: 40, color: Colors.white),
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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}

class _FriendBadge extends StatelessWidget {
  final bool isFriend;
  const _FriendBadge({required this.isFriend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isFriend ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFriend ? Icons.person : Icons.add,
            size: 14,
            color: Colors.white,
          ),
          if (isFriend)
            const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
