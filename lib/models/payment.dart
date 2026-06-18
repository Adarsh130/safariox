import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String tripId;
  final String userId;
  final String registrationId;
  final double amount;
  final String status; // pending, paid, failed
  final String paymentMethod; // razorpay, upi_manual, qr
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String upiTransactionId;
  final String receiptNote;
  final DateTime? paidAt;
  final DateTime? createdAt;

  Payment({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.registrationId,
    required this.amount,
    this.status = 'pending',
    this.paymentMethod = '',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.upiTransactionId = '',
    this.receiptNote = '',
    this.paidAt,
    this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      registrationId: data['registrationId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      razorpayOrderId: data['razorpayOrderId'] ?? '',
      razorpayPaymentId: data['razorpayPaymentId'] ?? '',
      upiTransactionId: data['upiTransactionId'] ?? '',
      receiptNote: data['receiptNote'] ?? '',
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'registrationId': registrationId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'upiTransactionId': upiTransactionId,
      'receiptNote': receiptNote,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
