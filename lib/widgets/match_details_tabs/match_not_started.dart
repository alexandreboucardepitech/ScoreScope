import 'package:flutter/material.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class MatchNotStarted extends StatefulWidget {
  final ValueChanged<bool> onNotificationsChanged;
  final String matchId;

  const MatchNotStarted({
    super.key,
    required this.onNotificationsChanged,
    required this.matchId,
  });

  @override
  State<MatchNotStarted> createState() => _MatchNotStartedState();
}

class _MatchNotStartedState extends State<MatchNotStarted> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final currentUser =
          await RepositoryProvider.userRepository.getCurrentUser();
      if (currentUser == null) {
        return;
      }

      MatchUserData? matchUserData = await RepositoryProvider.userRepository
          .fetchUserMatchUserData(currentUser.uid, widget.matchId);
      bool notif = matchUserData?.notifications ?? false;

      if (!mounted) return;
      setState(() {
        _notificationsEnabled = notif;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  void _onNotificationsChanged(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    widget.onNotificationsChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onNotificationsChanged(!_notificationsEnabled),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(
                _notificationsEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_outlined,
                size: 28,
                color: ColorPalette.textSecondary(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Le match n'a pas encore commencé !",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Active les notifications",
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: _onNotificationsChanged,
                activeColor: ColorPalette.accent(context),
                inactiveThumbColor: ColorPalette.buttonDisabled(context),
                inactiveTrackColor:
                    ColorPalette.buttonDisabled(context).withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
