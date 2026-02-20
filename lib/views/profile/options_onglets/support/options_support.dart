import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class OptionsSupportView extends StatelessWidget {
  const OptionsSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Support & Informations',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: ColorPalette.textPrimary(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildTile(context, "À propos"),
          _buildTile(context, "Signaler un bug"),
          _buildTile(context, "CGU"),
          _buildTile(context, "Politique de confidentialité"),
          _buildTile(context, "Version"),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorPalette.border(context),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          Icons.info_outline,
          color: ColorPalette.textSecondary(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: ColorPalette.textSecondary(context),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$title" n\'est pas encore implémenté.'),
            ),
          );
        },
      ),
    );
  }
}
