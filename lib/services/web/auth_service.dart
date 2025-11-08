import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scorescope/services/web/firestore_service.dart';

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

  // -------------------- Email / Password --------------------
  Future<User?> signUp(String email, String password) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credentials.user != null) {
      await FirestoreService().createUserIfNotExists(
        uid: credentials.user!.uid,
        email: credentials.user!.email,
        displayName: credentials.user!.displayName,
        photoUrl: credentials.user!.photoURL,
      );
    }
    return credentials.user;
  }

  Future<User?> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credentials.user != null) {
      await FirestoreService().createUserIfNotExists(
        uid: credentials.user!.uid,
        email: credentials.user!.email,
        displayName: credentials.user!.displayName,
        photoUrl: credentials.user!.photoURL,
      );
    }
    return credentials.user;
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

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate(scopeHint: ['email', 'openid', 'profile']);

      if (googleUser == null) {
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
    } catch (e, st) {
      print('signInWithGoogle error: $e\n$st');
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

  Stream<User?> get userChanges => _auth.userChanges();
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;
}
