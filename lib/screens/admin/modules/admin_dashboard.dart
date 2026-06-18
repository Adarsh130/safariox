import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../services/trip_service.dart';
import 'create_trip_page.dart';
import 'student_list_page.dart';
import 'send_notification_page.dart';
import 'upload_gallery_page.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Dashboard',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Manage all trips and students',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 20),

          // Stats Row
          StreamBuilder<List<Trip>>(
            stream: TripService().getAllTrips(),
            builder: (context, tripSnap) {
              final trips = tripSnap.data ?? [];
              final activeTrips =
                  trips.where((t) => t.status == 'active').length;
              return Row(
                children: [
                  _statCard(context, 'Total Trips', '${trips.length}',
                      Icons.tour_rounded, AppConfig.primaryGreen),
                  const SizedBox(width: 12),
                  _statCard(context, 'Active', '$activeTrips',
                      Icons.event_available_rounded, Colors.blue),
                  const SizedBox(width: 12),
                  _statCard(context, 'Completed',
                      '${trips.where((t) => t.status == 'completed').length}',
                      Icons.check_circle_rounded, Colors.orange),
                ],
              );
            },
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _quickAction(context, Icons.add_circle_rounded, 'Create Trip',
                  AppConfig.primaryGreen, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTripPage()),
                );
              }),
              _quickAction(context, Icons.people_rounded, 'View Students',
                  Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentListPage()),
                );
              }),
              _quickAction(context, Icons.notifications_rounded,
                  'Send Notification', Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SendNotificationPage()),
                );
              }),
              _quickAction(context, Icons.photo_library_rounded,
                  'Upload Gallery', Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadGalleryPage()),
                );
              }),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // Recent Trips
          Text('All Trips', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          StreamBuilder<List<Trip>>(
            stream: TripService().getAllTrips(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppConfig.primaryGreen));
              }
              final trips = snap.data ?? [];
              if (trips.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConfig.surfaceGreen,
                    borderRadius:
                        BorderRadius.circular(AppConfig.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.tour_outlined,
                          color: AppConfig.primaryGreen, size: 36),
                      const SizedBox(height: 8),
                      Text('No trips created yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppConfig.textGrey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trips.length,
                itemBuilder: (ctx, i) {
                  final trip = trips[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConfig.radiusMedium),
                      border: Border.all(color: AppConfig.dividerColor),
                      boxShadow: AppConfig.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppConfig.surfaceGreen,
                            borderRadius:
                                BorderRadius.circular(AppConfig.radiusSmall),
                          ),
                          child: const Icon(Icons.tour_rounded,
                              color: AppConfig.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trip.tripName,
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                  '${trip.destination} • ${trip.availableSeats}/${trip.totalSeats} seats',
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppConfig.textGrey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: trip.status == 'active'
                                    ? AppConfig.surfaceGreen
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                trip.tripCode,
                                style: Theme.of(ctx)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: AppConfig.primaryGreen,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.status.toUpperCase(),
                              style: Theme.of(ctx)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: trip.status == 'active'
                                          ? AppConfig.primaryGreen
                                          : AppConfig.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: Duration(milliseconds: 300 + i * 60),
                          duration: 400.ms)
                      .slideX(begin: 0.1, end: 0);
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
                    ?.copyWith(color: AppConfig.textGrey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: color, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
