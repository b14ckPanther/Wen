import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  AdminRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Stream<List<Map<String, dynamic>>> watchUsers() {
    return _usersCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
    );
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    const validRoles = {'user', 'owner', 'admin'};
    if (!validRoles.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Invalid user role');
    }

    await _usersCollection.doc(userId).update({
      'role': role,
      'roleStatus': 'active',
      'requestedRole': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveOwnerRequest({required String userId}) async {
    await _usersCollection.doc(userId).update({
      'role': 'owner',
      'roleStatus': 'active',
      'requestedRole': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectOwnerRequest({required String userId}) async {
    await _usersCollection.doc(userId).update({
      'roleStatus': 'rejected',
      'requestedRole': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser({required String userId}) async {
    await _usersCollection.doc(userId).delete();
  }
}
