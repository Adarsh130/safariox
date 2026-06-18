import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../models/certificate.dart';
import '../../../services/trip_service.dart';
import '../../../services/registration_service.dart';
import '../../../services/certificate_service.dart';

class GenerateReportsPage extends StatefulWidget {
  const GenerateReportsPage({super.key});

  @override
  State<GenerateReportsPage> createState() => _GenerateReportsPageState();
}

class _GenerateReportsPageState extends State<GenerateReportsPage> {
  final _tripService = TripService();
  final _regService = RegistrationService();
  final _certService = CertificateService();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  bool _isGenerating = false;

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

  Future<void> _markTripComplete() async {
    if (_selectedTrip == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark Trip as Completed'),
        content: Text(
            'This will mark "${_selectedTrip!.tripName}" as completed and allow certificate generation. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _tripService.updateTripStatus(_selectedTrip!.id, 'completed');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Trip marked as completed!'),
          backgroundColor: AppConfig.primaryGreen),
    );
    // Refresh
    _tripService.getAllTrips().first.then((trips) {
      if (mounted) {
        setState(() {
          _trips = trips;
          _selectedTrip =
              trips.firstWhere((t) => t.id == _selectedTrip!.id);
        });
      }
    });
  }

  Future<void> _generateAllCertificates() async {
    if (_selectedTrip == null) return;
    setState(() => _isGenerating = true);
    try {
      final regs = await _regService.getTripRegistrationsList(_selectedTrip!.id);
      final paidRegs = regs.where((r) => r.isPaid).toList();
      if (paidRegs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No paid registrations found')));
        return;
      }
      int count = 0;
      for (final reg in paidRegs) {
        await _certService.generateCertificate(
          registration: reg,
          trip: _selectedTrip!,
        );
        count++;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated $count certificates!'),
          backgroundColor: AppConfig.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _selectedTrip?.status == 'completed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports & Certificates',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Manage trip completion and certificates',
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
          const SizedBox(height: 20),

          // Status Banner
          if (_selectedTrip != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppConfig.surfaceGreen
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
                border: Border.all(
                  color: isCompleted
                      ? AppConfig.primaryGreen.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.event_rounded,
                    color:
                        isCompleted ? AppConfig.primaryGreen : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'Trip Completed — Certificates Available'
                          : 'Trip is ${_selectedTrip!.status.toUpperCase()} — Mark as completed to issue certificates',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isCompleted
                                ? AppConfig.primaryGreen
                                : Colors.orange.shade800,
                          ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Actions
          _actionCard(
            context,
            icon: Icons.check_circle_rounded,
            color: isCompleted ? AppConfig.textGrey : AppConfig.primaryGreen,
            title: 'Mark Trip as Completed',
            subtitle: 'Enables certificate generation for all paid students',
            buttonLabel: isCompleted ? 'Already Completed' : 'Mark Complete',
            onPressed: isCompleted ? null : _markTripComplete,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 12),

          _actionCard(
            context,
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber.shade700,
            title: 'Generate All Certificates',
            subtitle:
                'Generate participation certificates for all paid students',
            buttonLabel: _isGenerating ? 'Generating...' : 'Generate Certificates',
            onPressed: (!isCompleted || _isGenerating) ? null : _generateAllCertificates,
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: 12),

          _actionCard(
            context,
            icon: Icons.table_chart_rounded,
            color: Colors.blue,
            title: 'Export Student Data',
            subtitle: 'Coming soon — Export to Excel/CSV',
            buttonLabel: 'Coming Soon',
            onPressed: null,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          // Certificates list
          if (isCompleted && _selectedTrip != null) ...[
            const SizedBox(height: 20),
            Text('Generated Certificates',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            StreamBuilder<List<Certificate>>(
              stream: _certService.getTripCertificates(_selectedTrip!.id),
              builder: (ctx, snap) {
                final certs = snap.data ?? [];
                if (certs.isEmpty) {
                  return Center(
                    child: Text('No certificates generated yet',
                        style: Theme.of(ctx)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppConfig.textGrey)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: certs.length,
                  itemBuilder: (_, i) {
                    final cert = certs[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppConfig.radiusMedium),
                        border: Border.all(color: AppConfig.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: AppConfig.accentGold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(cert.studentName,
                                style: Theme.of(ctx).textTheme.titleSmall),
                          ),
                          Text(cert.passId,
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppConfig.primaryGreen,
                                      fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(color: AppConfig.dividerColor),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppConfig.textGrey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed != null ? color : Colors.grey.shade300,
              foregroundColor: onPressed != null ? Colors.white : AppConfig.textGrey,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
