import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class ChangePasswordView extends StatefulWidget {
  final AppUser currentUser;

  const ChangePasswordView({super.key, required this.currentUser});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isValid = false;

  void _validate() {
    final newPassword = _newPasswordController.text.trim();

    setState(() {
      _isValid = newPassword.length >= 6;
    });
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validate);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final newPassword = _newPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();

    if (user == null) return;

    try {
      await AuthService().reauthenticate(currentPassword);

      await RepositoryProvider.userRepository.updatePassword(
        userId: user.uid,
        newPassword: newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mot de passe mis à jour avec succès."),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erreur inconnue")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mot de passe actuel incorrect."),
        ),
      );
    }
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
          'Modifier le mot de passe',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: ColorPalette.textPrimary(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Mot de passe actuel
            Text(
              "Mot de passe actuel",
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorPalette.tileBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// Nouveau mot de passe
            Text(
              "Nouveau mot de passe",
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorPalette.tileBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            /// Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.accent(context),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: ColorPalette.border(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text(
                  "Mettre à jour",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
