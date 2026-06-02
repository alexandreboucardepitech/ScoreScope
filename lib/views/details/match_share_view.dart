import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/string/get_reaction_emoji.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class MatchShareView extends StatefulWidget {
  final MatchModel match;
  final MatchUserData? matchUserData;
  final AppUser user;

  const MatchShareView({
    super.key,
    required this.match,
    required this.matchUserData,
    required this.user,
  });

  @override
  State<MatchShareView> createState() => _MatchShareViewState();
}

class _MatchShareViewState extends State<MatchShareView> {
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  Joueur? _mvpJoueur;
  bool _loadingMvp = true;

  @override
  void initState() {
    super.initState();
    _loadMvp();
  }

  Future<void> _loadMvp() async {
    final mvpId = widget.matchUserData?.mvpVoteId;
    if (mvpId != null && mvpId.isNotEmpty) {
      try {
        final joueur =
            await RepositoryProvider.joueurRepository.fetchJoueurById(mvpId);
        if (mounted) setState(() => _mvpJoueur = joueur);
      } catch (_) {}
    }
    if (mounted) setState(() => _loadingMvp = false);
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary = _shareKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;

        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/scorescope_match.png');
        await file.writeAsBytes(pngBytes);

        final home = widget.match.equipeDomicile.nomCourt ??
            widget.match.equipeDomicile.nom;
        final away = widget.match.equipeExterieur.nomCourt ??
            widget.match.equipeExterieur.nom;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: translate.jAiNoteXXSurScorescopeapp(home, away),
        );
      } catch (e) {
        debugPrint('Erreur partage match : $e');
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: ColorPalette.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          translate.partagerCeMatch,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loadingMvp
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RepaintBoundary(
                    key: _shareKey,
                    child: _ShareCard(
                      match: widget.match,
                      matchUserData: widget.matchUserData,
                      user: widget.user,
                      mvpJoueur: _mvpJoueur,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _share,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.accentLight,
                        foregroundColor: ColorPalette.textPrimaryDark,
                        disabledBackgroundColor:
                            ColorPalette.accentLight.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorPalette.textPrimaryDark,
                              ),
                            )
                          : const Icon(Icons.share_rounded),
                      label: Text(
                        _isSharing ? translate.preparation : translate.partagerCeMatch,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final MatchModel match;
  final MatchUserData? matchUserData;
  final AppUser user;
  final Joueur? mvpJoueur;

  const _ShareCard({
    required this.match,
    required this.matchUserData,
    required this.user,
    required this.mvpJoueur,
  });

  String get _matchDateLabel {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(match.date);
  }

  String _noteEmoji(int note) => getReactionEmoji(note);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorPalette.accentLight.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildMatchBlock(context),
          _buildDivider(context),
          _buildUserBlock(context),
          _buildSocialFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPalette.accentLight, ColorPalette.accentVariantLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: ColorPalette.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: AppLogos.logoAccent(context, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            'ScoreScope',
            style: TextStyle(
              color: ColorPalette.textPrimaryDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '@${user.displayName}',
                style: const TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                translate.aRegardeCeMatch,
                style: TextStyle(
                  color: ColorPalette.textPrimaryDark.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: user.photoUrl!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _userAvatarFallback(context),
        ),
      );
    }
    return _userAvatarFallback(context);
  }

  Widget _userAvatarFallback(BuildContext context) {
    final initials =
        user.displayName.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorPalette.textPrimaryDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.textPrimaryDark.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: ColorPalette.textPrimaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBlock(BuildContext context) {
    final home = match.equipeDomicile;
    final away = match.equipeExterieur;
    final homeWins = match.scoreEquipeDomicile > match.scoreEquipeExterieur;
    final awayWins = match.scoreEquipeExterieur > match.scoreEquipeDomicile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (match.competition.logoUrl != null) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ColorPalette.logoBackground(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CachedNetworkImage(
                    imageUrl: match.competition.logoUrl!,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                match.competition.nom,
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _teamLogo(home.logoPath, 44, context),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        home.nomCourt ?? home.nom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: homeWins
                              ? ColorPalette.accent(context)
                              : ColorPalette.textPrimary(context),
                          fontWeight:
                              homeWins ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _matchDateLabel,
                      style: TextStyle(
                        color: ColorPalette.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _teamLogo(away.logoPath, 44, context),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        away.nomCourt ?? away.nom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: awayWins
                              ? ColorPalette.accent(context)
                              : ColorPalette.textPrimary(context),
                          fontWeight:
                              awayWins ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamLogo(String? logoPath, double size, BuildContext context) {
    if (logoPath != null) {
      return CachedNetworkImage(
        imageUrl: logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => Icon(Icons.shield,
            color: ColorPalette.textSecondary(context), size: size),
      );
    }
    return Icon(Icons.shield,
        color: ColorPalette.textSecondary(context), size: size);
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: ColorPalette.border(context),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildUserBlock(BuildContext context) {
    final note = matchUserData?.note;
    final visionnage = matchUserData?.visionnageMatch;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _buildUserStat(
              context,
              top: note != null ? _noteEmoji(note) : '❓',
              topIsEmoji: true,
              bottom: note != null ? '$note/10' : translate.nonNote,
              bottomAccent: note != null,
              label: translate.note,
            ),
          ),
          _buildVerticalSeparator(context),
          Expanded(
            child: _buildUserStat(
              context,
              top: visionnage?.emoji ?? '❓',
              topIsEmoji: true,
              bottom: visionnage?.label ?? '-',
              bottomAccent: visionnage != null,
              label: translate.visionnage,
            ),
          ),
          if (mvpJoueur != null) ...[
            _buildVerticalSeparator(context),
            Expanded(
              child: _buildMvpStat(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserStat(
    BuildContext context, {
    required String top,
    required bool topIsEmoji,
    required String bottom,
    required bool bottomAccent,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          top,
          style: TextStyle(
            fontSize: topIsEmoji ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: topIsEmoji ? null : ColorPalette.textPrimary(context),
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bottom,
          style: TextStyle(
            color: bottomAccent
                ? ColorPalette.accent(context)
                : ColorPalette.textSecondary(context),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: ColorPalette.textSecondary(context),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMvpStat(BuildContext context) {
    final joueur = mvpJoueur!;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: joueur.picture,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                _mvpAvatarFallback(joueur.fullName, context),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            joueur.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorPalette.accent(context),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          translate.mvpVote,
          style: TextStyle(
            color: ColorPalette.textSecondary(context),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _mvpAvatarFallback(String name, BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ColorPalette.accentLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ColorPalette.accentLight.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: ColorPalette.accent(context),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSeparator(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: ColorPalette.border(context),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSocialFooter(BuildContext context) {
    final logos = [
      'assets/logos/other/Instagram.png',
      'assets/logos/other/X.png',
      'assets/logos/other/AppleStore.png',
      'assets/logos/other/PlayStore.png',
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.accentLight.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(
            color: ColorPalette.accentLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Scorescope',
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: logos
                .map((asset) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Image.asset(
                        asset,
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
