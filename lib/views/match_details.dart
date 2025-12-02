import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_details_tabs/infos.dart';
import 'package:scorescope/widgets/match_details_tabs/mes_amis.dart';
import '../models/match.dart';
import '../utils/string/get_lignes_buteurs.dart';

class MatchDetailsPage extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavori = false;
  bool _isUpdatingFavori = false;

  bool _isPrivate = true;
  bool _isProcessingPrivacy = false;

  late MatchModel _currentMatch;

  bool _isFetchingMatch = false;

  int _userDataVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMatch = widget.match;
    _loadFavoriStatus();
    _loadPrivateStatus();
  }

  Future<void> _fetchMatch() async {
    setState(() => _isFetchingMatch = true);
    try {
      if (_isFetchingMatch) return;
      final freshMatch = await RepositoryProvider.matchRepository
          .fetchMatchById(_currentMatch.id);
      if (!mounted) return;
      if (freshMatch == null) return;
      setState(() => _currentMatch = freshMatch);
    } catch (e) {
      debugPrint('Erreur lors du fetch du match: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isFetchingMatch = false);
    }
  }

  Future<void> _loadFavoriStatus() async {
    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        final favori = await RepositoryProvider.userRepository
            .isMatchFavori(currentUser.uid, _currentMatch.id);
        if (!mounted) return;
        setState(() => _isFavori = favori);
      }
    } catch (_) {}
  }

  Future<void> _loadPrivateStatus() async {
    setState(() => _isProcessingPrivacy = true);
    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        final privacy = await RepositoryProvider.userRepository
            .getMatchPrivacy(currentUser.uid, _currentMatch.id);
        if (!mounted) return;
        setState(() => _isPrivate = privacy);
      }
    } catch (_) {
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPrivacy = false);
    }
  }

  Future<void> _toggleFavori() async {
    if (_isUpdatingFavori) return;
    setState(() => _isUpdatingFavori = true);

    final newFavori = !_isFavori;

    try {
      AppUser? currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        await RepositoryProvider.userRepository
            .matchFavori(_currentMatch.id, currentUser.uid, newFavori);
      }
      if (!mounted) return;
      setState(() {
        _isFavori = newFavori;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavori ? 'Match ajouté aux favoris' : 'Match retiré des favoris',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du favori'),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUpdatingFavori = false);
    }
  }

  void _onPrivacyMenuSelected(String action) {
    switch (action) {
      case 'publish':
        _showPublishDialog();
        break;
      case 'makePrivate':
        _showMakePrivateDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
      default:
        break;
    }
  }

  Future<void> _showPublishDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        title: Text(
          'Rendre le match public',
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content:
            const Text('Le match sera rendu public et visible par vos amis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _setPrivacy(false); // false => rendu public
            },
            child: Text(
              'Rendre public',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMakePrivateDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        title: Text(
          'Rendre le match privé',
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: const Text(
            'Le match restera en brouillon (privé) et ne sera pas visible par vos amis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _setPrivacy(true); // true => privé
            },
            child: Text(
              'Rendre privé',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        title: Text(
          'Supprimer le match',
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: const Text(
            "Êtes-vous sûr de vouloir supprimer ce match ?\nCela retirera votre note et votre vote MVP et il n'apparaîtra plus sur votre profil."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler',
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteMatchUserData();
              // refetch complet du match
              await _fetchMatch();
            },
            child: Text(
              'Supprimer',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setPrivacy(bool makePrivate) async {
    if (_isProcessingPrivacy) return;

    setState(() => _isProcessingPrivacy = true);

    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      await RepositoryProvider.userRepository
          .setMatchPrivacy(_currentMatch.id, currentUser.uid, makePrivate);

      if (!mounted) return;
      setState(() {
        _isPrivate = makePrivate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(makePrivate
              ? 'Match rendu privé'
              : 'Match rendu public'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour de la confidentialité'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPrivacy = false);
    }
  }

  Future<void> _deleteMatchUserData() async {
    if (_isProcessingPrivacy) return;

    setState(() => _isProcessingPrivacy = true);

    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      // Supprimer côté repo
      await RepositoryProvider.userRepository
          .removeMatchUserData(currentUser.uid, _currentMatch.id);

      if (!mounted) return;

      // Ne pas modifier _currentMatch localement avec des méthodes qui pourraient écrire.
      // On incrémente la version pour forcer les enfants à se mettre à jour.
      setState(() {
        _userDataVersion++;
        _isFavori = false; // on reset l'icône coeur
      });

      // On fetch ensuite pour récupérer l'état "vrai" depuis le serveur
      // (tu fais déjà un fetch après le dialog, mais si tu veux l'intégrer ici tu peux)
      // await _fetchMatch();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MatchModel supprimé')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erreur lors de la suppression du match (réessayez)')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPrivacy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double toolbarHeight = 50;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: toolbarHeight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.opposite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isUpdatingFavori
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.accent(context),
                    ),
                  )
                : Icon(
                    _isFavori ? Icons.favorite : Icons.favorite_border,
                    color: ColorPalette.accent(context),
                  ),
            onPressed: _toggleFavori,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: _isProcessingPrivacy
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: ColorPalette.accent(context),
                      ),
                    ),
                  )
                : PopupMenuButton<String>(
                    tooltip:
                        _isPrivate ? 'Match privé' : 'Match public',
                    icon: Icon(_isPrivate ? Icons.lock : Icons.public,
                        color: ColorPalette.accent(context)),
                    onSelected: (value) => _onPrivacyMenuSelected(value),
                    itemBuilder: (context) {
                      if (_isPrivate) {
                        return [
                          PopupMenuItem(
                            value: 'publish',
                            child: Row(
                              children: [
                                const Icon(Icons.public, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Rendre le match public',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Supprimer le match',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      } else {
                        return [
                          PopupMenuItem(
                            value: 'makePrivate',
                            child: Row(
                              children: [
                                const Icon(Icons.lock, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Rendre le match privé',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Supprimer le match',
                                  style: TextStyle(
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      }
                    },
                  ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ColorPalette.opposite(context)),
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'partager',
                child: Text(
                  'Partager',
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: ColorPalette.background(context),
            padding:
                EdgeInsets.fromLTRB(16, statusBarHeight + toolbarHeight, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                        _currentMatch.equipeDomicile.logoPath!,
                                        fit: BoxFit.contain)),
                                const SizedBox(height: 6),
                                Text(
                                  _currentMatch.equipeDomicile.nom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${_currentMatch.scoreEquipeDomicile} - ${_currentMatch.scoreEquipeExterieur}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.textPrimary(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                        _currentMatch.equipeExterieur.logoPath!,
                                        fit: BoxFit.contain)),
                                const SizedBox(height: 6),
                                Text(
                                  _currentMatch.equipeExterieur.nom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: getLignesButeurs(
                                      buts: _currentMatch.butsEquipeDomicile,
                                      domicile: true,
                                      fullName: false)
                                  .map(
                                    (line) => Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            ColorPalette.textSecondary(context),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Column(
                              children: const [
                                Icon(Icons.sports_soccer, size: 14),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: getLignesButeurs(
                                      buts: _currentMatch.butsEquipeExterieur,
                                      domicile: false,
                                      fullName: false)
                                  .map(
                                    (line) => Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            ColorPalette.textSecondary(context),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  indicatorColor: ColorPalette.accent(context),
                  labelColor: ColorPalette.textAccent(context),
                  unselectedLabelColor: ColorPalette.textPrimary(context),
                  tabs: const [
                    Tab(text: "Infos"),
                    Tab(text: "Statistiques"),
                    Tab(text: "Mes Amis"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InfosTab(
                  key: ValueKey('${_currentMatch.id}_$_userDataVersion'),
                  match: _currentMatch,
                  userDataVersion: _userDataVersion,
                ),
                Center(child: Text("Contenu Statistiques")),
                MesAmisTab(matchId: _currentMatch.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
