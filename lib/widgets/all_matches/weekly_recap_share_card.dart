import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class WeeklyRecapShareCard extends StatelessWidget {
  final dynamic data;
  final String weekLabel;
  final int funStatIndex;

  const WeeklyRecapShareCard({
    super.key,
    required this.data,
    required this.weekLabel,
    required this.funStatIndex,
  });

  @override
  Widget build(BuildContext context) {
    final d = data;

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorPalette.background(context),
            ColorPalette.surface(context),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBrandHeader(context),
              const SizedBox(height: 40),
              _buildHeader(context, d),
              const SizedBox(height: 24),
              if (d.bestMatch != null) ...[
                _buildBestMatch(context, d),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  if (d.topCompetitionName != null) ...[
                    Expanded(
                      child: _buildTopComp(context, d),
                    ),
                    const SizedBox(width: 20),
                  ],
                  Expanded(
                    child: _buildStreak(context, d),
                  ),
                ],
              ),
              const Spacer(),
              _buildFunStat(context, d),
              const SizedBox(height: 40),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AppLogos.logoAccent(context, size: 52),
            const SizedBox(width: 16),
            Text(
              'ScoreScope',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: ColorPalette.accent(context).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            translate.recapHebdo,
            style: TextStyle(
              color: ColorPalette.accent(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic d) {
    final diff = d.matchCount - d.prevWeekMatchCount;

    final diffColor = diff > 0
        ? ColorPalette.successLight
        : diff < 0
            ? ColorPalette.errorLight
            : ColorPalette.textPrimaryDark;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorPalette.accentLight,
            ColorPalette.accentVariantLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weekLabel,
            style: TextStyle(
              color: ColorPalette.textPrimaryDark.withValues(alpha: 0.7),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${d.matchCount}',
                style: const TextStyle(
                  color: ColorPalette.textPrimaryDark,
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 18),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  translate.matchsRegardes,
                  style: TextStyle(
                    color: ColorPalette.textPrimaryDark.withValues(alpha: 0.9),
                    fontSize: 38,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (diff != 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    translate.xXVsSemainePrecedente(diff > 0 ? '+' : '', diff.toString()),
                    style: TextStyle(
                      color: diffColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestMatch(BuildContext context, dynamic d) {
    final match = d.bestMatch!;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: ColorPalette.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 ${translate.meilleurMatch}',
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 24),
          match.buildDetailsLine(
            context: context,
            podium: PodiumContext(
              rank: 1,
              value: d.bestMatchRating ?? 0,
            ),
            large: true,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: ColorPalette.accent(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${d.bestMatchRating}/10',
              style: TextStyle(
                color: ColorPalette.accent(context),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopComp(BuildContext context, dynamic d) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏅 ${translate.competition}',
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (d.topCompetitionLogo != null)
                CachedNetworkImage(
                  imageUrl: d.topCompetitionLogo!,
                  width: 56,
                  height: 56,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.topCompetitionName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      '${d.topCompetitionCount} ${translate.matchs}',
                      style: TextStyle(
                        color: ColorPalette.textSecondary(context),
                        fontSize: 18,
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

  Widget _buildStreak(BuildContext context, dynamic d) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 ${translate.serie}',
            style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${d.streak}',
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  translate.semainesConsecutives,
                  style: TextStyle(
                    color: ColorPalette.textSecondary(context),
                    fontSize: 18,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunStat(BuildContext context, dynamic d) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        d.funStats[funStatIndex],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontSize: 30,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          translate.telechargeScorescope,
          style: TextStyle(
            color: ColorPalette.textSecondary(context),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
