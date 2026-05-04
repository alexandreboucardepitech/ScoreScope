import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scorescope/services/web/firestore_service.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;
  GoogleSignInAccount? _currentGoogleUser;

  AuthService();

  Future<void> initialize() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await _googleSignIn.initialize();
        _isGoogleSignInInitialized = true;
      } catch (e, st) {
        print('GoogleSignIn initialization failed: $e\n$st');
        _isGoogleSignInInitialized = false;
      }
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isGoogleSignInInitialized) await initialize();
  }

  Future<User?> signUp(String email, String password) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;

    if (user != null) {
      try {
        await user.sendEmailVerification();
        print("✅ Email de vérification envoyé");
      } catch (e) {
        print("❌ Erreur envoi email: $e");
      }

      await FirestoreService().createUserIfNotExists(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    }

    return user;
  }

  Future<User?> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;

    if (user == null) {
      return null;
    }

    await user.reload();
    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: "email-not-verified",
        message: "Veuillez vérifier votre email avant de vous connecter.",
      );
    }

    // Seulement si vérifié
    await FirestoreService().createUserIfNotExists(
      uid: refreshedUser.uid,
      email: refreshedUser.email,
      displayName: refreshedUser.displayName,
      photoUrl: refreshedUser.photoURL,
    );

    return refreshedUser;
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          await FirestoreService().createUserIfNotExists(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email,
            displayName: userCredential.user!.displayName,
            photoUrl: userCredential.user!.photoURL,
          );
        }
        return userCredential.user;
      }

      await _ensureInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
            'GoogleSignIn.authenticate() is not supported on this platform');
      }

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'openid', 'profile'],
        );
      } on GoogleSignInException catch (_) {
        return null;
      } catch (e) {
        return null;
      }

      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient
          .authorizationForScopes(['email', 'openid', 'profile']);

      final String? accessToken = authorization?.accessToken;
      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null && idToken == null) {
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _currentGoogleUser = googleUser;

      if (userCredential.user != null) {
        await FirestoreService().createUserIfNotExists(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
        );
      }

      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      print("Google Sign-In error: $e");
      return null;
    } on PlatformException catch (e) {
      if (e.code == 'canceled' || e.code == 'sign_in_canceled') {
        return null;
      }
      print("PlatformException during Google Sign-In: $e");
      return null;
    } catch (e, st) {
      print("Unexpected error: $e\n$st");
      return null;
    }
  }

  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureInitialized();
    try {
      final result = _googleSignIn.attemptLightweightAuthentication();
      if (result is Future<GoogleSignInAccount?>) return await result;
      return result as GoogleSignInAccount?;
    } catch (e) {
      print('Silent sign-in failed: $e');
      return null;
    }
  }

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureInitialized();
    try {
      final authClient = _googleSignIn.authorizationClient;
      var authorization = await authClient.authorizationForScopes(scopes);
      authorization ??= await authClient.authorizeScopes(scopes);
      return authorization.accessToken;
    } catch (e) {
      print('Failed to get access token for scopes: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
      }
    }
    await _auth.signOut();
    _currentGoogleUser = null;
  }

  Future<void> reauthenticate(String password) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      throw Exception("Utilisateur non authentifié.");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<User?> signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],

        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: 'com.scorescope.app.login',
                redirectUri: Uri.parse(
                  'https://scorescope-5a12b.firebaseapp.com/__/auth/handler',
                ),
              )
            : null,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user != null) {
        final String? displayName = user.displayName ??
            "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}"
                .trim();

        await FirestoreService().createUserIfNotExists(
          uid: user.uid,
          email: user.email,
          displayName: displayName?.isEmpty ?? true ? null : displayName,
          photoUrl: user.photoURL,
        );
      }

      return user;
    } catch (e, st) {
      print("Unexpected Apple Sign-In error: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorPalette.surface(context),
        content: Text(
          "Erreur Apple : $e\n$st",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
      ),
    );
      return null;
    }
  }

  Stream<User?> get userChanges => _auth.userChanges();
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;
}
