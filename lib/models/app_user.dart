import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String role; // 'user' or 'admin'
  final String profileImage;
  final bool isActive;
  final List<String> joinedTrips; // trip IDs
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.profileImage,
    required this.isActive,
    this.joinedTrips = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      profileImage: data['profileImage'] ?? '',
      isActive: data['isActive'] ?? true,
      joinedTrips: List<String>.from(data['joinedTrips'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'isActive': isActive,
      'joinedTrips': joinedTrips,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? role,
    String? profileImage,
    bool? isActive,
    List<String>? joinedTrips,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      joinedTrips: joinedTrips ?? this.joinedTrips,
      createdAt: createdAt,
    );
  }
}
