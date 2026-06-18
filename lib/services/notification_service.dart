import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../config/app_config.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification(NotificationModel notification) async {
    await _db
        .collection(AppConfig.colNotifications)
        .add(notification.toMap());
  }

  Stream<List<NotificationModel>> getTripNotifications(String tripId) {
    return _db
        .collection(AppConfig.colNotifications)
        .where('tripId', isEqualTo: tripId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<NotificationModel>> getNotificationsForTrips(
      List<String> tripIds) {
    if (tripIds.isEmpty) {
      return Stream.value([]);
    }
    // Firestore 'whereIn' supports up to 30 items
    final ids = tripIds.take(30).toList();
    return _db
        .collection(AppConfig.colNotifications)
        .where('tripId', whereIn: ids)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db
        .collection(AppConfig.colNotifications)
        .doc(notificationId)
        .delete();
  }
}
