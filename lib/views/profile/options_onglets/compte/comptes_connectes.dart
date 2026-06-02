import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConnectedAccountsView extends StatefulWidget {
  const ConnectedAccountsView({super.key});

  @override
  State<ConnectedAccountsView> createState() => _ConnectedAccountsViewState();
}

class _ConnectedAccountsViewState extends State<ConnectedAccountsView> {
  User? get _user => FirebaseAuth.instance.currentUser;

  bool get _hasGoogle =>
      _user!.providerData.any((p) => p.providerId == 'google.com');

  bool get _hasPassword =>
      _user!.providerData.any((p) => p.providerId == 'password');

  bool _isLoading = false;

  Future<void> _linkGoogle() async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await user.linkWithPopup(googleProvider);
      } else {
        await authService.initialize();

        if (!GoogleSignIn.instance.supportsAuthenticate()) {
          throw UnsupportedError('GoogleSignIn.authenticate() not supported');
        }

        final googleUser = await GoogleSignIn.instance.authenticate(
          scopeHint: ['email', 'openid', 'profile'],
        );

        final authClient = GoogleSignIn.instance.authorizationClient;
        final authorization = await authClient
            .authorizationForScopes(['email', 'openid', 'profile']);

        final accessToken = authorization?.accessToken;
        final idToken = googleUser.authentication.idToken;

        if (accessToken == null && idToken == null) {
          throw Exception("Tokens Google invalides");
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        await user.linkWithCredential(credential);
      }

      setState(() {});
      _showMessage(translate.compteGoogleConnecte);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        _showMessage(
          translate.ceCompteGoogleEstDejaUtiliseParUnAutreUtilisateur,
        );
      } else {
        _showMessage(e.message ?? translate.erreurGoogle);
      }
    } catch (e) {
      _showMessage(translate.erreurLorsDeLaConnexionGoogle);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkGoogle() async {
    if (_user!.providerData.length <= 1) {
      _showMessage(translate.vousDevezAvoirAuMoinsUneMethodeDeConnexionActive);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _user!.unlink('google.com');
      setState(() {});
      _showMessage(translate.compteGoogleDeconnecte);
    } catch (e) {
      _showMessage(translate.erreurLorsDeLaDeconnexion);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _linkPassword() async {
    final user = _user;
    if (user == null) return;

    final googleProvider = _user!.providerData.firstWhere(
      (p) => p.providerId == 'google.com',
    );

    final email = googleProvider.email;

    final password = await _showCreatePasswordDialog();
    if (password == null || password.length < 6) return;

    if (email == null) {
      _showMessage(translate.impossibleDeRecupererVotreEmail);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      setState(() {});
      _showMessage(translate.motDePasseAjouteAvecSucces);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? translate.erreur);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkPassword() async {
    final user = _user;
    if (user == null) return;

    if (user.providerData.length <= 1) {
      _showMessage(translate.vousDevezAvoirAuMoinsUneMethodeDeConnexionActive);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await user.unlink('password');
      setState(() {});
      _showMessage(translate.motDePasseSupprime);
    } catch (e) {
      _showMessage(translate.erreurLorsDeLaSuppression);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showCreatePasswordDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            translate.creerUnMotDePasse,
            style: TextStyle(
              color: ColorPalette.textPrimary(
                context,
              ),
            ),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: translate.nouveauMotDePasse,
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
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                translate.valider,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required bool isConnected,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isConnected ? translate.connecte : translate.nonConnecte,
                  style: TextStyle(
                    color: isConnected
                        ? ColorPalette.success(context)
                        : ColorPalette.error(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ).copyWith(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Text(
              isConnected ? translate.delier : translate.connecter,
              style: TextStyle(
                color: ColorPalette.accent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            translate.utilisateurNonConnecte,
            style: TextStyle(
              color: ColorPalette.textPrimary(
                context,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          translate.comptesConnectes,
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
          children: [
            _buildTile(
              title: translate.emailMotDePasse,
              isConnected: _hasPassword,
              onPressed: _hasPassword ? _unlinkPassword : _linkPassword,
            ),
            _buildTile(
              title: translate.google,
              isConnected: _hasGoogle,
              onPressed: _hasGoogle ? _unlinkGoogle : _linkGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
