import 'package:flutter/material.dart';

class AppConfig {
  // App Info
  static const String appName = 'SafariOX India';
  static const String appTagline = 'Smart Student Trip Management Platform';
  static const String appVersion = '1.0.0';

  // Razorpay (replace with your actual key)
  static const String razorpayKeyId = 'rzp_test_YOUR_KEY_HERE';
  static const String razorpayKeySecret = 'YOUR_SECRET_HERE';

  // Admin PIN (hashed in production — change this!)
  static const String adminSecretPin = '123456';

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colTrips = 'trips';
  static const String colRegistrations = 'registrations';
  static const String colPayments = 'payments';
  static const String colNotifications = 'notifications';
  static const String colGallery = 'gallery';
  static const String colCertificates = 'certificates';

  // Registration Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';

  // Trip Status
  static const String tripActive = 'active';
  static const String tripCompleted = 'completed';
  static const String tripCancelled = 'cancelled';

  // Colors
  static const Color primaryGreen = Color(0xFF1B8C4E);
  static const Color lightGreen = Color(0xFF4CAF7D);
  static const Color darkGreen = Color(0xFF0D5C32);
  static const Color surfaceGreen = Color(0xFFE8F5EE);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color errorRed = Color(0xFFE53935);
  static const Color bgWhite = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B8C4E), Color(0xFF4CAF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D5C32), Color(0xFF1B8C4E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: AppConfig.primaryGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXL = 32.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
}
