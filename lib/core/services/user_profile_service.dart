import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper for reading and writing user profile + settings
/// to Firestore at `users/{uid}`.
///
/// [localAvatarPath] is an in-memory cache of the last picked image path
/// so the Settings profile card can update immediately after save without
/// needing to re-fetch from Firestore.
class UserProfileService {
  final _db = FirebaseFirestore.instance;

  /// Set after the user picks and saves a new profile photo.
  /// Null means fall back to Google photoURL / initials.
  String? localAvatarPath;

  /// In-memory cache of the birthday-reminders toggle so HomeScreen can
  /// read it without an async Firestore call.
  bool birthdaysEnabled = true;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid);

  Future<Map<String, dynamic>?> load(String uid) async {
    final snap = await _ref(uid).get();
    return snap.data();
  }

  Future<void> save(String uid, Map<String, dynamic> data) =>
      _ref(uid).set(data, SetOptions(merge: true));
}
