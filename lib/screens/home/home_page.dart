import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import '../../services/user_service.dart';
import '../trips/join_trip_page.dart';
import '../trips/trip_detail_page.dart';
import '../notifications/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TripService _tripService = TripService();
  final UserService _userService = UserService();
  List<Trip> _myTrips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyTrips();
  }

  Future<void> _loadMyTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final appUser = await _userService.getUser(user.uid);
      if (appUser == null || appUser.joinedTrips.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final trips = await _tripService.getTripsByIds(appUser.joinedTrips);
      setState(() {
        _myTrips = trips;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: AppConfig.bgWhite,
      body: RefreshIndicator(
        color: AppConfig.primaryGreen,
        onRefresh: _loadMyTrips,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppConfig.darkGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.75))),
                              Text(userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsPage()),
                          ),
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),
                    // Join Trip Banner
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const JoinTripPage()),
                      ).then((_) => _loadMyTrips()),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppConfig.radiusMedium),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppConfig.radiusSmall),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Join a Trip',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                  Text('Enter trip code to join your class trip',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.75))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppConfig.primaryGreen, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  children: [
                    _statCard('My Trips', '${_myTrips.length}',
                        Icons.tour_rounded, AppConfig.primaryGreen),
                    const SizedBox(width: 12),
                    _statCard('Upcoming', _myTrips.where((t) => t.tripDate.isAfter(DateTime.now())).length.toString(),
                        Icons.event_rounded, Colors.orange),
                    const SizedBox(width: 12),
                    _statCard('Completed', _myTrips.where((t) => t.status == 'completed').length.toString(),
                        Icons.check_circle_rounded, Colors.blue),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Trips',
                        style: Theme.of(context).textTheme.headlineSmall),
                    if (_myTrips.isNotEmpty)
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            ),

            // Trips List
            _loading
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppConfig.primaryGreen)),
                    ),
                  )
                : _myTrips.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final trip = _myTrips[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: _TripCard(
                                trip: trip,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TripDetailPage(trip: trip),
                                  ),
                                ).then((_) => _loadMyTrips()),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    delay: Duration(milliseconds: 400 + index * 80),
                                    duration: 400.ms)
                                .slideY(begin: 0.2, end: 0);
                          },
                          childCount: _myTrips.length,
                        ),
                      ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppConfig.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppConfig.surfaceGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_outlined,
                color: AppConfig.primaryGreen, size: 48),
          ),
          const SizedBox(height: 16),
          Text('No Trips Yet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Ask your teacher for a trip code and tap "Join a Trip" to get started!',
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
            ).then((_) => _loadMyTrips()),
            icon: const Icon(Icons.add),
            label: const Text('Join a Trip'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, yyyy').format(trip.tripDate);
    final isUpcoming = trip.tripDate.isAfter(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConfig.radiusMedium),
                topRight: Radius.circular(AppConfig.radiusMedium),
              ),
              child: trip.bannerImageUrl.isNotEmpty
                  ? Image.network(
                      trip.bannerImageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _placeholderBanner(),
                    )
                  : _placeholderBanner(),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(trip.tripName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? AppConfig.surfaceGreen
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUpcoming ? 'Upcoming' : trip.status.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isUpcoming
                                    ? AppConfig.primaryGreen
                                    : AppConfig.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppConfig.textGrey),
                      const SizedBox(width: 4),
                      Text(trip.destination,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppConfig.textGrey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: AppConfig.textGrey),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppConfig.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConfig.surfaceGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Code: ${trip.tripCode}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppConfig.primaryGreen,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                      Text(
                        '₹${trip.pricePerStudent.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppConfig.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppConfig.primaryGradient),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tour_rounded, color: Colors.white54, size: 40),
          SizedBox(height: 8),
          Text('Educational Tour', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
