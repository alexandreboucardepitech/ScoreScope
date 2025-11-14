import 'package:flutter/material.dart';
import 'package:scorescope/utils/Color_palette.dart';

class ProfileStatTile extends StatelessWidget {
  final String label;
  final double labelHeight;
  final Widget? valueWidget;
  const ProfileStatTile(
      {super.key,
      required this.label,
      this.valueWidget,
      this.labelHeight = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        valueWidget ?? const SizedBox.shrink(),
        const SizedBox(height: 4),
        SizedBox(
          height: labelHeight,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }
}
