import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- STATS ---
  Future<Map<String, int>> getPlatformStats() async {
    final users = await _db.collection('users').get();
    final trips = await _db.collection('trip_requests').get();
    
    int vendors = 0;
    int drivers = 0;
    for (var doc in users.docs) {
      if (doc.data()['role'] == 'vendor') vendors++;
      if (doc.data()['role'] == 'driver') drivers++;
    }

    return {
      'totalUsers': users.docs.length,
      'totalVendors': vendors,
      'totalDrivers': drivers,
      'totalTrips': trips.docs.length,
    };
  }

  // --- USER MANAGEMENT ---
  Stream<List<AppUser>> getAllUsersStream() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  Future<void> toggleUserStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }

  // --- TOUR MANAGEMENT ---
  Stream<QuerySnapshot> getAllToursStream() {
    return _db.collection('tours').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateTourStatus(String tourId, String status) async {
    await _db.collection('tours').doc(tourId).update({'status': status});
  }

  // --- BOOKING MANAGEMENT ---
  Stream<QuerySnapshot> getAllBookingsStream() {
    return _db.collection('bookings').orderBy('createdAt', descending: true).snapshots();
  }
}
