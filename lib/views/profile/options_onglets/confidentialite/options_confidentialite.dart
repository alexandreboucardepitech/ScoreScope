import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/blocked_users_view.dart';

class OptionsConfidentialiteView extends StatefulWidget {
  final AppUser currentUser;

  const OptionsConfidentialiteView({
    super.key,
    required this.currentUser,
  });

  @override
  State<OptionsConfidentialiteView> createState() =>
      _OptionsConfidentialiteViewState();
}

class _OptionsConfidentialiteViewState
    extends State<OptionsConfidentialiteView> {
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    isPrivate = widget.currentUser.private;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Confidentialité',
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
          _buildSectionHeader(context, "Compte"),
          _buildToggleTile(
            context,
            title: "Compte privé",
            value: isPrivate,
            isMain: false,
            onChanged: (value) async {
              await RepositoryProvider.userRepository.updatePrivateAccount(
                userId: widget.currentUser.uid,
                isPrivate: value,
              );

              setState(() {
                isPrivate = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Autres utilisateurs"),
          _buildOptionTile(
            context,
            title: 'Liste des utilisateurs bloqués',
            icon: Icons.block_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlockedUsersView(currentUser: widget.currentUser),
                ),
              );
            },
            isImportant: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: ColorPalette.textAccent(context),
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    bool isMain = false,
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
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SwitchTheme(
          data: SwitchTheme.of(context).copyWith(
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            trackOutlineWidth: MaterialStateProperty.all(0),
          ),
          child: SwitchListTile(
            hoverColor: Colors.transparent,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            activeColor: ColorPalette.accent(context),
            inactiveThumbColor: ColorPalette.buttonDisabled(context),
            inactiveTrackColor:
                ColorPalette.buttonDisabled(context).withOpacity(0.4),
            value: value,
            onChanged: enabled ? onChanged : null,
            title: Text(
              title,
              style: TextStyle(
                color: enabled
                    ? (isMain
                        ? ColorPalette.textAccent(context)
                        : ColorPalette.textPrimary(context))
                    : ColorPalette.textSecondary(context),
                fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
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
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
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
