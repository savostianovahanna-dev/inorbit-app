import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:inorbit/core/services/notification_service.dart';
import 'package:inorbit/data/local/app_database.dart';

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
      await _googleSignIn.initialize(
        serverClientId:
            '769287403463-j8baukuje8jhjpj2ho61p8gsvbvsjn6i.apps.googleusercontent.com',
      );

      _googleInitialized = true;
      debugPrint('Google Sign-In успішно ініціалізовано');
    } catch (e) {
      debugPrint('Помилка ініціалізації Google Sign-In: $e');
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
      final googleUser = await _googleSignIn.authenticate();

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
      debugPrint('Google Sign-In error: $e\n$stack');
      return null;
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _ensureGoogleInitialized();
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // Re-authenticate (required by Firebase for account deletion)
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);

    // Delete Firestore data
    final firestore = FirebaseFirestore.instance;
    final friendsSnap = await firestore.collection('users/$uid/friends').get();
    for (final doc in friendsSnap.docs) {
      await doc.reference.delete();
    }
    final momentsSnap = await firestore.collection('users/$uid/moments').get();
    for (final doc in momentsSnap.docs) {
      await doc.reference.delete();
    }
    await firestore.doc('users/$uid').delete();

    // Delete local SQLite data
    final db = getIt<AppDatabase>();
    await db.friendsDao.deleteNotInIds([], uid);

    // Cancel all notifications
    await NotificationService.instance.cancelAll();

    // Delete Firebase Auth account + sign out Google
    await user.delete();
    await _googleSignIn.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
}
