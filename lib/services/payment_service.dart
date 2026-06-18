import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../config/app_config.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createPayment(Payment payment) async {
    final docRef = await _db
        .collection(AppConfig.colPayments)
        .add(payment.toMap());
    return docRef.id;
  }

  Future<Payment?> getPaymentForRegistration(String registrationId) async {
    final snap = await _db
        .collection(AppConfig.colPayments)
        .where('registrationId', isEqualTo: registrationId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Payment.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Stream<List<Payment>> getTripPayments(String tripId) {
    return _db
        .collection(AppConfig.colPayments)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Payment.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updatePaymentStatus(
    String paymentId, {
    required String status,
    String razorpayPaymentId = '',
    String upiTransactionId = '',
    String paymentMethod = '',
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == AppConfig.paymentPaid) {
      data['paidAt'] = FieldValue.serverTimestamp();
    }
    if (razorpayPaymentId.isNotEmpty) {
      data['razorpayPaymentId'] = razorpayPaymentId;
    }
    if (upiTransactionId.isNotEmpty) {
      data['upiTransactionId'] = upiTransactionId;
    }
    if (paymentMethod.isNotEmpty) {
      data['paymentMethod'] = paymentMethod;
    }
    await _db
        .collection(AppConfig.colPayments)
        .doc(paymentId)
        .update(data);
  }

  Future<double> getTotalCollected(String tripId) async {
    final snap = await _db
        .collection(AppConfig.colPayments)
        .where('tripId', isEqualTo: tripId)
        .where('status', isEqualTo: AppConfig.paymentPaid)
        .get();
    double total = 0.0;
    for (final d in snap.docs) {
      total += ((d.data()['amount'] ?? 0) as num).toDouble();
    }
    return total;
  }

  Stream<List<Payment>> getUserPayments(String userId) {
    return _db
        .collection(AppConfig.colPayments)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Payment.fromMap(d.data(), d.id)).toList());
  }
}
