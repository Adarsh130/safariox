import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String tripName;
  final String instituteName;
  final String destination;
  final DateTime tripDate;
  final DateTime registrationDeadline;
  final double pricePerStudent;
  final int totalSeats;
  final int availableSeats;
  final String bannerImageUrl;
  final String itineraryPdfUrl;
  final String instructions;
  final String tripCode; // Auto-generated 6-char unique code
  final String status; // active, completed, cancelled
  // Trip Info Fields
  final String schedule;
  final String reportingTime;
  final String pickupPoint;
  final String busDetails;
  final String tourManagerContact;
  final String tourManagerName;
  final String emergencyContact;
  final String emergencyContactName;
  final String googlePhotosLink;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Trip({
    required this.id,
    required this.tripName,
    required this.instituteName,
    required this.destination,
    required this.tripDate,
    required this.registrationDeadline,
    required this.pricePerStudent,
    required this.totalSeats,
    required this.availableSeats,
    this.bannerImageUrl = '',
    this.itineraryPdfUrl = '',
    this.instructions = '',
    required this.tripCode,
    this.status = 'active',
    this.schedule = '',
    this.reportingTime = '',
    this.pickupPoint = '',
    this.busDetails = '',
    this.tourManagerContact = '',
    this.tourManagerName = '',
    this.emergencyContact = '',
    this.emergencyContactName = '',
    this.googlePhotosLink = '',
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Trip.fromMap(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      tripName: data['tripName'] ?? '',
      instituteName: data['instituteName'] ?? '',
      destination: data['destination'] ?? '',
      tripDate: (data['tripDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registrationDeadline:
          (data['registrationDeadline'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      pricePerStudent: (data['pricePerStudent'] ?? 0).toDouble(),
      totalSeats: data['totalSeats'] ?? 0,
      availableSeats: data['availableSeats'] ?? 0,
      bannerImageUrl: data['bannerImageUrl'] ?? '',
      itineraryPdfUrl: data['itineraryPdfUrl'] ?? '',
      instructions: data['instructions'] ?? '',
      tripCode: data['tripCode'] ?? '',
      status: data['status'] ?? 'active',
      schedule: data['schedule'] ?? '',
      reportingTime: data['reportingTime'] ?? '',
      pickupPoint: data['pickupPoint'] ?? '',
      busDetails: data['busDetails'] ?? '',
      tourManagerContact: data['tourManagerContact'] ?? '',
      tourManagerName: data['tourManagerName'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      emergencyContactName: data['emergencyContactName'] ?? '',
      googlePhotosLink: data['googlePhotosLink'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripName': tripName,
      'instituteName': instituteName,
      'destination': destination,
      'tripDate': Timestamp.fromDate(tripDate),
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'pricePerStudent': pricePerStudent,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'bannerImageUrl': bannerImageUrl,
      'itineraryPdfUrl': itineraryPdfUrl,
      'instructions': instructions,
      'tripCode': tripCode,
      'status': status,
      'schedule': schedule,
      'reportingTime': reportingTime,
      'pickupPoint': pickupPoint,
      'busDetails': busDetails,
      'tourManagerContact': tourManagerContact,
      'tourManagerName': tourManagerName,
      'emergencyContact': emergencyContact,
      'emergencyContactName': emergencyContactName,
      'googlePhotosLink': googlePhotosLink,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isRegistrationOpen =>
      DateTime.now().isBefore(registrationDeadline) && status == 'active';

  bool get hasSeatsAvailable => availableSeats > 0;
}
