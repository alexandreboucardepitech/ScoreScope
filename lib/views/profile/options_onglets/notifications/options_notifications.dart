import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class OptionsNotificationsView extends StatefulWidget {
  final AppUser currentUser;
  const OptionsNotificationsView({super.key, required this.currentUser});

  @override
  State<OptionsNotificationsView> createState() =>
      _OptionsNotificationsViewState();
}

class _OptionsNotificationsViewState extends State<OptionsNotificationsView> {
  bool globalEnabled = true;
  bool friendRequest = true;
  bool friendRequestAccepted = true;
  bool reaction = true;
  bool comment = true;
  bool favoriteTeamMatch = true;
  bool weeklyRecap = true;

  @override
  void initState() {
    super.initState();
    final options = widget.currentUser.options;
    globalEnabled = options.allNotifications;
    friendRequest = options.friendRequest;
    friendRequestAccepted = options.friendRequestAccepted;
    reaction = options.reaction;
    comment = options.comment;
    favoriteTeamMatch = options.favoriteTeamMatch;
    weeklyRecap = options.weeklyRecap;
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
          translate.notifications,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSectionHeader(context, translate.general),
          _buildToggleTile(
            context,
            title: translate.activerLesNotifications,
            value: globalEnabled,
            isMain: true,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                allNotifications: value,
              );
              setState(() => globalEnabled = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, translate.social),
          _buildToggleTile(
            context,
            title: translate.demandesDAmis,
            value: friendRequest,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                friendRequest: value,
              );
              setState(() => friendRequest = value);
            },
          ),
          _buildToggleTile(
            context,
            title: translate.demandeDAmiAcceptee,
            value: friendRequestAccepted,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                friendRequestAccepted: value,
              );
              setState(() => friendRequestAccepted = value);
            },
          ),
          _buildToggleTile(
            context,
            title: translate.reactionsSurTesMatchs,
            value: reaction,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                reaction: value,
              );
              setState(() => reaction = value);
            },
          ),
          _buildToggleTile(
            context,
            title: translate.commentairesSurTesMatchs,
            value: comment,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                comment: value,
              );
              setState(() => comment = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, translate.matchs),
          _buildToggleTile(
            context,
            title: translate.finDeMatchEquipeFavorite,
            value: favoriteTeamMatch,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                favoriteTeamMatch: value,
              );
              setState(() => favoriteTeamMatch = value);
            },
          ),
          _buildToggleTile(
            context,
            title: translate.recapHebdomadaire,
            value: weeklyRecap,
            enabled: globalEnabled,
            onChanged: (value) {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                weeklyRecap: value,
              );
              setState(() => weeklyRecap = value);
            },
          ),
          const SizedBox(height: 24),
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
}
