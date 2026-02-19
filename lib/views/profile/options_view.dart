import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/blocked_users_view.dart';

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
          'Options',
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
            title: 'Modifier le profil',
            icon: Icons.person_outline,
            onTap: () {},
          ),
          _buildOptionTile(
            context,
            title: 'Notifications',
            icon: Icons.notifications_none,
            onTap: () {},
          ),
          _buildOptionTile(
            context,
            title: 'Confidentialité',
            icon: Icons.lock_outline,
            onTap: () {},
          ),
          _buildOptionTile(
            context,
            title: 'Liste des utilisateurs bloqués',
            icon: Icons.block_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlockedUsersView(currentUser: currentUser),
                ),
              );
            },
            isImportant: true,
          ),
          _buildOptionTile(
            context,
            title: 'À propos',
            icon: Icons.info_outline,
            onTap: () {},
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
