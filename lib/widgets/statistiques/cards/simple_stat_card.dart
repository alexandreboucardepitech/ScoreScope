import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class SimpleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const SimpleStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorAccent = accentColor ?? ColorPalette.accent(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              icon,
              size: 36,
              color: colorAccent,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary(context),
                  height: 0.9,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorPalette.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
