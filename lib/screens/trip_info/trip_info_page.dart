import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';

class TripInfoPage extends StatelessWidget {
  final Trip trip;

  const TripInfoPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Trip Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppConfig.primaryGradient,
              borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.tripName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white)),
                      Text(trip.destination,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          if (trip.reportingTime.isNotEmpty)
            _InfoCard(
              icon: Icons.access_time_rounded,
              color: Colors.orange,
              title: 'Reporting Time',
              content: trip.reportingTime,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          if (trip.pickupPoint.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.location_on_rounded,
              color: Colors.red,
              title: 'Pickup Point',
              content: trip.pickupPoint,
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          ],

          if (trip.busDetails.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.directions_bus_rounded,
              color: Colors.blue,
              title: 'Bus Details',
              content: trip.busDetails,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],

          if (trip.schedule.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.event_note_rounded,
              color: AppConfig.primaryGreen,
              title: 'Trip Schedule',
              content: trip.schedule,
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
          ],

          if (trip.instructions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.rule_rounded,
              color: Colors.purple,
              title: 'Instructions',
              content: trip.instructions,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ],

          const SizedBox(height: 20),

          if (trip.tourManagerContact.isNotEmpty ||
              trip.emergencyContact.isNotEmpty) ...[
            Text('Contact Numbers',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
          ],

          if (trip.tourManagerContact.isNotEmpty)
            _ContactCard(
              icon: Icons.person_pin_rounded,
              color: AppConfig.primaryGreen,
              label: 'Tour Manager',
              name: trip.tourManagerName.isNotEmpty
                  ? trip.tourManagerName
                  : 'Tour Manager',
              phone: trip.tourManagerContact,
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

          if (trip.emergencyContact.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.emergency_rounded,
              color: AppConfig.errorRed,
              label: 'Emergency Contact',
              name: trip.emergencyContactName.isNotEmpty
                  ? trip.emergencyContactName
                  : 'Emergency',
              phone: trip.emergencyContact,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],

          if (trip.reportingTime.isEmpty &&
              trip.pickupPoint.isEmpty &&
              trip.busDetails.isEmpty &&
              trip.schedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppConfig.textLight, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'Trip details will be updated by the admin before the trip date.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppConfig.textGrey),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;

  const _InfoCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: AppConfig.dividerColor),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppConfig.textGrey)),
                const SizedBox(height: 4),
                Text(content,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppConfig.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final String phone;

  const _ContactCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.name,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppConfig.textGrey)),
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(phone,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppConfig.textGrey)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final url = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                },
                icon: Icon(Icons.call_rounded, color: AppConfig.primaryGreen),
                style: IconButton.styleFrom(
                  backgroundColor: AppConfig.surfaceGreen,
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () async {
                  final url = Uri.parse('sms:$phone');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                },
                icon: const Icon(Icons.message_rounded, color: Colors.blue),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
