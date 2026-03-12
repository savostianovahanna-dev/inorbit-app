import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../di/injection.dart';
import '../../domain/usecases/sync_data.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  static final _googleSignIn =
      GoogleSignIn.instance; // ← singleton, НЕ створюємо новий!

  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    try {
      // Обов'язково! serverClientId — це Web Client ID з Google Console
      // (той самий, що в Firebase → Authentication → Google → Web SDK configuration)
      // Приклад: 123456789012-abc123def456.apps.googleusercontent.com
      await _googleSignIn.initialize(
        serverClientId:
            '769287403463-j8baukuje8jhjpj2ho61p8gsvbvsjn6i.apps.googleusercontent.com',
        // clientId: 'YOUR_IOS_CLIENT_ID_HERE',   // тільки для iOS, якщо хочеш явно вказати
        // scopes: ['email', 'profile'],           // зазвичай не потрібно
      );

      _googleInitialized = true;
      print('Google Sign-In успішно ініціалізовано');
    } catch (e) {
      print('Помилка ініціалізації Google Sign-In: $e');
      rethrow;
    }
  }

  void _onLoginSuccess(User firebaseUser) {
    final userId = firebaseUser.uid;
    initRemoteRepositories(userId);
    getIt<SyncData>().call().catchError((Object e) {
      debugPrint('Initial sync failed: $e');
    });
  }

  // ── Google ────────────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        return null; // користувач скасував
      }

      // Отримуємо деталі аутентифікації (idToken тут!)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, // тепер працює
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        _onLoginSuccess(userCredential.user!);
      }
      return userCredential;
    } on Exception catch (e, stack) {
      print('Google Sign-In error: $e\n$stack');
      return null;
    }
  }

  // ── Apple ─────────────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    if (userCredential.user != null) {
      _onLoginSuccess(userCredential.user!);
    }
    return userCredential;
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
