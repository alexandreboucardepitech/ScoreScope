import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class GraphCard extends StatelessWidget {
  final String title;

  const GraphCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border(context)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Center(
            child: Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: ColorPalette.textSecondary(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
