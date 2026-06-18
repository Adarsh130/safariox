import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String id;
  final String tripId;
  final String userId;
  final String registrationId;
  final String studentName;
  final String tripName;
  final String instituteName;
  final String destination;
  final String passId;
  final String downloadUrl;
  final DateTime? tripDate;
  final DateTime? issuedAt;

  Certificate({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.registrationId,
    required this.studentName,
    required this.tripName,
    required this.instituteName,
    required this.destination,
    required this.passId,
    this.downloadUrl = '',
    this.tripDate,
    this.issuedAt,
  });

  factory Certificate.fromMap(Map<String, dynamic> data, String id) {
    return Certificate(
      id: id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      registrationId: data['registrationId'] ?? '',
      studentName: data['studentName'] ?? '',
      tripName: data['tripName'] ?? '',
      instituteName: data['instituteName'] ?? '',
      destination: data['destination'] ?? '',
      passId: data['passId'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      tripDate: (data['tripDate'] as Timestamp?)?.toDate(),
      issuedAt: (data['issuedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'registrationId': registrationId,
      'studentName': studentName,
      'tripName': tripName,
      'instituteName': instituteName,
      'destination': destination,
      'passId': passId,
      'downloadUrl': downloadUrl,
      'tripDate':
          tripDate != null ? Timestamp.fromDate(tripDate!) : null,
      'issuedAt': issuedAt != null
          ? Timestamp.fromDate(issuedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
