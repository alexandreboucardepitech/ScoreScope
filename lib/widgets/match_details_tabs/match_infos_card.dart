import 'package:flutter/material.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/utils/string/date_format.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class MatchInfosCard extends StatelessWidget {
  final MatchModel match;

  const MatchInfosCard({required this.match, super.key});

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
          Row(
            children: [
              Icon(
                Icons.location_pin,
                size: 20,
                color: ColorPalette.accent(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nom du stade — à faire',
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 20,
                color: ColorPalette.accent(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatDateAndHour(match.date),
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: ColorPalette.accent(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.competition.nom,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
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
