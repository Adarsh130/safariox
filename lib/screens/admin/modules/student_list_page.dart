import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../models/registration.dart';
import '../../../services/trip_service.dart';
import '../../../services/registration_service.dart';

class StudentListPage extends StatefulWidget {
  final String? preselectedTripId;

  const StudentListPage({super.key, this.preselectedTripId});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage>
    with SingleTickerProviderStateMixin {
  final _tripService = TripService();
  final _regService = RegistrationService();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    _tripService.getAllTrips().first.then((trips) {
      if (mounted) {
        setState(() {
          _trips = trips;
          if (widget.preselectedTripId != null) {
            _selectedTrip = trips.firstWhere(
                (t) => t.id == widget.preselectedTripId,
                orElse: () => trips.first);
          } else if (trips.isNotEmpty) {
            _selectedTrip = trips.first;
          }
        });
      }
    });
  }

  Future<void> _updateStatus(Registration reg, String status) async {
    String note = '';
    if (status == 'rejected') {
      final ctrl = TextEditingController();
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rejection Reason'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
                hintText: 'Optional note for student'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip')),
            ElevatedButton(
                onPressed: () {
                  note = ctrl.text;
                  Navigator.pop(context);
                },
                child: const Text('Confirm')),
          ],
        ),
      );
    }
    await _regService.updateRegistrationStatus(reg.id, status,
        adminNote: note);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Student ${status == 'approved' ? 'approved' : 'rejected'}'),
        backgroundColor: status == 'approved'
            ? AppConfig.primaryGreen
            : AppConfig.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trip Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: DropdownButtonFormField<Trip>(
            initialValue: _selectedTrip,
            decoration: const InputDecoration(
              labelText: 'Select Trip',
              prefixIcon: Icon(Icons.tour_rounded),
            ),
            items: _trips
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        '${t.tripName} [${t.tripCode}]',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (t) => setState(() => _selectedTrip = t),
          ),
        ),

        // Filter Chips
        if (_selectedTrip != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppConfig.bgWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'pending', 'approved', 'rejected'].map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.toUpperCase()),
                      selected: _filterStatus == s,
                      onSelected: (_) =>
                          setState(() => _filterStatus = s),
                      backgroundColor: Colors.white,
                      selectedColor: AppConfig.surfaceGreen,
                      checkmarkColor: AppConfig.primaryGreen,
                      labelStyle: TextStyle(
                        color: _filterStatus == s
                            ? AppConfig.primaryGreen
                            : AppConfig.textGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Student List
        Expanded(
          child: _selectedTrip == null
              ? const Center(child: Text('Select a trip to view students'))
              : StreamBuilder<List<Registration>>(
                  stream:
                      _regService.getTripRegistrations(_selectedTrip!.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppConfig.primaryGreen));
                    }
                    var regs = snap.data ?? [];
                    if (_filterStatus != 'all') {
                      regs = regs
                          .where((r) => r.status == _filterStatus)
                          .toList();
                    }
                    if (regs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded,
                                color: AppConfig.textLight, size: 56),
                            const SizedBox(height: 12),
                            Text(
                              _filterStatus == 'all'
                                  ? 'No registrations yet'
                                  : 'No $_filterStatus registrations',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: AppConfig.textGrey),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: regs.length,
                      itemBuilder: (ctx, i) {
                        final reg = regs[i];
                        return _StudentCard(
                          registration: reg,
                          onApprove: () =>
                              _updateStatus(reg, 'approved'),
                          onReject: () =>
                              _updateStatus(reg, 'rejected'),
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: 60 * i),
                                duration: 400.ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Registration registration;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _StudentCard(
      {required this.registration,
      required this.onApprove,
      required this.onReject});

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return AppConfig.primaryGreen;
      case 'rejected':
        return AppConfig.errorRed;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reg = registration;
    final color = _statusColor(reg.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppConfig.surfaceGreen,
                backgroundImage: reg.photoUrl.isNotEmpty
                    ? NetworkImage(reg.photoUrl)
                    : null,
                child: reg.photoUrl.isEmpty
                    ? Text(
                        reg.fullName.isNotEmpty
                            ? reg.fullName[0].toUpperCase()
                            : 'S',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppConfig.primaryGreen),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reg.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                        'Class ${reg.className}-${reg.section}  •  Roll: ${reg.rollNumber}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppConfig.textGrey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  reg.status.toUpperCase(),
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _detail(context, '📞', reg.studentMobile),
              const SizedBox(width: 12),
              _detail(context, '👨‍👩‍👧', reg.parentMobile),
              const SizedBox(width: 12),
              _detail(context, '💳',
                  reg.paymentStatus == 'paid' ? 'Paid' : 'Pending'),
            ],
          ),
          if (reg.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConfig.errorRed,
                      side: const BorderSide(color: AppConfig.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (reg.adminNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Admin Note: ${reg.adminNote}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppConfig.errorRed)),
          ],
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppConfig.textGrey)),
      ],
    );
  }
}
