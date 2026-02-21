import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/main.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/options_onglets/compte/change_email.dart';
import 'package:scorescope/views/profile/options_onglets/compte/change_password.dart';
import 'package:scorescope/views/profile/options_onglets/compte/comptes_connectes.dart';

class OptionsCompteView extends StatelessWidget {
  final AppUser currentUser;

  const OptionsCompteView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Compte',
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
          /// SECTION SÉCURITÉ
          _buildSectionHeader(context, "Sécurité"),

          _buildOptionTile(context,
              title: "Email",
              subtitle: currentUser.email,
              icon: Icons.email_outlined, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeEmailView(currentUser: currentUser),
              ),
            );
          }),

          _buildOptionTile(
            context,
            title: "Mot de passe",
            icon: Icons.lock_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangePasswordView(currentUser: currentUser),
                ),
              );
            },
          ),

          _buildOptionTile(
            context,
            title: "Comptes connectés",
            icon: Icons.link_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectedAccountsView(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          /// SECTION DANGEREUSE
          _buildSectionHeader(context, "Zone sensible"),

          _buildOptionTile(
            context,
            title: "Se déconnecter",
            icon: Icons.logout_outlined,
            onTap: () {
              _showDisconnectDialog(context);
            },
          ),

          _buildOptionTile(
            context,
            title: "Supprimer le compte",
            icon: Icons.delete_outline,
            isDestructive: true,
            onTap: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          color: ColorPalette.textSecondary(context),
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
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
          color:
              isDestructive ? Colors.red : ColorPalette.textSecondary(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isDestructive ? Colors.red : ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: ColorPalette.textSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Se déconnecter",
          style: TextStyle(
            color: ColorPalette.textAccent(context),
          ),
        ),
        content: Text(
          "Voulez-vous vraiment vous déconnecter ?",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await RepositoryProvider.userRepository.signOut();

              RootAppState? root =
                  context.findAncestorStateOfType<RootAppState>();
              root?.restartApp();

              InitialApp.of(context)?.restartApp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            child: Text(
              "Se déconnecter",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Supprimer le compte",
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          "Cette action est irréversible. Toutes vos données seront définitivement supprimées.",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context); // fermer le dialog

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // On demande systématiquement le mot de passe
              final password = await _showReauthDialog(context);
              if (password == null || password.isEmpty) return;

              try {
                await RepositoryProvider.userRepository.deleteAccount(
                  uid: user.uid,
                  email: user.email,
                  password: password,
                  providers:
                      user.providerData.map((e) => e.providerId).toList(),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Compte supprimé avec succès."),
                  ),
                );
                await RepositoryProvider.userRepository.signOut();

                RootAppState? root =
                    context.findAncestorStateOfType<RootAppState>();
                root?.restartApp();

                InitialApp.of(context)?.restartApp();
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erreur : ${e.toString()}"),
                  ),
                );
              }
            },
            child: Text(
              "Supprimer",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Réutiliser le même dialog que pour reauth
  Future<String?> _showReauthDialog(BuildContext context) async {
    final passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirmez votre identité",
            style: TextStyle(
              color: ColorPalette.textAccent(context),
            ),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mot de passe",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Annuler",
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: Text(
                "Confirmer",
                style: TextStyle(
                  color: ColorPalette.textAccent(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
