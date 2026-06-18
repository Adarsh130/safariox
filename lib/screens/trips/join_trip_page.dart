import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import 'trip_detail_page.dart';

class JoinTripPage extends StatefulWidget {
  const JoinTripPage({super.key});

  @override
  State<JoinTripPage> createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  final _codeController = TextEditingController();
  final _tripService = TripService();
  Trip? _foundTrip;
  bool _isSearching = false;
  String? _errorMessage;

  Future<void> _searchTrip() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-character trip code');
      return;
    }
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _foundTrip = null;
    });
    try {
      final trip = await _tripService.getTripByCode(code);
      setState(() {
        _foundTrip = trip;
        _errorMessage = trip == null ? 'No trip found with this code. Please check and try again.' : null;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Error searching trip. Please try again.';
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Trip'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppConfig.primaryGradient,
                borderRadius: BorderRadius.circular(AppConfig.radiusLarge),
              ),
              child: Column(
                children: [
                  const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 56),
                  const SizedBox(height: 12),
                  Text('Enter Trip Code',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    'Get the 6-character code from your teacher or institute',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 28),

            Text('Trip Code',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: AppConfig.textGrey)),
            const SizedBox(height: 8),

            // Code input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          letterSpacing: 6,
                          fontWeight: FontWeight.w700,
                          color: AppConfig.primaryGreen,
                        ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'XXXXXX',
                      hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            letterSpacing: 6,
                            color: AppConfig.textLight,
                          ),
                      counterText: '',
                      errorText: _errorMessage,
                    ),
                    onChanged: (_) => setState(() {
                      _errorMessage = null;
                      _foundTrip = null;
                    }),
                    onSubmitted: (_) => _searchTrip(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchTrip,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // Found Trip Preview
            if (_foundTrip != null) ...[
              const SizedBox(height: 24),
              _TripPreviewCard(trip: _foundTrip!),
            ],
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _TripPreviewCard extends StatelessWidget {
  final Trip trip;

  const _TripPreviewCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final canJoin = trip.isRegistrationOpen && trip.hasSeatsAvailable;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        border: Border.all(
            color: AppConfig.primaryGreen.withValues(alpha: 0.4), width: 1.5),
        boxShadow: AppConfig.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.surfaceGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConfig.radiusMedium),
                topRight: Radius.circular(AppConfig.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppConfig.primaryGreen),
                const SizedBox(width: 8),
                Text('Trip Found!',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppConfig.primaryGreen)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.tripName,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(trip.instituteName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppConfig.textGrey)),
                const SizedBox(height: 12),
                _infoRow(context, Icons.location_on_rounded, trip.destination),
                const SizedBox(height: 6),
                _infoRow(
                    context,
                    Icons.calendar_today_rounded,
                    'Trip Date: ${trip.tripDate.day}/${trip.tripDate.month}/${trip.tripDate.year}'),
                const SizedBox(height: 6),
                _infoRow(context, Icons.event_busy_rounded,
                    'Deadline: ${trip.registrationDeadline.day}/${trip.registrationDeadline.month}/${trip.registrationDeadline.year}'),
                const SizedBox(height: 6),
                _infoRow(context, Icons.people_rounded,
                    '${trip.availableSeats} seats available'),
                const SizedBox(height: 6),
                _infoRow(context, Icons.currency_rupee_rounded,
                    '₹${trip.pricePerStudent.toStringAsFixed(0)} per student'),
                const SizedBox(height: 16),
                if (!canJoin)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConfig.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_rounded,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.hasSeatsAvailable
                                ? 'Registration deadline has passed'
                                : 'No seats available',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (canJoin) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TripDetailPage(trip: trip)),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('View Trip & Register'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConfig.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textDark)),
        ),
      ],
    );
  }
}
