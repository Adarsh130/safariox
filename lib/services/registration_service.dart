import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registration.dart';
import '../config/app_config.dart';

class RegistrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> hasAlreadyRegistered(String userId, String tripId) async {
    final snap = await _db
        .collection(AppConfig.colRegistrations)
        .where('userId', isEqualTo: userId)
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String> createRegistration(Registration registration) async {
    final docRef = await _db
        .collection(AppConfig.colRegistrations)
        .add(registration.toMap());
    return docRef.id;
  }

  Future<Registration?> getMyRegistrationForTrip(
      String userId, String tripId) async {
    final snap = await _db
        .collection(AppConfig.colRegistrations)
        .where('userId', isEqualTo: userId)
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Registration.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Stream<List<Registration>> getMyRegistrations(String userId) {
    return _db
        .collection(AppConfig.colRegistrations)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Registration.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<Registration>> getTripRegistrations(String tripId) {
    return _db
        .collection(AppConfig.colRegistrations)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Registration.fromMap(d.data(), d.id))
            .toList());
  }

  Future<List<Registration>> getTripRegistrationsList(String tripId) async {
    final snap = await _db
        .collection(AppConfig.colRegistrations)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => Registration.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateRegistrationStatus(
      String registrationId, String status, {String adminNote = ''}) async {
    await _db
        .collection(AppConfig.colRegistrations)
        .doc(registrationId)
        .update({
      'status': status,
      'adminNote': adminNote,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePaymentStatus(
      String registrationId, String paymentStatus) async {
    await _db
        .collection(AppConfig.colRegistrations)
        .doc(registrationId)
        .update({
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setPassId(String registrationId, String passId) async {
    await _db
        .collection(AppConfig.colRegistrations)
        .doc(registrationId)
        .update({
      'passId': passId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePhotoUrl(
      String registrationId, String photoUrl) async {
    await _db
        .collection(AppConfig.colRegistrations)
        .doc(registrationId)
        .update({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Registration?> watchRegistration(String registrationId) {
    return _db
        .collection(AppConfig.colRegistrations)
        .doc(registrationId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Registration.fromMap(doc.data()!, doc.id);
    });
  }

  Future<int> getPendingCount(String tripId) async {
    final snap = await _db
        .collection(AppConfig.colRegistrations)
        .where('tripId', isEqualTo: tripId)
        .where('status', isEqualTo: AppConfig.statusPending)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
