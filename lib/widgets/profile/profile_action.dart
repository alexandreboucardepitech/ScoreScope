import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/edit_profile_view.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class ProfileAction extends StatelessWidget {
  final AppUser? user;
  final Amitie? amitie;
  final bool isMe;
  final String? currentUserId;
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
        onPressed: () async {
          if (user != null) {
            String? editProfile = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return EditProfileView(
                    user: user!,
                  );
                },
              ),
            );
            if (editProfile != null && editProfile == 'profileEdited') {
              onActionRequested?.call(editProfile);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  translate.erreurAucunUtilisateurNEstSpecifie,
                ),
              ),
            );
          }
        },
        icon: Icon(Icons.edit, size: 16, color: ColorPalette.accent(context)),
        label: Text(
          translate.modifierLeProfil,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.buttonSecondary(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    final status = amitie?.status ?? 'none';
    final isSentByMe = (currentUserId != null) &&
        (amitie != null) &&
        (amitie!.firstUserId == currentUserId) &&
        (status == 'pending' || status == 'blocked');

    String label;
    IconData icon;
    bool isClickable =
        (status != 'blocked') || (status == 'blocked' && isSentByMe);

    switch (status) {
      case 'accepted':
        label = translate.amis;
        icon = Icons.check;
        break;
      case 'pending':
        label = isSentByMe ? translate.enAttente : translate.demandeRecue;
        icon = Icons.hourglass_top;
        break;
      case 'blocked':
        label = translate.bloque;
        icon = Icons.block;
        break;
      default:
        label = translate.ajouter;
        icon = Icons.add;
    }

    return ElevatedButton.icon(
      onPressed: isClickable ? () => _showDialog(context, isSentByMe) : null,
      icon: Icon(icon, size: 16, color: ColorPalette.accent(context)),
      label: Text(
        label,
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
        ),
      ),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: ColorPalette.buttonDisabled(context),
        backgroundColor: ColorPalette.buttonSecondary(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showDialog(BuildContext context, bool isSentByMe) {
    final status = amitie?.status ?? 'none';
    final List<Widget> actions = <Widget>[];

    if (status == 'none') {
      actions.addAll([
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            translate.annuler,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onActionRequested?.call('send');
          },
          child: Text(
            translate.envoyer,
            style: TextStyle(
              color: ColorPalette.textAccent(context),
            ),
          ),
        ),
      ]);
    } else if (status == 'pending') {
      if (isSentByMe) {
        actions.addAll([
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              translate.annuler,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onActionRequested?.call('cancel');
            },
            child: Text(
              translate.retirerLaDemande,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ]);
      } else {
        actions.addAll([
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              translate.annuler,
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
              translate.refuser,
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
              translate.accepter,
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
          child: Text(
            translate.annuler,
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
            translate.retirer,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
      ]);
    } else if (status == 'blocked') {
      actions.addAll([
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            translate.annuler,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onActionRequested?.call('unblock');
          },
          child: Text(
            translate.debloquer,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
        ),
      ]);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          translate.amitie,
          style: TextStyle(
              color: ColorPalette.textAccent(context),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
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
    final displayName = user?.displayName ?? translate.cetUtilisateur;
    switch (amitie?.status ?? 'none') {
      case 'accepted':
        return translate.voulezVousRetirerLAmiX(displayName);
      case 'pending':
        if (isSentByMe) {
          return translate.voulezVousRetirerLaDemandeDAmiAX(displayName);
        } else {
          return translate.accepterLaDemandeDAmiDeX(displayName);
        }
      case 'blocked':
        return translate.voulezVousDebloquerX(displayName);
      default:
        return translate.voulezVousEnvoyerUneDemandeDAmiAX(displayName);
    }
  }
}
