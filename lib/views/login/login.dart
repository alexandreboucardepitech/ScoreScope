import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/main.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/views/login/sign_up.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorPalette.surface(context),
        content: Text(message),
      ),
    );
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        if (user != null) {
          InitialApp.of(context)?.restartApp();
        } else {
          _showError('Connexion annulée ou impossible.');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Erreur d\'authentification');
    } catch (e) {
      _showError('Erreur inconnue');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (mounted) setState(() => _loading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (mounted) {
        if (user != null) {
          InitialApp.of(context)?.restartApp();
        } else {
          _showError('Connexion Google annulée.');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message ?? 'Erreur Google');
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur inconnue');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (mounted) setState(() => _loading = true);
    try {
      final user = await _authService.signInWithApple(context);
      if (mounted) {
        if (user != null) {
          InitialApp.of(context)?.restartApp();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message ?? 'Erreur Apple');
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur inconnue');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(
        color: ColorPalette.textPrimary(context),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return translate.xRequis(label);
        }
        if (label == translate.email && !v.contains('@')) {
          return translate.emailInvalide;
        }
        if (label == translate.motDePasse && v.length < 6) {
          return translate.auMoins6Caracteres;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: ColorPalette.textSecondary(context),
        ),
        filled: true,
        fillColor: ColorPalette.surfaceSecondary(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorPalette.border(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorPalette.accent(context),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorPalette.error(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorPalette.surface(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.highlight(context),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppLogos.logoAccent(context, size: 72),
                    const SizedBox(width: 16),
                    Text(
                      translate.connexion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      translate.connecteToiPourAccederAScorescope,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// ---- EMAIL ----
                    _buildInputField(
                      context: context,
                      controller: _emailController,
                      label: translate.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    /// ---- PASSWORD ----
                    _buildInputField(
                      context: context,
                      controller: _passwordController,
                      label: translate.motDePasse,
                      obscure: true,
                    ),

                    const SizedBox(height: 28),

                    /// ---- PRIMARY BUTTON ----
                    ElevatedButton(
                      onPressed: _loading ? null : _handleEmailSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _loading
                            ? ColorPalette.buttonDisabled(context)
                            : ColorPalette.buttonPrimary(context),
                        foregroundColor: ColorPalette.opposite(context),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorPalette.opposite(context),
                              ),
                            )
                          : Text(
                              translate.seConnecter,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    if (Platform.isIOS) ...[
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _handleAppleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              ColorPalette.buttonSecondary(context),
                          side: BorderSide(
                            color: ColorPalette.border(context),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          Icons.login,
                          color: ColorPalette.textPrimary(context),
                        ),
                        label: Text(
                          translate.continuerAvecApple,
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              ColorPalette.buttonSecondary(context),
                          side: BorderSide(
                            color: ColorPalette.border(context),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          Icons.login,
                          color: ColorPalette.textPrimary(context),
                        ),
                        label: Text(
                          translate.continuerAvecGoogle,
                          style: TextStyle(
                            color: ColorPalette.textPrimary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpView(
                                    prefilledEmail:
                                        _emailController.text.isNotEmpty
                                            ? _emailController.text.trim()
                                            : null,
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        translate.creerUnCompte,
                        style: TextStyle(
                          color: ColorPalette.textAccent(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
