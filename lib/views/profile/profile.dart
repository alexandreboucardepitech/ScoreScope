import 'package:flutter/material.dart';
import 'package:scorescope/views/profile/equipes_preferees.dart';
import 'package:scorescope/views/profile/matchs_favoris.dart';
import 'package:scorescope/views/profile/matchs_regardes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repositories/i_app_user_repository.dart';
import 'package:scorescope/services/repository_provider.dart';

/// Refactor de ProfileView :
/// - Chargement asynchrone de l'AppUser courant via repository
/// - Placeholder / shimmer pendant le chargement
/// - Correction des bugs (initState async, comparaison par uid, menu contextuel)
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

  // flags par section
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

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUser = false;
      });
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
      final nbButs = await userRepository.getUserNbMatchsRegardes(
          uid); // remplacer par une nouvelle fonction "get Nb Buts"
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

  @override
  Widget build(BuildContext context) {
    // Comparer par uid (plus sûr que comparer l'objet entier)
    final bool isMe = widget.user.uid == currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: const Text(''),
        actions: [
          _buildContextMenu(context, isMe),
        ],
      ),
      body: Column(
        children: [
          // Header : si on charge, afficher le placeholder/shimmer
          _isLoadingUser
              ? _HeaderShimmer()
              : _Header(
                  user: widget.user,
                  isMe: isMe,
                  isLoadingNbMatchsRegardes: _isLoadingNbMatchsRegardes,
                  userNbMatchsRegardes: userNbMatchsRegardes,
                  isLoadingNbButs: _isLoadingNbButs,
                  userNbButs: userNbButs),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  EquipesPreferees(
                      teamsId: userEquipesPrefereesId,
                      isLoading: _isLoadingEquipesPreferees),
                  const SizedBox(height: 12),
                  MatchsRegardes(
                      matchesId: userMatchsRegardesId,
                      isLoading: _isLoadingMatchsRegardes),
                  const SizedBox(height: 12),
                  MatchsFavoris(
                      matchsFavorisId: userMatchsFavorisId,
                      isLoading: _isLoadingMatchsFavoris),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context, bool isMe) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        // TODO: implement actions (edit, settings, add friend, block...)
      },
      itemBuilder: (ctx) {
        if (isMe) {
          return [
            const PopupMenuItem(value: 'edit', child: Text('Éditer le profil')),
            const PopupMenuItem(value: 'settings', child: Text('Paramètres')),
          ];
        }
        return [
          const PopupMenuItem(value: 'friend', child: Text('Ajouter en ami')),
          const PopupMenuItem(value: 'block', child: Text('Bloquer')),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}

// ----------------------- Header & Shimmer ----------------------------
class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 88,
                height: 88,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 150, color: Colors.white),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(width: 62, height: 40, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 62, height: 40, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 62, height: 40, color: Colors.white),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final IAppUserRepository userRepository = RepositoryProvider.userRepository;
  final AppUser user;
  final bool isMe;
  final bool isLoadingNbMatchsRegardes;
  final int? userNbMatchsRegardes;
  final bool isLoadingNbButs;
  final int? userNbButs;

  _Header({
    required this.user,
    required this.isMe,
    this.isLoadingNbMatchsRegardes = false,
    this.userNbMatchsRegardes,
    this.isLoadingNbButs = false,
    this.userNbButs,
  });

  @override
  Widget build(BuildContext context) {
    // On définit une hauteur fixe pour tous les labels pour aligner les chiffres
    const double labelHeight = 20;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child:
                user.photoUrl == null && (user.displayName?.isNotEmpty ?? false)
                    ? Text(
                        user.displayName!.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 28),
                      )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom et bouton
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.displayName ?? 'Utilisateur',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isMe)
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Éditer'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      )
                    else
                      const _FriendActionButton(),
                  ],
                ),
                const SizedBox(height: 6),
                // Bio
                if (user.bio != null)
                  Text(
                    user.bio!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 10),
                // Stats alignées
                Row(
                  children: [
                    Flexible(
                      child: _StatTile(
                        label: 'Amis',
                        labelHeight: labelHeight,
                        valueWidget: const Text(
                          "PAS FAIT",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _StatTile(
                        label: 'Matchs regardés',
                        labelHeight: labelHeight,
                        valueWidget: isLoadingNbMatchsRegardes
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 24,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                userNbMatchsRegardes?.toString() ?? '0',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _StatTile(
                        label: 'Buts',
                        labelHeight: labelHeight,
                        valueWidget: isLoadingNbButs
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 24,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                userNbButs?.toString() ?? '0',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double labelHeight;
  final Widget? valueWidget;

  const _StatTile({
    required this.label,
    this.valueWidget,
    this.labelHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        valueWidget ?? const SizedBox.shrink(),
        const SizedBox(height: 4),
        SizedBox(
          height: labelHeight,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _FriendActionButton extends StatelessWidget {
  const _FriendActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFriend = false;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
      child: Text(isFriend == true ? 'Amis' : '+ Ami'),
    );
  }
}
