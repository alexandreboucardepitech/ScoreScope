import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/display_score_or_match_date.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/display_prolongations_penaltys.dart';
import 'package:scorescope/views/details/match_share_view.dart';
import 'package:scorescope/views/details/player_details_page.dart';
import 'package:scorescope/views/details/team_details_page.dart';
import 'package:scorescope/widgets/match_details_tabs/compositions.dart';
import 'package:scorescope/widgets/match_details_tabs/infos.dart';
import 'package:scorescope/widgets/match_details_tabs/mes_amis.dart';
import '../../models/match.dart';
import '../../utils/string/get_lignes_buteurs.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class MatchDetailsPage extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<InfosTabState> _infosTabKey = GlobalKey<InfosTabState>();

  bool _pageHasUnsavedRating = false;
  int? _pagePendingRating;

  late TabController _tabController;
  bool _isFavori = false;
  bool _isUpdatingFavori = false;

  bool _isPrivate = true;
  bool _isProcessingPrivacy = false;

  late MatchModel _currentMatch;

  bool _isFetchingMatch = false;

  int _userDataVersion = 0;

  MatchUserData? userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMatch = widget.match;
    _loadFavoriStatus();
    _loadPrivateStatus();
    _loadMatchUserData();
  }

  Future<void> _reloadMatch() async {
    try {
      final freshMatch = await RepositoryProvider.matchRepository
          .fetchMatchById(_currentMatch.id);
      if (freshMatch != null) {
        setState(() => _currentMatch = freshMatch);
      }
    } catch (e) {
      debugPrint('Erreur lors du rechargement du match: $e');
    }
  }

  Future<void> _refresh() async {
    _reloadMatch();
    _loadFavoriStatus();
    _loadPrivateStatus();
    setState(() {});
  }

  Future<void> _fetchMatch() async {
    if (_isFetchingMatch) return;

    setState(() => _isFetchingMatch = true);

    try {
      final freshMatch = await RepositoryProvider.matchRepository
          .fetchMatchById(_currentMatch.id);
      if (!mounted) return;
      if (freshMatch == null) return;
      setState(() => _currentMatch = freshMatch);
    } catch (e) {
      debugPrint('Erreur lors du fetch du match: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingMatch = false);
      }
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
      if (mounted) {
        setState(() => _isProcessingPrivacy = false);
      }
    }
  }

  Future<void> _loadMatchUserData() async {
    try {
      final currentUser = RepositoryProvider.userRepository.currentUser;
      if (currentUser != null) {
        final data = await RepositoryProvider.userRepository
            .fetchUserMatchUserData(currentUser.uid, _currentMatch.id);
        if (!mounted) return;
        setState(() => userData = data);
      }
    } catch (e) {
      debugPrint(
        translate
            .erreurLorsDuChargementDesDonneesUtilisateurDuMatchX(e.toString()),
      );
    }
  }

  Future<String?> _showUnsavedDialog() {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        title: Text(
          translate.modificationsEnAttente,
          style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold),
        ),
        content: Text(
          _pagePendingRating != null
              ? translate.laNoteXSur10SeraPerdueSiTuQuittesMaintenant(_pagePendingRating.toString())
              : translate.taNoteSeraPerdueSiTuQuittesMaintenant,
          style: TextStyle(color: ColorPalette.textPrimary(context)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'continue'),
              child: Text(translate.continuerAModifier,
                  style: TextStyle(color: ColorPalette.textPrimary(context)))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'leave'),
              child: Text(translate.quitterSansEnregistrer,
                  style: TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.accent(context)),
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(translate.enregistrerEtQuitter,
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavori() async {
    if (_isUpdatingFavori) return;
    setState(() => _isUpdatingFavori = true);

    final newFavori = !_isFavori;

    try {
      AppUser? currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser != null) {
        await RepositoryProvider.userRepository.matchFavori(
          _currentMatch.id,
          currentUser.uid,
          _currentMatch.date,
          newFavori,
        );
      }
      if (!mounted) return;
      setState(() {
        _isFavori = newFavori;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavori
                ? translate.matchAjouteAuxFavoris
                : translate.matchRetireDesFavoris,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate.erreurLorsDeLaMiseAJourDuFavori),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingFavori = false);
      }
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
          translate.rendreLeMatchPublic,
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: Text(
          translate.leMatchSeraRenduPublicEtVisibleParVosAmis,
          style: TextStyle(
            color: ColorPalette.textPrimary(
              context,
            ),
          ),
        ),
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
              backgroundColor: ColorPalette.accent(context),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _setPrivacy(false); // false => rendu public
            },
            child: Text(
              translate.rendrePublic,
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
          translate.rendreLeMatchPrive,
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: Text(
          translate.leMatchResteraPriveEtNeSeraPasVisibleParVosAmis,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
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
              backgroundColor: ColorPalette.accent(context),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _setPrivacy(true); // true => privé
            },
            child: Text(
              translate.rendrePrive,
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
          translate.supprimerLeMatch,
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: Text(
          translate.etesVousSurDeVouloirSupprimerCeMatch,
        ),
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
              Navigator.of(context).pop();
              await _deleteMatchUserData();
              // refetch complet du match
              await _fetchMatch();
            },
            child: Text(
              translate.supprimer,
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
      if (currentUser == null)
        throw Exception(translate.utilisateurNonConnecte);

      await RepositoryProvider.userRepository.setMatchPrivacy(
        _currentMatch.id,
        currentUser.uid,
        _currentMatch.date,
        makePrivate,
      );

      if (!mounted) return;
      setState(() {
        _isPrivate = makePrivate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(makePrivate
              ? translate.matchRenduPrive
              : translate.matchRenduPublic),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate.erreurLorsDeLaMiseAJourDeLaConfidentialite),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPrivacy = false);
      }
    }
  }

  Future<void> _deleteMatchUserData() async {
    if (_isProcessingPrivacy) return;

    setState(() => _isProcessingPrivacy = true);

    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser == null)
        throw Exception(translate.utilisateurNonConnecte);

      _currentMatch.mvpVotes
          .removeWhere((userId, voteId) => userId == currentUser.uid);
      _currentMatch.notes
          .removeWhere((userId, note) => userId == currentUser.uid);

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorPalette.accent(context),
          content: Text(translate.matchSupprime),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate.erreurLorsDeLaSuppressionDuMatch),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPrivacy = false);
      }
    }
  }

  void _toggleNotifications(bool value) async {
    if (userData != null) {
      MatchUserData newUserData = MatchUserData(
        matchId: userData!.matchId,
        comments: userData!.comments,
        favourite: userData!.favourite,
        matchDate: userData!.matchDate,
        mvpVoteId: userData!.mvpVoteId,
        note: userData!.note,
        notifications: value,
        private: userData!.private,
        reactions: userData!.reactions,
        visionnageMatch: userData!.visionnageMatch,
        watchedAt: userData!.watchedAt,
      );
      setState(() {
        userData = newUserData;
      });
    } else {
      setState(() {
        userData = MatchUserData(
          matchId: widget.match.id,
          notifications: value,
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translate.notificationsXPourXX(
              value ? 'activées' : 'désactivées',
              widget.match.equipeDomicile.nomCourt ??
                  widget.match.equipeDomicile.nom,
              widget.match.equipeExterieur.nomCourt ??
                  widget.match.equipeExterieur.nom),
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    AppUser? currentUser = RepositoryProvider.userRepository.currentUser;
    if (currentUser != null) {
      await RepositoryProvider.userRepository.updateMatchNotifications(
        matchId: widget.match.id,
        userId: currentUser.uid,
        matchDate: widget.match.date,
        activateNotifications: value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double toolbarHeight = 50;

    return PopScope(
      canPop: !_pageHasUnsavedRating,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final action = await _showUnsavedDialog();
        if (action == 'save') {
          await _infosTabKey.currentState?.savePendingRating();
          if (mounted) Navigator.pop(context, result);
        } else if (action == 'leave') {
          if (mounted) Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: toolbarHeight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorPalette.opposite(context)),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            if (widget.match.isLive)
              IconButton(
                icon: Icon(
                  userData?.notifications ?? false
                      ? Icons.notifications_active
                      : Icons.notifications_outlined,
                  color: ColorPalette.accent(context),
                ),
                onPressed: () => _toggleNotifications(
                  !(userData?.notifications ?? false),
                ),
              ),
            if (widget.match.isScheduled == false) ...[
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
              _isProcessingPrivacy
                  ? SizedBox(
                      width: 48,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: ColorPalette.accent(context),
                          ),
                        ),
                      ),
                    )
                  : PopupMenuButton<String>(
                      tooltip: _isPrivate
                          ? translate.matchPrive
                          : translate.matchPublic,
                      icon: Icon(
                        _isPrivate ? Icons.lock : Icons.public,
                        color: ColorPalette.accent(context),
                      ),
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
                                    translate.rendreLeMatchPublic,
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
                                    translate.supprimerLeMatch,
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
                                    translate.rendreLeMatchPrive,
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
                                    translate.supprimerLeMatch,
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
            ],
            if (widget.match.isFinished &&
                userData != null &&
                userData?.watchedAt != null)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
                icon: Icon(Icons.share_rounded,
                    color: ColorPalette.accent(context)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchShareView(
                      match: _currentMatch,
                      matchUserData: userData,
                      user: RepositoryProvider.userRepository.currentUser!,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: ColorPalette.background(context),
              padding: EdgeInsets.fromLTRB(
                  16, statusBarHeight + toolbarHeight, 16, 0),
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
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamDetailsPage(
                                        teamId: _currentMatch.equipeDomicile.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CachedNetworkImage(
                                        imageUrl: _currentMatch
                                            .equipeDomicile.logoPath!,
                                        fit: BoxFit.contain,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.shield,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _currentMatch.equipeDomicile.nom,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    displayScoreOrMatchDate(_currentMatch),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: ColorPalette.textPrimary(context),
                                    ),
                                  ),
                                  if (_currentMatch.isScheduled)
                                    Text(
                                      DateFormat('d MMMM', 'fr_FR')
                                          .format(_currentMatch.date),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ColorPalette.textPrimary(context),
                                      ),
                                    ),
                                  if (_currentMatch.isLive &&
                                      _currentMatch.liveMinute != null)
                                    Text(
                                      _currentMatch.isHalftime
                                          ? translate.miTemps
                                          : _currentMatch.extraTime != null
                                              ? "${_currentMatch.liveMinute!}+${_currentMatch.extraTime!}'"
                                              : "${_currentMatch.liveMinute}'",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorPalette.textAccent(context),
                                      ),
                                    ),
                                  ...displayProlongationsPenaltys(
                                    match: _currentMatch,
                                    context: context,
                                    fontSize: 16,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamDetailsPage(
                                        teamId:
                                            _currentMatch.equipeExterieur.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CachedNetworkImage(
                                        imageUrl: _currentMatch
                                            .equipeExterieur.logoPath!,
                                        fit: BoxFit.contain,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.shield,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _currentMatch.equipeExterieur.nom,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ColorPalette.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  fullName: true,
                                )
                                    .map(
                                      (line) => InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlayerDetailsPage(
                                                playerId: line.joueur.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          line.nomJoueur,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorPalette.textSecondary(
                                                context),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            if (_currentMatch.scoreEquipeDomicile > 0 ||
                                _currentMatch.scoreEquipeExterieur > 0)
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
                                  fullName: true,
                                )
                                    .map(
                                      (line) => InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlayerDetailsPage(
                                                playerId: line.joueur.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          line.nomJoueur,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorPalette.textSecondary(
                                                context),
                                          ),
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
                    tabs: [
                      Tab(text: translate.infos),
                      Tab(text: translate.compositions),
                      Tab(text: translate.mesAmis),
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
                    key: _infosTabKey,
                    match: _currentMatch,
                    userDataVersion: _userDataVersion,
                    onRefresh: _refresh,
                    onUnsavedRatingChanged: (hasUnsaved, pending) {
                      setState(() {
                        _pageHasUnsavedRating = hasUnsaved;
                        _pagePendingRating = pending;
                      });
                    },
                  ),
                  CompositionsTab(
                    match: _currentMatch,
                    onRefresh: _refresh,
                  ),
                  MesAmisTab(
                    matchId: _currentMatch.id,
                    onRefresh: _refresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
