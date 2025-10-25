import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required bool asOwner,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final uid = credential.user!.uid;
    final now = Timestamp.now();
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': asOwner ? 'owner' : 'user',
      'plan': 'free',
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>?> userDocumentStream() {
    return authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc;
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchCurrentUserDocument() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserRole({
    required String role,
    required Map<String, dynamic> currentData,
  }) async {
    final uid = _auth.currentUser!.uid;
    const validRoles = {'user', 'owner', 'admin'};
    if (!validRoles.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Invalid user role');
    }

    final data = Map<String, dynamic>.from(currentData)
      ..['role'] = role
      ..['updatedAt'] = Timestamp.now();

    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<void> updateDisplayName(String name) async {
    final uid = _auth.currentUser!.uid;
    await _auth.currentUser?.updateDisplayName(name);
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'updatedAt': Timestamp.now(),
    });
  }
}
