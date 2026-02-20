import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/options_onglets/compte/options_compte.dart';
import 'package:scorescope/views/profile/options_onglets/confidentialite/options_confidentialite.dart';
import 'package:scorescope/views/profile/options_onglets/notifications/options_notifications.dart';
import 'package:scorescope/views/profile/options_onglets/preferences/options_preferences.dart';

class OptionsView extends StatelessWidget {
  final AppUser currentUser;
  const OptionsView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Paramètres',
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
          _buildOptionTile(
            context,
            title: 'Compte',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OptionsCompteView(currentUser: currentUser),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OptionsNotificationsView(currentUser: currentUser),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            title: 'Confidentialité',
            icon: Icons.lock_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OptionsConfidentialiteView(currentUser: currentUser),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            title: 'Préférences',
            icon: Icons.tune_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OptionsPreferencesView(currentUser: currentUser),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            title: 'Support & Informations',
            icon: Icons.info_outline,
            onTap: () {
              // Navigator.push vers SupportView
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isImportant = false,
  }) {
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
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        leading: Icon(
          icon,
          color: isImportant
              ? ColorPalette.accent(context)
              : ColorPalette.textSecondary(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isImportant
                ? ColorPalette.textAccent(context)
                : ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: ColorPalette.textSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
