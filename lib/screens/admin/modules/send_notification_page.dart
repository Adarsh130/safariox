import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../models/notification_model.dart';
import '../../../services/trip_service.dart';
import '../../../services/notification_service.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _tripService = TripService();
  final _notifService = NotificationService();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  String _selectedType = 'instruction';
  bool _isSending = false;

  static const _types = [
    {'key': 'instruction', 'label': '📢 Announcement', 'color': AppConfig.primaryGreen},
    {'key': 'reporting_time', 'label': '🕐 Reporting Time', 'color': Colors.orange},
    {'key': 'bus_update', 'label': '🚌 Bus Update', 'color': Colors.blue},
    {'key': 'emergency', 'label': '🚨 Emergency', 'color': AppConfig.errorRed},
  ];

  @override
  void initState() {
    super.initState();
    _tripService.getAllTrips().first.then((trips) {
      if (mounted) {
        setState(() {
          _trips = trips;
          if (trips.isNotEmpty) _selectedTrip = trips.first;
        });
      }
    });
  }

  Future<void> _send() async {
    if (_selectedTrip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trip')));
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required')));
      return;
    }
    setState(() => _isSending = true);
    try {
      final notif = NotificationModel(
        id: '',
        tripId: _selectedTrip!.id,
        title: _titleCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
        type: _selectedType,
        sentBy: FirebaseAuth.instance.currentUser?.uid ?? 'admin',
      );
      await _notifService.sendNotification(notif);
      if (!mounted) return;
      _titleCtrl.clear();
      _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent to all students!'),
          backgroundColor: AppConfig.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Notification',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Broadcast to all registered students of a trip',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 20),

          DropdownButtonFormField<Trip>(
            initialValue: _selectedTrip,
            decoration: const InputDecoration(
              labelText: 'Select Trip',
              prefixIcon: Icon(Icons.tour_rounded),
            ),
            items: _trips
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.tripName} [${t.tripCode}]',
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (t) => setState(() => _selectedTrip = t),
          ),
          const SizedBox(height: 16),

          Text('Notification Type',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((type) {
              final isSelected = _selectedType == type['key'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedType = type['key'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withValues(alpha: 0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (type['color'] as Color)
                          : AppConfig.dividerColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? (type['color'] as Color)
                          : AppConfig.textGrey,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Notification Title',
              prefixIcon: Icon(Icons.title_rounded),
              hintText: 'e.g. Reporting Time Updated',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message',
              prefixIcon: Icon(Icons.message_rounded),
              hintText: 'Enter the full notification message here...',
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _send,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: const Text('Send Notification',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
