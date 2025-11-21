import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class ProfileAction extends StatefulWidget {
  final AppUser? user;
  final Amitie? amitie; // peut être null si aucune relation
  final bool isMe;
  final Function(String)? onStatusChanged;

  const ProfileAction({
    super.key,
    required this.user,
    required this.amitie,
    required this.isMe,
    this.onStatusChanged,
  });

  @override
  State<ProfileAction> createState() => _ProfileActionState();
}

class _ProfileActionState extends State<ProfileAction> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await RepositoryProvider.userRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      currentUserId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si on est sur notre profil, afficher le bouton "Modifier le profil"
    if (widget.isMe) {
      return ElevatedButton.icon(
        onPressed: () {
          // placeholder pour l'édition de profil (sera remplacé plus tard)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Click sur "modifier le profil"')),
          );
        },
        icon: Icon(Icons.edit, size: 16, color: ColorPalette.accent(context)),
        label: Text(
          'Modifier le profil',
          style: TextStyle(color: ColorPalette.textPrimary(context)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.buttonSecondary(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    // Pour les profils autres que le mien : logique d'amitié
    String label;
    IconData icon;
    bool isClickable = false;

    // Si on n'a pas encore l'id courant, montrer un placeholder (ou loader)
    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    final status = widget.amitie?.status ?? 'none';
    final isSentByMe = widget.amitie != null &&
        widget.amitie!.firstUserId == currentUserId &&
        status == 'pending';

    switch (status) {
      case 'accepted':
        label = "Amis";
        icon = Icons.check;
        isClickable = true;
        break;
      case 'pending':
        label = isSentByMe ? "En attente" : "Demande reçue";
        icon = Icons.hourglass_top;
        isClickable = true;
        break;
      case 'blocked':
        label = "Bloqué";
        icon = Icons.block;
        isClickable = false;
        break;
      default:
        label = "Ajouter";
        icon = Icons.add;
        isClickable = true;
    }

    return ElevatedButton.icon(
      onPressed: isClickable ? () => _showDialog(context, isSentByMe) : null,
      icon: Icon(icon, size: 16, color: ColorPalette.accent(context)),
      label: Text(
        label,
        style: TextStyle(color: ColorPalette.textPrimary(context)),
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
    if (widget.amitie?.status == 'blocked') return;

    final status = widget.amitie?.status ?? 'none';
    final List<Widget> actions = <Widget>[];

    if (status == 'none') {
      actions.addAll([
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Annuler",
              style: TextStyle(color: ColorPalette.textPrimary(context))),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _handleFriendAction(context, 'send');
          },
          child: Text("Envoyer",
              style: TextStyle(color: ColorPalette.textPrimary(context))),
        ),
      ]);
    } else if (status == 'pending') {
      if (isSentByMe) {
        // j'ai envoyé la demande -> possibilité d'annuler
        actions.addAll([
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Annuler",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleFriendAction(context, 'cancel');
            },
            child: Text("Retirer la demande",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
        ]);
      } else {
        // j'ai reçu la demande -> refuser / accepter
        actions.addAll([
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleFriendAction(context, 'remove');
            },
            child: Text("Refuser",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleFriendAction(context, 'accept');
            },
            child: Text("Accepter",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Annuler",
                style: TextStyle(color: ColorPalette.textPrimary(context))),
          ),
        ]);
      }
    } else if (status == 'accepted') {
      actions.addAll([
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Annuler",
              style: TextStyle(color: ColorPalette.textPrimary(context))),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _handleFriendAction(context, 'remove');
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
          style: TextStyle(color: ColorPalette.textPrimary(context), fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: actions,
      ),
    );
  }

  String _getDialogString(bool isSentByMe) {
    final status = widget.amitie?.status ?? 'none';
    switch (status) {
      case 'accepted':
        return "Voulez-vous retirer l'ami ${widget.user?.displayName ?? "cet utilisateur"} ?";
      case 'pending':
        if (isSentByMe) {
          return "Voulez-vous retirer la demande d'ami à ${widget.user?.displayName ?? "cet utilisateur"} ?";
        } else {
          return "Accepter la demande d'ami de ${widget.user?.displayName ?? "cet utilisateur"} ?";
        }
      case 'blocked':
        return "Vous avez bloqué cet utilisateur.";
      default:
        return "Voulez-vous envoyer une demande d'ami à ${widget.user?.displayName ?? "cet utilisateur"} ?";
    }
  }

  String _getSnackbarMessage(String action) {
    switch (action) {
      case 'send':
        return "Demande d'ami envoyée à ${widget.user?.displayName} avec succès!";
      case 'cancel':
        return "Demande d'ami à ${widget.user?.displayName} annulée avec succès!";
      case 'accept':
        return "${widget.user?.displayName} est désormais votre ami!";
      case 'remove':
        return "Ami ${widget.user?.displayName} retiré avec succès!";
      default:
        return "Action effectuée avec succès!";
    }
  }

  Future<void> _handleFriendAction(BuildContext context, String action) async {
    if (widget.user == null) return;
    final currentUser = await RepositoryProvider.userRepository.getCurrentUser();
    if (currentUser == null) return;

    final amitieRepo = RepositoryProvider.amitieRepository;

    try {
      switch (action) {
        case 'send':
          await amitieRepo.sendFriendRequest(currentUser.uid, widget.user!.uid);
          break;
        case 'cancel':
          await amitieRepo.removeFriend(currentUser.uid, widget.user!.uid);
          break;
        case 'accept':
          await amitieRepo.acceptFriendRequest(currentUser.uid, widget.user!.uid);
          break;
        case 'remove':
          await amitieRepo.removeFriend(currentUser.uid, widget.user!.uid);
          break;
      }

      if (!mounted) return;

      if (widget.onStatusChanged != null) {
        String newStatus;
        if (action == 'send') {
          newStatus = 'pending';
        } else if (action == 'accept') {
          newStatus = 'accepted';
        } else {
          newStatus = 'none';
        }
        widget.onStatusChanged!(newStatus);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getSnackbarMessage(action))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'action sur l'utilisateur.")),
      );
    }
  }
}
