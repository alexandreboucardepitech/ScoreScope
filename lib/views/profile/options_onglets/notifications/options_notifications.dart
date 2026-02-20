import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
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

  bool newFollowers = true;
  bool likes = true;
  bool comments = true;
  bool replies = true;
  bool favoriteTeamMatch = true;
  bool results = true;
  bool emailNotifications = false;

  @override
  void initState() {
    super.initState();

    final options = widget.currentUser.options;

    globalEnabled = options.allNotifications;
    newFollowers = options.newFollowers;
    likes = options.likes;
    comments = options.comments;
    replies = options.replies;
    favoriteTeamMatch = options.favoriteTeamMatch;
    results = options.results;
    emailNotifications = options.emailNotifications;
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
          'Notifications',
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
          _buildSectionHeader(context, "Général"),
          _buildToggleTile(
            context,
            title: "Activer les notifications",
            value: globalEnabled,
            isMain: true,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                allNotifications: value,
              );
              setState(() {
                globalEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Activité"),
          _buildToggleTile(
            context,
            title: "Nouveaux abonnés",
            value: newFollowers,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                newFollowers: value,
              );
              setState(() => newFollowers = value);
            },
          ),
          _buildToggleTile(
            context,
            title: "Likes",
            value: likes,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                likes: value,
              );
              setState(() => likes = value);
            },
          ),
          _buildToggleTile(
            context,
            title: "Commentaires",
            value: comments,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                comments: value,
              );
              setState(() => comments = value);
            },
          ),
          _buildToggleTile(
            context,
            title: "Réponses",
            value: replies,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                replies: value,
              );
              setState(() => replies = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Matchs"),
          _buildToggleTile(
            context,
            title: "Match équipe favorite",
            value: favoriteTeamMatch,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                favoriteTeamMatch: value,
              );
              setState(() => favoriteTeamMatch = value);
            },
          ),
          _buildToggleTile(
            context,
            title: "Résultats",
            value: results,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                results: value,
              );
              setState(() => results = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Email"),
          _buildToggleTile(
            context,
            title: "Communications par e-mail",
            value: emailNotifications,
            enabled: globalEnabled,
            onChanged: (value) async {
              RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                emailNotifications: value,
              );
              setState(() => emailNotifications = value);
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
