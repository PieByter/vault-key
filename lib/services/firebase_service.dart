import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase services: Auth + Firestore.
///
/// Responsibilities:
/// - Initialize Firebase
/// - User authentication (sign up, login, logout)
/// - CRUD operations on encrypted credential documents
/// - Real-time sync listener for the user's vault collection
class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Auth ─────────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Firestore: Credentials ───────────────────────────────────────────────

  /// Get reference to the user's vault collection.
  CollectionReference<Map<String, dynamic>> _vaultCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('credentials');
  }

  /// Fetch all credentials for current user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllCredentials() async {
    final snapshot = await _vaultCollection().get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Fetch credentials modified after [since] (for incremental sync).
  Future<List<Map<String, dynamic>>> fetchCredentialsSince(
    DateTime since,
  ) async {
    final snapshot = await _vaultCollection()
        .where('updatedAt', isGreaterThanOrEqualTo: since.toIso8601String())
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Upsert (insert or update) a single credential to Firestore.
  Future<void> upsertCredential(Map<String, dynamic> encryptedJson) async {
    final id = encryptedJson['id'] as String;
    await _vaultCollection()
        .doc(id)
        .set(encryptedJson, SetOptions(merge: true));
  }

  /// Delete a credential from Firestore (soft-delete).
  Future<void> deleteCredential(String credentialId) async {
    await _vaultCollection().doc(credentialId).update({'isDeleted': true});
  }

  /// Permanently remove a credential from Firestore.
  Future<void> permanentlyDeleteCredential(String credentialId) async {
    await _vaultCollection().doc(credentialId).delete();
  }

  // ── Firestore: Categories ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _categoriesCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Future<List<Map<String, dynamic>>> fetchAllCategories() async {
    final snapshot = await _categoriesCollection().get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> upsertCategory(Map<String, dynamic> category) async {
    final id = category['id'] as String;
    await _categoriesCollection()
        .doc(id)
        .set(category, SetOptions(merge: true));
  }

  // ── Real-time Listener ───────────────────────────────────────────────────

  /// Listen for real-time changes to the user's vault.
  Stream<List<Map<String, dynamic>>> watchCredentials() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('credentials')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ── Keep-Alive (Prevent Supabase pause — not needed for Firebase) ────────

  /// Ping Firestore to keep connection alive. Firebase doesn't pause.
  Future<void> ping() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'lastPing': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
