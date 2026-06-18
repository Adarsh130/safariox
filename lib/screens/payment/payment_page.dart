import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/registration.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../services/registration_service.dart';
import 'package:uuid/uuid.dart';

class PaymentPage extends StatefulWidget {
  final Registration registration;
  final Trip trip;

  const PaymentPage(
      {super.key, required this.registration, required this.trip});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _paymentService = PaymentService();
  final _regService = RegistrationService();
  final _upiTxnCtrl = TextEditingController();
  Razorpay? _razorpay;
  bool _isProcessing = false;
  String? _paymentId;

  // Admin UPI ID — change in production
  static const String adminUpiId = 'admin@upi';
  static const String adminName = 'SafariOX India';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initRazorpay();
    _loadExistingPayment();
  }

  Future<void> _loadExistingPayment() async {
    final p = await _paymentService
        .getPaymentForRegistration(widget.registration.id);
    if (p != null && mounted) {
      setState(() => _paymentId = p.id);
    }
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    if (_paymentId == null) return;
    await _paymentService.updatePaymentStatus(
      _paymentId!,
      status: AppConfig.paymentPaid,
      razorpayPaymentId: response.paymentId ?? '',
      paymentMethod: 'razorpay',
    );
    await _regService.updatePaymentStatus(
        widget.registration.id, AppConfig.paymentPaid);

    // Generate pass ID
    final passId = const Uuid().v4().substring(0, 8).toUpperCase();
    await _regService.setPassId(widget.registration.id, passId);

    if (!mounted) return;
    _showSuccessDialog(response.paymentId ?? '');
  }

  void _handleRazorpayError(PaymentFailureResponse response) async {
    if (_paymentId != null) {
      await _paymentService.updatePaymentStatus(
        _paymentId!,
        status: AppConfig.paymentFailed,
        paymentMethod: 'razorpay',
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _startRazorpay() async {
    setState(() => _isProcessing = true);
    try {
      // Create payment record
      final p = Payment(
        id: '',
        tripId: widget.trip.id,
        userId: widget.registration.userId,
        registrationId: widget.registration.id,
        amount: widget.trip.pricePerStudent,
        paymentMethod: 'razorpay',
      );
      final pId = await _paymentService.createPayment(p);
      setState(() => _paymentId = pId);

      final options = {
        'key': AppConfig.razorpayKeyId,
        'amount': (widget.trip.pricePerStudent * 100).toInt(),
        'name': 'SafariOX India',
        'description': widget.trip.tripName,
        'prefill': {
          'name': widget.registration.fullName,
          'contact': widget.registration.studentMobile,
        },
        'theme': {'color': '#1B8C4E'},
      };
      _razorpay!.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _openUpiApp(String appName) async {
    final amount = widget.trip.pricePerStudent.toStringAsFixed(2);
    final upiUrl =
        'upi://pay?pa=$adminUpiId&pn=${Uri.encodeComponent(adminName)}&am=$amount&cu=INR&tn=${Uri.encodeComponent(widget.trip.tripName)}';
    try {
      if (await canLaunchUrl(Uri.parse(upiUrl))) {
        await launchUrl(Uri.parse(upiUrl));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No UPI app found. Please install GPay, PhonePe or BHIM.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening UPI app: $e')),
        );
      }
    }
  }

  Future<void> _confirmUpiPayment() async {
    final txnId = _upiTxnCtrl.text.trim();
    if (txnId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the UPI transaction ID')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      String pId = _paymentId ?? '';
      if (pId.isEmpty) {
        final p = Payment(
          id: '',
          tripId: widget.trip.id,
          userId: widget.registration.userId,
          registrationId: widget.registration.id,
          amount: widget.trip.pricePerStudent,
          paymentMethod: 'upi_manual',
          upiTransactionId: txnId,
        );
        pId = await _paymentService.createPayment(p);
        setState(() => _paymentId = pId);
      }
      await _paymentService.updatePaymentStatus(
        pId,
        status: AppConfig.paymentPaid,
        upiTransactionId: txnId,
        paymentMethod: 'upi_manual',
      );
      await _regService.updatePaymentStatus(
          widget.registration.id, AppConfig.paymentPaid);
      final passId = const Uuid().v4().substring(0, 8).toUpperCase();
      await _regService.setPassId(widget.registration.id, passId);

      if (!mounted) return;
      _showSuccessDialog(txnId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String txnId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.radiusLarge)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppConfig.primaryGreen, size: 72),
            const SizedBox(height: 16),
            Text('Payment Successful!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppConfig.primaryGreen)),
            const SizedBox(height: 8),
            Text('Your trip pass has been generated.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppConfig.textGrey),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('View My Pass'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _tabController.dispose();
    _upiTxnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'UPI Apps'),
            Tab(text: 'QR Code'),
            Tab(text: 'Razorpay'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Amount Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppConfig.primaryGradient,
              borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
              boxShadow: AppConfig.elevatedShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount to Pay',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            )),
                    Text(
                      '₹${widget.trip.pricePerStudent.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.registration.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.white)),
                    Text(widget.trip.tripCode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 2,
                            )),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpiTab(),
                _buildQrTab(),
                _buildRazorpayTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay via UPI App',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Select your preferred UPI app to make payment',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
            children: [
              _upiAppButton('GPay', Icons.g_mobiledata, Colors.blue,
                  () => _openUpiApp('gpay')),
              _upiAppButton('PhonePe', Icons.phone_android,
                  Colors.deepPurple, () => _openUpiApp('phonepe')),
              _upiAppButton(
                  'BHIM', Icons.account_balance, Colors.blue.shade900,
                  () => _openUpiApp('bhim')),
              _upiAppButton('Paytm', Icons.payment, Colors.blue,
                  () => _openUpiApp('paytm')),
              _upiAppButton('Any UPI', Icons.open_in_new, AppConfig.primaryGreen,
                  () => _openUpiApp('upi')),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('After Payment',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Enter the UPI Transaction ID from your payment confirmation:',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 12),
          TextField(
            controller: _upiTxnCtrl,
            decoration: const InputDecoration(
              labelText: 'UPI Transaction ID',
              prefixIcon: Icon(Icons.receipt_rounded),
              hintText: 'e.g. 123456789012',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _confirmUpiPayment,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_rounded),
              label: const Text('Confirm Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrTab() {
    final amount = widget.trip.pricePerStudent.toStringAsFixed(2);
    final upiUrl =
        'upi://pay?pa=$adminUpiId&pn=${Uri.encodeComponent(adminName)}&am=$amount&cu=INR&tn=${Uri.encodeComponent(widget.trip.tripName)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Scan QR to Pay',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Open any UPI app and scan this QR code',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Column(
              children: [
                QrImageView(
                  data: upiUrl,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(adminUpiId,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(adminName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppConfig.textGrey)),
                const SizedBox(height: 8),
                Text(
                  '₹$amount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppConfig.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text('After scanning, enter your transaction ID:',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 12),
          TextField(
            controller: _upiTxnCtrl,
            decoration: const InputDecoration(
              labelText: 'UPI Transaction ID',
              prefixIcon: Icon(Icons.receipt_rounded),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _confirmUpiPayment,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirm Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRazorpayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay via Razorpay',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Secure payment via Razorpay gateway',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.security_rounded,
                    color: Colors.blue, size: 36),
                const SizedBox(height: 8),
                Text('100% Secure',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.blue)),
                const SizedBox(height: 4),
                Text(
                  'Supports Credit/Debit Cards, Net Banking, UPI, and Wallets',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppConfig.textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startRazorpay,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.payment_rounded),
              label: Text(
                  'Pay ₹${widget.trip.pricePerStudent.toStringAsFixed(0)} via Razorpay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upiAppButton(
      String name, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
