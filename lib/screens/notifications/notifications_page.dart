import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notifService = NotificationService();
  final _userService = UserService();
  List<String> _joinedTripIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTripIds();
  }

  Future<void> _loadTripIds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final appUser = await _userService.getUser(user.uid);
    if (mounted) {
      setState(() {
        _joinedTripIds = appUser?.joinedTrips ?? [];
        _loading = false;
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'reporting_time':
        return Colors.orange;
      case 'bus_update':
        return Colors.blue;
      case 'emergency':
        return AppConfig.errorRed;
      default:
        return AppConfig.primaryGreen;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'reporting_time':
        return 'Reporting Time';
      case 'bus_update':
        return 'Bus Update';
      case 'emergency':
        return 'Emergency';
      default:
        return 'Announcement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppConfig.primaryGreen))
          : _joinedTripIds.isEmpty
              ? _buildEmptyState()
              : StreamBuilder<List<NotificationModel>>(
                  stream: _notifService
                      .getNotificationsForTrips(_joinedTripIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppConfig.primaryGreen),
                      );
                    }
                    final notifications = snapshot.data ?? [];
                    if (notifications.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final color = _getTypeColor(n.type);
                        final timeStr = n.sentAt != null
                            ? DateFormat('dd MMM • h:mm a').format(n.sentAt!)
                            : '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppConfig.radiusMedium),
                            border: Border.all(
                                color: color.withValues(alpha: 0.2)),
                            boxShadow: AppConfig.cardShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(n.typeIcon,
                                      style:
                                          const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getTypeName(n.type),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: color),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(timeStr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: AppConfig
                                                        .textLight)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(n.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(n.message,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppConfig.textGrey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(
                                    milliseconds: 80 * index),
                                duration: 400.ms)
                            .slideX(begin: 0.2, end: 0);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: AppConfig.surfaceGreen, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppConfig.primaryGreen, size: 40),
            ),
            const SizedBox(height: 16),
            Text('No Notifications',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Notifications from your trips will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConfig.textGrey),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}
