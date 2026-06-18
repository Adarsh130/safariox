import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../models/registration.dart';
import '../../../services/trip_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/registration_service.dart';

class PaymentReportPage extends StatefulWidget {
  const PaymentReportPage({super.key});

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  final _tripService = TripService();
  final _paymentService = PaymentService();
  final _regService = RegistrationService();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  double _totalCollected = 0;

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
          if (trips.isNotEmpty) _selectedTrip = trips.first;
        });
        if (trips.isNotEmpty) _loadTotal(trips.first.id);
      }
    });
  }

  Future<void> _loadTotal(String tripId) async {
    final total = await _paymentService.getTotalCollected(tripId);
    if (mounted) setState(() => _totalCollected = total);
  }

  Future<void> _markPaid(Registration reg) async {
    await _regService.updatePaymentStatus(reg.id, AppConfig.paymentPaid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Payment marked as paid'),
          backgroundColor: AppConfig.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
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
                onChanged: (t) {
                  setState(() => _selectedTrip = t);
                  if (t != null) _loadTotal(t.id);
                },
              ),
              if (_selectedTrip != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppConfig.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppConfig.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Collected',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8))),
                          Text(
                            '₹${_totalCollected.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _selectedTrip == null
              ? const Center(child: Text('Select a trip'))
              : StreamBuilder<List<Registration>>(
                  stream:
                      _regService.getTripRegistrations(_selectedTrip!.id),
                  builder: (context, snap) {
                    final regs = snap.data ?? [];
                    if (regs.isEmpty) {
                      return const Center(
                          child: Text('No registrations for this trip'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: regs.length,
                      itemBuilder: (ctx, i) {
                        final reg = regs[i];
                        final isPaid = reg.paymentStatus == 'paid';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppConfig.radiusMedium),
                            border: Border.all(
                                color: isPaid
                                    ? AppConfig.primaryGreen
                                        .withValues(alpha: 0.2)
                                    : AppConfig.dividerColor),
                            boxShadow: AppConfig.cardShadow,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isPaid
                                    ? AppConfig.surfaceGreen
                                    : Colors.orange.withValues(alpha: 0.1),
                                child: Icon(
                                  isPaid
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  color: isPaid
                                      ? AppConfig.primaryGreen
                                      : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(reg.fullName,
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w700)),
                                    Text(
                                        'Class ${reg.className}-${reg.section}  •  ${reg.studentMobile}',
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppConfig.textGrey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${_selectedTrip!.pricePerStudent.toStringAsFixed(0)}',
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isPaid
                                                ? AppConfig.primaryGreen
                                                : AppConfig.textDark),
                                  ),
                                  if (!isPaid && reg.status == 'approved')
                                    TextButton(
                                      onPressed: () => _markPaid(reg),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        foregroundColor:
                                            AppConfig.primaryGreen,
                                      ),
                                      child: const Text('Mark Paid',
                                          style:
                                              TextStyle(fontSize: 11)),
                                    ),
                                  if (isPaid)
                                    Text('PAID',
                                        style: TextStyle(
                                            color: AppConfig.primaryGreen,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                                delay:
                                    Duration(milliseconds: 60 * i),
                                duration: 400.ms);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
