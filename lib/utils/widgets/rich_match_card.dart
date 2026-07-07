import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class RichMatchCard extends StatelessWidget {
  final MatchModel match;
  final int? rating;
  final Joueur? mvpVoted;
  final Joueur? globalMvp;
  final double? globalRating;
  final bool favourite;
  final Color accent;
  final Color goldColor;
  final Color textColor;
  final Color textDimColor;
  final bool isBest;

  const RichMatchCard({
    super.key,
    required this.match,
    this.rating,
    this.mvpVoted,
    this.globalMvp,
    this.globalRating,
    this.favourite = false,
    required this.accent,
    required this.goldColor,
    required this.textColor,
    required this.textDimColor,
    this.isBest = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _teamCol(
                          match.equipeDomicile.logoPath,
                          match.equipeDomicile.code ?? match.equipeDomicile.nom,
                          match.scoreEquipeDomicile >
                              match.scoreEquipeExterieur),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          '${match.scoreEquipeDomicile} - ${match.scoreEquipeExterieur}',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          _ratingBadge('$rating/10', accent),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _teamCol(
                          match.equipeExterieur.logoPath,
                          match.equipeExterieur.code ??
                              match.equipeExterieur.nom,
                          match.scoreEquipeExterieur >
                              match.scoreEquipeDomicile),
                    ),
                  ),
                ],
              ),
              if (mvpVoted != null || globalMvp != null) ...[
                const SizedBox(height: 10),
                Divider(color: accent.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (mvpVoted != null)
                      Expanded(
                        child:
                            _mvpMiniLine(mvpVoted!, translate.tonMvp, accent),
                      ),
                    if (mvpVoted != null && globalMvp != null)
                      Container(
                        width: 1,
                        height: 36,
                        color: accent.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    if (globalMvp != null)
                      Expanded(
                        child: _mvpMiniLine(
                            globalMvp!, translate.mvpGlobal, goldColor),
                      ),
                  ],
                ),
              ],
              if (globalRating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${translate.noteGlobale} : ',
                      style: TextStyle(color: textDimColor, fontSize: 11),
                    ),
                    Text(
                      globalRating!.toStringAsFixed(1),
                      style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(color: textDimColor, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (favourite)
          Positioned(
            top: 6,
            right: 6,
            child: Icon(Icons.star_rounded, color: goldColor, size: 16),
          ),
      ],
    );
  }

  Widget _mvpMiniLine(Joueur joueur, String label, Color color) {
    return Row(
      children: [
        if (joueur.picture.isNotEmpty)
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: joueur.picture,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      _initialsCircle(joueur.fullName, 24, color)))
        else
          _initialsCircle(joueur.fullName, 24, color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: textDimColor, fontSize: 10),
              ),
              Text(_shortName(joueur.fullName),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratingBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _teamCol(String? logoPath, String code, bool wins) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          _teamLogo(logoPath, 34),
          const SizedBox(height: 4),
          Text(
            code,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: wins ? accent : textDimColor,
                fontWeight: wins ? FontWeight.bold : FontWeight.normal,
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _teamLogo(String? logoPath, double size) {
    if (logoPath == null) {
      return Icon(Icons.shield, color: textDimColor, size: size);
    }
    return CachedNetworkImage(
      imageUrl: logoPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) =>
          Icon(Icons.shield, color: textDimColor, size: size),
    );
  }

  Widget _initialsCircle(String fullName, double size, Color color) {
    final trimmed = fullName.trim();
    final initials = trimmed.isEmpty
        ? '?'
        : trimmed
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: size * 0.4),
        ),
      ),
    );
  }

  // NB: implémentation déduite (pas fournie dans l'extrait d'origine) —
  // "Harry Kane" -> "H. Kane". À ajuster si ta version diffère.
  String _shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length < 2) return fullName;
    final first = parts.first;
    final last = parts.sublist(1).join(' ');
    return '${first.isNotEmpty ? first[0] : ''}. $last';
  }
}
