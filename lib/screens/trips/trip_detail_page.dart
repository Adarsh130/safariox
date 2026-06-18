import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/registration.dart';
import '../../services/registration_service.dart';
import '../registration/student_registration_page.dart';
import '../payment/payment_page.dart';
import '../pass/trip_pass_page.dart';
import '../trip_info/trip_info_page.dart';
import '../gallery/gallery_page.dart';
import '../certificate/certificate_page.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  final RegistrationService _regService = RegistrationService();
  Registration? _myRegistration;
  bool _loading = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadRegistration();
  }

  Future<void> _loadRegistration() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final reg = await _regService.getMyRegistrationForTrip(
        user.uid, widget.trip.id);
    if (mounted) {
      setState(() {
        _myRegistration = reg;
        _loading = false;
      });
    }
  }

  Future<void> _joinTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isJoining = true);
    try {
      // Add trip to user's joinedTrips list
      await FirebaseFirestore.instance
          .collection(AppConfig.colUsers)
          .doc(user.uid)
          .update({
        'joinedTrips': FieldValue.arrayUnion([widget.trip.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      // Navigate to registration form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentRegistrationPage(trip: widget.trip),
        ),
      ).then((_) => _loadRegistration());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final dateStr = DateFormat('dd MMMM, yyyy').format(trip.tripDate);

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConfig.primaryGreen))
          : CustomScrollView(
              slivers: [
                // App Bar with Banner
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppConfig.primaryGreen,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: trip.bannerImageUrl.isNotEmpty
                        ? Image.network(
                            trip.bannerImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _bannerPlaceholder(),
                          )
                        : _bannerPlaceholder(),
                    title: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trip.tripName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Registration Status Banner
                        if (_myRegistration != null)
                          _StatusBanner(registration: _myRegistration!)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.1, end: 0),

                        if (_myRegistration != null) const SizedBox(height: 16),

                        // Trip Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(context, '📍', 'Destination',
                                  trip.destination),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                  context, '📅', 'Trip Date', dateStr),
                            ),
                          ],
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(context, '🪑', 'Seats Available',
                                  '${trip.availableSeats} / ${trip.totalSeats}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(context, '💰', 'Price',
                                  '₹${trip.pricePerStudent.toStringAsFixed(0)}'),
                            ),
                          ],
                        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                        const SizedBox(height: 20),

                        // Trip Code
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppConfig.surfaceGreen,
                            borderRadius:
                                BorderRadius.circular(AppConfig.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_rounded,
                                  color: AppConfig.primaryGreen),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Trip Code',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppConfig.textGrey)),
                                  Text(trip.tripCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              color: AppConfig.primaryGreen,
                                              letterSpacing: 3,
                                              fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 20),

                        // Institute
                        Text('Institute',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: AppConfig.textGrey)),
                        const SizedBox(height: 4),
                        Text(trip.instituteName,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),

                        if (trip.instructions.isNotEmpty) ...[
                          Text('Instructions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: AppConfig.textGrey)),
                          const SizedBox(height: 4),
                          Text(trip.instructions,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                        ],

                        // Action Buttons (based on registration status)
                        _buildActionButtons(context),
                        const SizedBox(height: 24),

                        // Quick Access Section
                        if (_myRegistration != null) ...[
                          Text('Quick Access',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: [
                              _quickAction(context, Icons.info_outlined,
                                  'Trip Info', AppConfig.primaryGreen, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TripInfoPage(trip: trip),
                                  ),
                                );
                              }),
                              _quickAction(context, Icons.photo_library_outlined,
                                  'Gallery', Colors.purple, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GalleryPage(trip: trip),
                                  ),
                                );
                              }),
                              if (_myRegistration!.isPaid &&
                                  trip.status == 'completed')
                                _quickAction(
                                    context,
                                    Icons.workspace_premium_outlined,
                                    'Certificate',
                                    Colors.orange, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CertificatePage(
                                        registration: _myRegistration!,
                                        trip: trip,
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_myRegistration == null) {
      // Not registered yet
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isJoining ? null : _joinTrip,
          icon: _isJoining
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.app_registration_rounded),
          label: const Text('Register for This Trip'),
        ),
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
    }

    final reg = _myRegistration!;

    if (reg.status == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration Pending',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Colors.orange.shade800)),
                  Text('Waiting for admin approval',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppConfig.textGrey)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (reg.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: AppConfig.errorRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppConfig.errorRed),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration Rejected',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: AppConfig.errorRed)),
                  if (reg.adminNote.isNotEmpty)
                    Text('Note: ${reg.adminNote}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppConfig.textGrey)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Approved
    if (reg.status == 'approved' && reg.paymentStatus != 'paid') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.surfaceGreen,
              borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppConfig.primaryGreen),
                const SizedBox(width: 8),
                Text('Registration Approved!',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppConfig.primaryGreen)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      registration: reg,
                      trip: widget.trip,
                    ),
                  ),
                ).then((_) => _loadRegistration());
              },
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Proceed to Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      );
    }

    // Paid
    if (reg.isPaid) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripPassPage(
                  registration: reg,
                  trip: widget.trip,
                ),
              ),
            );
          },
          icon: const Icon(Icons.badge_rounded),
          label: const Text('View My Trip Pass'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.darkGreen,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _infoCard(
      BuildContext context, String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: AppConfig.dividerColor),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                        color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppConfig.primaryGradient),
      child: const Center(
        child: Icon(Icons.tour_rounded, color: Colors.white54, size: 60),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Registration registration;

  const _StatusBanner({required this.registration});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    String subtitle;
    IconData icon;

    if (registration.isPaid) {
      color = AppConfig.primaryGreen;
      label = '✅ Registration Complete';
      subtitle = 'Payment confirmed • Trip pass ready';
      icon = Icons.check_circle_rounded;
    } else if (registration.status == 'approved') {
      color = Colors.blue;
      label = '✅ Approved — Payment Pending';
      subtitle = 'Complete payment to get your trip pass';
      icon = Icons.payment_rounded;
    } else if (registration.status == 'rejected') {
      color = AppConfig.errorRed;
      label = '❌ Registration Rejected';
      subtitle = registration.adminNote.isNotEmpty
          ? registration.adminNote
          : 'Contact your teacher for details';
      icon = Icons.cancel_rounded;
    } else {
      color = Colors.orange;
      label = '⏳ Registration Pending';
      subtitle = 'Awaiting admin approval';
      icon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppConfig.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
