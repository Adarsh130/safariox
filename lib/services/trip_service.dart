import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../config/app_config.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generate a unique 6-character alphanumeric trip code
  String _generateTripCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    int seed = random;
    for (int i = 0; i < 6; i++) {
      code += chars[seed % chars.length];
      seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
    }
    return code;
  }

  Future<String> createTrip(Trip trip) async {
    String tripCode = _generateTripCode();

    // Ensure code is unique
    bool exists = true;
    while (exists) {
      final snap = await _db
          .collection(AppConfig.colTrips)
          .where('tripCode', isEqualTo: tripCode)
          .limit(1)
          .get();
      exists = snap.docs.isNotEmpty;
      if (exists) tripCode = _generateTripCode();
    }

    final tripWithCode = Trip(
      id: '',
      tripName: trip.tripName,
      instituteName: trip.instituteName,
      destination: trip.destination,
      tripDate: trip.tripDate,
      registrationDeadline: trip.registrationDeadline,
      pricePerStudent: trip.pricePerStudent,
      totalSeats: trip.totalSeats,
      availableSeats: trip.totalSeats,
      bannerImageUrl: trip.bannerImageUrl,
      itineraryPdfUrl: trip.itineraryPdfUrl,
      instructions: trip.instructions,
      tripCode: tripCode,
      status: 'active',
      schedule: trip.schedule,
      reportingTime: trip.reportingTime,
      pickupPoint: trip.pickupPoint,
      busDetails: trip.busDetails,
      tourManagerContact: trip.tourManagerContact,
      tourManagerName: trip.tourManagerName,
      emergencyContact: trip.emergencyContact,
      emergencyContactName: trip.emergencyContactName,
      googlePhotosLink: trip.googlePhotosLink,
      createdBy: trip.createdBy,
    );

    final docRef = await _db
        .collection(AppConfig.colTrips)
        .add(tripWithCode.toMap());
    return docRef.id;
  }

  Future<Trip?> getTripByCode(String code) async {
    final snap = await _db
        .collection(AppConfig.colTrips)
        .where('tripCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return Trip.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<Trip?> getTripById(String tripId) async {
    final doc =
        await _db.collection(AppConfig.colTrips).doc(tripId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Trip.fromMap(doc.data()!, doc.id);
  }

  Stream<List<Trip>> getAllTrips() {
    return _db
        .collection(AppConfig.colTrips)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Trip.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Trip>> getActiveTrips() {
    return _db
        .collection(AppConfig.colTrips)
        .where('status', isEqualTo: 'active')
        .orderBy('tripDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Trip.fromMap(d.data(), d.id)).toList());
  }

  Future<List<Trip>> getTripsByIds(List<String> tripIds) async {
    if (tripIds.isEmpty) return [];
    final List<Trip> trips = [];
    for (final id in tripIds) {
      final trip = await getTripById(id);
      if (trip != null) trips.add(trip);
    }
    return trips;
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _db.collection(AppConfig.colTrips).doc(tripId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    await _db.collection(AppConfig.colTrips).doc(tripId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> decrementSeat(String tripId) async {
    await _db.collection(AppConfig.colTrips).doc(tripId).update({
      'availableSeats': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementSeat(String tripId) async {
    await _db.collection(AppConfig.colTrips).doc(tripId).update({
      'availableSeats': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTrip(String tripId) async {
    await _db.collection(AppConfig.colTrips).doc(tripId).delete();
  }

  // Legacy methods kept for compatibility
  Stream<List<dynamic>> getCustomerTrips(String userId) {
    return const Stream.empty();
  }
}
