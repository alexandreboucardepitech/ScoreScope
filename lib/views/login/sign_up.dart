import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class SignUpView extends StatefulWidget {
  final String? prefilledEmail;

  const SignUpView({super.key, this.prefilledEmail});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Si un email est passé, on le met dans le champ
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorPalette.surface(context),
        content: Text(message),
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColorPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          translate.verifieTonEmail,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          translate.unEmailDeConfirmationAEteEnvoye,
          style: TextStyle(
            color: ColorPalette.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              translate.ok,
              style: TextStyle(
                color: ColorPalette.textAccent(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        _showVerificationDialog();
      } else {
        _showError(translate.impossibleDeCreerLeCompte);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? translate.erreurCreationCompte);
    } catch (e) {
      _showError(translate.erreurInconnue);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    bool isConfirmation = false,
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

        if (isConfirmation && v != _passwordController.text) {
          return translate.lesMotsDePasseNeCorrespondentPas;
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLogos.logoAccent(context, size: 72),
                    const SizedBox(width: 16),
                    Text(
                      translate.creerUnCompte,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      translate.rejoinsLaCommunauteScorescope,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorPalette.textSecondary(context),
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// EMAIL
                    _buildInputField(
                      context: context,
                      controller: _emailController,
                      label: translate.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    _buildInputField(
                      context: context,
                      controller: _passwordController,
                      label: translate.motDePasse,
                      obscure: true,
                    ),

                    const SizedBox(height: 16),

                    /// CONFIRM PASSWORD
                    _buildInputField(
                      context: context,
                      controller: _confirmController,
                      label: translate.confirmerLeMotDePasse,
                      obscure: true,
                      isConfirmation: true,
                    ),

                    const SizedBox(height: 28),

                    /// CTA
                    ElevatedButton(
                      onPressed: _loading ? null : _handleSignUp,
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
                              translate.creerMonCompte,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    /// BACK TO LOGIN
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: Text(
                        translate.dejaUnCompteSeConnecter,
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
