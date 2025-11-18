import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class MatchInfosCard extends StatelessWidget {
  const MatchInfosCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Infos match',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          // Lignes placeholder
          Row(
            children: [
              const Text('📍'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nom du stade — à faire',
                  style: TextStyle(color: ColorPalette.textPrimary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('📅'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A FAIRE',
                  style: TextStyle(color: ColorPalette.textPrimary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('🏆'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Compétition — à faire',
                  style: TextStyle(color: ColorPalette.textPrimary(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
