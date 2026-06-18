import 'package:cloud_firestore/cloud_firestore.dart';

class Registration {
  final String id;
  final String tripId;
  final String userId;
  final String tripCode;
  final String fullName;
  final String className;
  final String section;
  final String rollNumber;
  final String studentMobile;
  final String parentMobile;
  final String gender;
  final String address;
  final String photoUrl;
  final String status; // pending, approved, rejected
  final String adminNote;
  final String paymentStatus; // pending, paid, failed
  final String passId; // generated after payment
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Registration({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.tripCode,
    required this.fullName,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.studentMobile,
    required this.parentMobile,
    required this.gender,
    required this.address,
    this.photoUrl = '',
    this.status = 'pending',
    this.adminNote = '',
    this.paymentStatus = 'pending',
    this.passId = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Registration.fromMap(Map<String, dynamic> data, String id) {
    return Registration(
      id: id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      tripCode: data['tripCode'] ?? '',
      fullName: data['fullName'] ?? '',
      className: data['className'] ?? '',
      section: data['section'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      studentMobile: data['studentMobile'] ?? '',
      parentMobile: data['parentMobile'] ?? '',
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      status: data['status'] ?? 'pending',
      adminNote: data['adminNote'] ?? '',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      passId: data['passId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'tripCode': tripCode,
      'fullName': fullName,
      'className': className,
      'section': section,
      'rollNumber': rollNumber,
      'studentMobile': studentMobile,
      'parentMobile': parentMobile,
      'gender': gender,
      'address': address,
      'photoUrl': photoUrl,
      'status': status,
      'adminNote': adminNote,
      'paymentStatus': paymentStatus,
      'passId': passId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isApproved => status == 'approved';
  bool get isPaid => paymentStatus == 'paid';
  bool get hasPass => passId.isNotEmpty;
}
