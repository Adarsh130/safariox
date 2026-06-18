import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }
}
