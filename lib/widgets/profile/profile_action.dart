import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

/// Presentational widget: affiche uniquement le statut fourni et
/// émet des intentions d'action via `onActionRequested`.
class ProfileAction extends StatelessWidget {
  final AppUser? user;
  final Amitie? amitie; // source de vérité (peut être null)
  final bool isMe;
  final String?
      currentUserId; // utile pour savoir si la demande a été envoyée par moi
  final void Function(String action)? onActionRequested;

  const ProfileAction({
    super.key,
    required this.user,
    required this.amitie,
    required this.isMe,
    this.currentUserId,
    this.onActionRequested,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Click sur "modifier le profil"')),
          );
        },
        icon: Icon(Icons.edit, size: 16, color: ColorPalette.accent(context)),
        label: Text('Modifier le profil',
            style: TextStyle(color: ColorPalette.textPrimary(context))),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.buttonSecondary(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    final status = amitie?.status ?? 'none';
    final isSentByMe = (currentUserId != null) &&
        (amitie != null) &&
        (amitie!.firstUserId == currentUserId) &&
        status == 'pending';

    String label;
    IconData icon;
    bool isClickable = status != 'blocked';

    switch (status) {
      case 'accepted':
        label = "Amis";
        icon = Icons.check;
        break;
      case 'pending':
        label = isSentByMe ? "En attente" : "Demande reçue";
        icon = Icons.hourglass_top;
        break;
      case 'blocked':
        label = "Bloqué";
        icon = Icons.block;
        break;
      default:
        label = "Ajouter";
        icon = Icons.add;
    }

    return ElevatedButton.icon(
      onPressed: isClickable ? () => _showDialog(context, isSentByMe) : null,
      icon: Icon(icon, size: 16, color: ColorPalette.accent(context)),
      label: Text(label,
          style: TextStyle(color: ColorPalette.textPrimary(context))),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: ColorPalette.buttonDisabled(context),
        backgroundColor: ColorPalette.buttonSecondary(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showDialog(BuildContext context, bool isSentByMe) {
    if (amitie?.status == 'blocked') return;

    final status = amitie?.status ?? 'none';
    final List<Widget> actions = <Widget>[];

    if (status == 'none') {
      actions.addAll([
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Annuler",
                style: TextStyle(color: ColorPalette.textPrimary(context)))),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onActionRequested?.call('send');
          },
          child: Text("Envoyer",
              style: TextStyle(color: ColorPalette.textPrimary(context))),
        ),
      ]);
    } else if (status == 'pending') {
      if (isSentByMe) {
        actions.addAll([
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annuler",
                  style: TextStyle(color: ColorPalette.textPrimary(context)))),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onActionRequested?.call('cancel');
            },
            child: Text("Retirer la demande",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
        ]);
      } else {
        actions.addAll([
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onActionRequested?.call('remove');
            },
            child: Text(
              "Refuser",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onActionRequested?.call('accept');
            },
            child: Text(
              "Accepter",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ]);
      }
    } else if (status == 'accepted') {
      actions.addAll([
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Annuler",
                style: TextStyle(color: ColorPalette.textPrimary(context)))),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onActionRequested?.call('remove');
          },
          child: Text("Retirer",
              style: TextStyle(color: ColorPalette.textPrimary(context))),
        ),
      ]);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Amitié",
            style: TextStyle(
                color: ColorPalette.textAccent(context),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        content: Text(
          _getDialogString(isSentByMe),
          style:
              TextStyle(color: ColorPalette.textPrimary(context), fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: actions,
      ),
    );
  }

  String _getDialogString(bool isSentByMe) {
    final displayName = user?.displayName ?? "cet utilisateur";
    switch (amitie?.status ?? 'none') {
      case 'accepted':
        return "Voulez-vous retirer l'ami $displayName ?";
      case 'pending':
        if (isSentByMe) {
          return "Voulez-vous retirer la demande d'ami à $displayName ?";
        } else {
          return "Accepter la demande d'ami de $displayName ?";
        }
      case 'blocked':
        return "Vous avez bloqué cet utilisateur.";
      default:
        return "Voulez-vous envoyer une demande d'ami à $displayName ?";
    }
  }
}
