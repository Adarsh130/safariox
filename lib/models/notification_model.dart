import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String tripId;
  final String title;
  final String message;
  final String type; // reporting_time, bus_update, instruction, emergency
  final String sentBy;
  final DateTime? sentAt;

  NotificationModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.message,
    this.type = 'instruction',
    this.sentBy = '',
    this.sentAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      tripId: data['tripId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'instruction',
      sentBy: data['sentBy'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'title': title,
      'message': message,
      'type': type,
      'sentBy': sentBy,
      'sentAt': sentAt != null
          ? Timestamp.fromDate(sentAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  String get typeIcon {
    switch (type) {
      case 'reporting_time':
        return '🕐';
      case 'bus_update':
        return '🚌';
      case 'emergency':
        return '🚨';
      case 'instruction':
      default:
        return '📢';
    }
  }
}
