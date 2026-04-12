import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/util/podium_context.dart';
import 'package:scorescope/models/util/podium_displayable.dart';
import 'package:scorescope/utils/string/round_smart.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/couleur_from_hexa.dart';

abstract class BasicPodiumDisplayable implements PodiumDisplayable {
  String get displayLabel;
  String? get longDisplayLabel;
  String? get displayImage;
  bool get circleImage => false;

  @override
  Widget buildPodiumCard({
    required BuildContext context,
    required PodiumContext podium,
    bool logoBackground = true,
  }) {
    final isFirst = podium.isFirst;
    Color color = podium.color != null
        ? fromHex(podium.color!)
        : ColorPalette.accent(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (displayImage != null && isFirst)
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(logoBackground ? 6 : 0),
            decoration: BoxDecoration(
              color: logoBackground
                  ? ColorPalette.logoBackground(context)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: circleImage
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: displayImage!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: displayImage!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
          ),
        if (displayImage != null && isFirst) const SizedBox(width: 12),
        Expanded(
          child: isFirst
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isFirst ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    buildValueChip(
                      context,
                      num.parse(roundSmart(podium.value.toDouble())),
                      color,
                      large: isFirst,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      '${podium.rank}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: podium.rank == 2 ? Colors.grey : Colors.brown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                    ),
                    Text(
                      roundSmart(podium.value.toDouble()),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.textPrimary(context),
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget buildPodiumRow({
    required BuildContext context,
    required PodiumContext podium,
    bool logoBackground = true,
  }) {
    final isFirst = podium.isFirst;
    Color color = podium.color != null
        ? fromHex(podium.color!)
        : ColorPalette.accent(context);

    final textColor = color.computeLuminance() > 0.5
        ? ColorPalette.textPrimaryLight
        : ColorPalette.textPrimaryDark;

    return Row(
      children: [
        if (displayImage != null && isFirst)
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(logoBackground ? 6 : 0),
            decoration: BoxDecoration(
              color: logoBackground
                  ? ColorPalette.logoBackground(context)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: circleImage
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: displayImage!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: displayImage!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
          ),
        if (isFirst) const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayLabel,
            maxLines: isFirst ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isFirst ? 16 : 14,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (isFirst)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roundSmart(podium.value.toDouble()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          )
        else
          Text(
            roundSmart(podium.value.toDouble()),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  @override
  Widget buildDetailsLine({
    required BuildContext context,
    required PodiumContext podium,
    bool large = true,
  }) {
    return Text(
      large
          ? longDisplayLabel ?? displayLabel
          : displayLabel, // si large : on prend le long si il existe, sinon le court
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ColorPalette.textPrimary(context),
        fontWeight:
            (podium.rank ?? 4) <= 3 ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

Widget buildValueChip(
  BuildContext context,
  num value,
  Color accent, {
  bool large = false,
}) {
  final textColor =
      accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: large ? 12 : 10,
      vertical: large ? 6 : 4,
    ),
    decoration: large
        ? BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          )
        : null,
    child: Text(
      value.toString(),
      style: TextStyle(
        fontSize: large ? 12 : 10,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
  );
}
