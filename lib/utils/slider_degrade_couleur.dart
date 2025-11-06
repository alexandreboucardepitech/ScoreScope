import 'package:flutter/material.dart';

class SliderDegradeCouleur extends SliderTrackShape {
  final LinearGradient gradient;
  final Color inactiveColor;

  const SliderDegradeCouleur({
    required this.gradient,
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 6;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Animation<double>? enableAnimation,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    // 1️⃣ Portion active : appliquer le dégradé sur toute la largeur mais clipper jusqu'au thumb
    final activePaint = Paint()..shader = gradient.createShader(trackRect);

    final activeRect = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
          activeRect, Radius.circular(trackRect.height / 2)),
      activePaint,
    );

    // 2️⃣ Portion inactive : gris
    final inactiveRect = Rect.fromLTRB(
        thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
    final inactivePaint = Paint()..color = inactiveColor;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
          inactiveRect, Radius.circular(trackRect.height / 2)),
      inactivePaint,
    );
  }
}
