import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class SimpleStatListItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const SimpleStatListItem({
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: colorAccent,
          ),
          const SizedBox(width: 12),

          /// Titre
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Valeur
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
