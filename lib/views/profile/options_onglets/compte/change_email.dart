import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class ChangeEmailView extends StatefulWidget {
  final AppUser currentUser;

  const ChangeEmailView({super.key, required this.currentUser});

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final TextEditingController _emailController = TextEditingController();

  bool _isValid = false;

  void _validate() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    setState(() {
      _isValid = emailRegex.hasMatch(email);
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final newEmail = _emailController.text.trim();

    if (user == null) return;

    try {
      await RepositoryProvider.userRepository.updateEmail(
        userId: user.uid,
        newEmail: newEmail,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate.unEmailDeConfirmationAEteEnvoyeAVotreNouvelleAdresse,
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' || e.code == 'user-token-expired') {
        final password = await _showReauthDialog();
        if (password == null) return;

        try {
          await AuthService().reauthenticate(password);

          await RepositoryProvider.userRepository.updateEmail(
            userId: user.uid,
            newEmail: newEmail,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translate.unEmailDeConfirmationAEteEnvoye,
              ),
            ),
          );

          Navigator.pop(context);
        } catch (reauthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translate.motDePasseIncorrect),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? translate.erreurInconnue),
          ),
        );
      }
    }
  }

  Future<String?> _showReauthDialog() async {
    final passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            translate.confirmezVotreIdentite,
            style: TextStyle(
              color: ColorPalette.textPrimary(
                context,
              ),
            ),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: translate.motDePasse,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translate.annuler,
                style: TextStyle(
                  color: ColorPalette.textPrimary(
                    context,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: Text(
                translate.confirmer,
                style: TextStyle(
                  color: ColorPalette.textPrimary(
                    context,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
          translate.modifierLEmail,
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
            if (widget.currentUser.email != null) ...[
              /// Email actuel
              Text(
                translate.emailActuel,
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.currentUser.email!,
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 32),

            /// Nouveau email
            Text(
              translate.nouvelEmail,
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: "exemple@email.com",
                filled: true,
                fillColor: ColorPalette.tileBackground(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorPalette.border(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorPalette.accent(context),
                  ),
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
                child: Text(
                  translate.mettreAJour,
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
