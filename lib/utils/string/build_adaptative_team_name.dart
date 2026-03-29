import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'dart:ui' as ui;

Widget buildAdaptiveTeamName(
  BuildContext context, {
  required String nomComplet,
  required String? nomCourt,
  required bool isWinner,
  required bool isLive,
  required TextAlign align,
}) {
  final textColor = isWinner && !isLive
      ? ColorPalette.textAccent(context)
      : ColorPalette.textPrimary(context);

  final TextStyle baseStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  return LayoutBuilder(
    builder: (context, constraints) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: nomComplet, style: baseStyle),
        maxLines: 2,
        textDirection: ui.TextDirection.ltr,
        textAlign: align,
        textScaler: MediaQuery.of(context).textScaler,
      )..layout(maxWidth: constraints.maxWidth);

      final metrics = textPainter.computeLineMetrics();
      bool isUglyWrap = false;

      if (metrics.length > 1) {
        final endOfFirstLine =
            textPainter.getLineBoundary(const TextPosition(offset: 0)).end;
        if (endOfFirstLine <= 3) {
          isUglyWrap = true;
        }
      }

      final bool fitsComfortably =
          (textPainter.width * 1.1) <= constraints.maxWidth;

      if (!isUglyWrap && fitsComfortably) {
        return Text(
          nomComplet,
          textAlign: align,
          maxLines: 2,
          style: baseStyle,
        );
      }

      if (nomCourt != null) {
        return Text(
          nomCourt,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle,
        );
      }

      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align == TextAlign.end
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          nomComplet,
          style: baseStyle,
        ),
      );
    },
  );
}
