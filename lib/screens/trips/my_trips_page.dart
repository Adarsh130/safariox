import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/registration.dart';
import '../../services/trip_service.dart';
import '../../services/registration_service.dart';
import '../../services/user_service.dart';
import '../trips/trip_detail_page.dart';
import '../trips/join_trip_page.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  final _tripService = TripService();
  final _regService = RegistrationService();
  final _userService = UserService();
  List<Trip> _trips = [];
  Map<String, Registration?> _registrationMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final appUser = await _userService.getUser(user.uid);
      final tripIds = appUser?.joinedTrips ?? [];
      final trips = await _tripService.getTripsByIds(tripIds);

      final Map<String, Registration?> regMap = {};
      for (final trip in trips) {
        final reg = await _regService.getMyRegistrationForTrip(
            user.uid, trip.id);
        regMap[trip.id] = reg;
      }

      if (mounted) {
        setState(() {
          _trips = trips;
          _registrationMap = regMap;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgWhite,
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JoinTripPage()),
            ).then((_) => _loadData()),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppConfig.primaryGreen))
          : RefreshIndicator(
              color: AppConfig.primaryGreen,
              onRefresh: _loadData,
              child: _trips.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _trips.length,
                      itemBuilder: (ctx, i) {
                        final trip = _trips[i];
                        final reg = _registrationMap[trip.id];
                        return _TripListTile(
                          trip: trip,
                          registration: reg,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TripDetailPage(trip: trip)),
                          ).then((_) => _loadData()),
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: 60 * i),
                                duration: 400.ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.backpack_outlined,
                color: AppConfig.textLight, size: 64),
            const SizedBox(height: 16),
            Text('No Trips Yet',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Join a trip using a trip code from your teacher.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConfig.textGrey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinTripPage()),
              ).then((_) => _loadData()),
              icon: const Icon(Icons.add),
              label: const Text('Join a Trip'),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}

class _TripListTile extends StatelessWidget {
  final Trip trip;
  final Registration? registration;
  final VoidCallback onTap;

  const _TripListTile(
      {required this.trip, required this.registration, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reg = registration;
    final dateStr = DateFormat('dd MMM yyyy').format(trip.tripDate);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (reg == null) {
      statusColor = Colors.grey;
      statusLabel = 'Not Registered';
      statusIcon = Icons.edit_outlined;
    } else if (reg.isPaid) {
      statusColor = AppConfig.primaryGreen;
      statusLabel = 'Confirmed ✅';
      statusIcon = Icons.check_circle_rounded;
    } else if (reg.status == 'approved') {
      statusColor = Colors.blue;
      statusLabel = 'Pay Now 💳';
      statusIcon = Icons.payment_rounded;
    } else if (reg.status == 'rejected') {
      statusColor = AppConfig.errorRed;
      statusLabel = 'Rejected';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = Colors.orange;
      statusLabel = 'Pending ⏳';
      statusIcon = Icons.hourglass_empty_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: AppConfig.dividerColor),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
              child: trip.bannerImageUrl.isNotEmpty
                  ? Image.network(trip.bannerImageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.tripName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${trip.destination} • $dateStr',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppConfig.textGrey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppConfig.textLight),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: AppConfig.surfaceGreen,
      child: const Icon(Icons.tour_rounded,
          color: AppConfig.primaryGreen, size: 28),
    );
  }
}
