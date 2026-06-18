import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/registration.dart';

class TripPassPage extends StatelessWidget {
  final Registration registration;
  final Trip trip;

  const TripPassPage(
      {super.key, required this.registration, required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(trip.tripDate);
    final qrData =
        'SAFARIOX|PASS:${registration.passId}|USER:${registration.userId}|TRIP:${trip.tripCode}';

    return Scaffold(
      backgroundColor: AppConfig.bgWhite,
      appBar: AppBar(
        title: const Text('My Trip Pass'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                  'My SafariOX India Trip Pass\nTrip: ${trip.tripName}\nStudent: ${registration.fullName}\nPass ID: ${registration.passId}\nCode: ${trip.tripCode}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Pass Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConfig.radiusLarge),
                boxShadow: AppConfig.elevatedShadow,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: AppConfig.darkGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppConfig.radiusLarge),
                        topRight: Radius.circular(AppConfig.radiusLarge),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset('assets/logo.jpeg',
                                    fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SafariOX India',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                Text('Digital Trip Pass',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('✅ VALID',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(trip.tripName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text('${trip.destination} • $dateStr',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),

                  // Dashed divider
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppConfig.bgWhite,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: CustomPaint(
                              painter: _DashedLinePainter(),
                              child: const SizedBox(height: 1),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppConfig.bgWhite,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Student Photo
                              if (registration.photoUrl.isNotEmpty)
                                CircleAvatar(
                                  radius: 36,
                                  backgroundImage:
                                      NetworkImage(registration.photoUrl),
                                )
                              else
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppConfig.surfaceGreen,
                                  child: Text(
                                    registration.fullName.isNotEmpty
                                        ? registration.fullName[0]
                                            .toUpperCase()
                                        : 'S',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                            color: AppConfig.primaryGreen),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              _passField(context, 'NAME',
                                  registration.fullName),
                              const SizedBox(height: 8),
                              _passField(context, 'INSTITUTE',
                                  trip.instituteName),
                              const SizedBox(height: 8),
                              _passField(context, 'CLASS',
                                  '${registration.className}-${registration.section}  Roll: ${registration.rollNumber}'),
                              const SizedBox(height: 8),
                              _passField(context, 'TRIP CODE', trip.tripCode),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // QR Code
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppConfig.radiusSmall),
                                border: Border.all(
                                    color: AppConfig.dividerColor),
                              ),
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 100,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Scan to verify',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppConfig.textGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Pass ID Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppConfig.surfaceGreen,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppConfig.radiusLarge),
                        bottomRight: Radius.circular(AppConfig.radiusLarge),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('PASS ID',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppConfig.textGrey)),
                        const SizedBox(height: 2),
                        Text(
                          registration.passId.isNotEmpty
                              ? registration.passId
                              : 'Generating...',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppConfig.primaryGreen,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 20),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
                border:
                    Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Text('Important',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.orange.shade800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _bulletPoint(context,
                      'Carry this pass on the day of the trip'),
                  _bulletPoint(context,
                      'This pass will be verified at the departure point'),
                  _bulletPoint(context,
                      'Keep the Pass ID safe — it is your unique identifier'),
                  _bulletPoint(context,
                      'Do not share your pass with others'),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _passField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppConfig.textGrey, letterSpacing: 1)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _bulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppConfig.textDark)),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConfig.dividerColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}
