import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/registration.dart';
import '../../models/trip.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';

class CertificatePage extends StatefulWidget {
  final Registration registration;
  final Trip trip;

  const CertificatePage(
      {super.key, required this.registration, required this.trip});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final _certService = CertificateService();
  Certificate? _certificate;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadCertificate();
  }

  Future<void> _loadCertificate() async {
    final cert =
        await _certService.getCertificate(widget.registration.id);
    if (mounted) {
      setState(() {
        _certificate = cert;
        _loading = false;
      });
    }
  }

  Future<void> _generateAndDownload() async {
    setState(() => _generating = true);
    try {
      final cert = await _certService.generateCertificate(
        registration: widget.registration,
        trip: widget.trip,
      );
      setState(() => _certificate = cert);
      await _certService.printOrShare(cert);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating certificate: $e')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participation Certificate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppConfig.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Certificate Preview Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConfig.radiusLarge),
                      border: Border.all(
                          color: AppConfig.primaryGreen, width: 3),
                      boxShadow: AppConfig.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: AppConfig.darkGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppConfig.radiusLarge - 3),
                              topRight:
                                  Radius.circular(AppConfig.radiusLarge - 3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: Image.asset('assets/logo.jpeg',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('SAFARIOX INDIA',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(AppConfig.appTagline,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.75))),
                            ],
                          ),
                        ),

                        // Body
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  color: AppConfig.accentGold, size: 48),
                              const SizedBox(height: 16),
                              Text('CERTIFICATE OF PARTICIPATION',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          letterSpacing: 1.5,
                                          color: AppConfig.textGrey)),
                              const SizedBox(height: 16),
                              Text('This is to certify that',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppConfig.textGrey)),
                              const SizedBox(height: 6),
                              Text(
                                widget.registration.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                        color: AppConfig.primaryGreen,
                                        fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'from ${widget.trip.instituteName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppConfig.textGrey),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'has successfully participated in the educational tour',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${widget.trip.tripName}"',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: AppConfig.primaryGreen,
                                        fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'to ${widget.trip.destination}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppConfig.textGrey),
                              ),
                              Text(
                                DateFormat('dd MMMM, yyyy')
                                    .format(widget.trip.tripDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppConfig.textGrey),
                              ),
                            ],
                          ),
                        ),

                        // Footer
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppConfig.surfaceGreen,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  AppConfig.radiusLarge - 3),
                              bottomRight: Radius.circular(
                                  AppConfig.radiusLarge - 3),
                            ),
                          ),
                          child: _certificate != null
                              ? Column(
                                  children: [
                                    Text('Pass ID',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                                color: AppConfig.textGrey)),
                                    Text(
                                      _certificate!.passId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: AppConfig.primaryGreen,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Generate your certificate below',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppConfig.textGrey),
                                ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _generating ? null : _generateAndDownload,
                      icon: _generating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.download_rounded),
                      label: Text(_certificate == null
                          ? 'Generate & Download PDF'
                          : 'Download Certificate PDF'),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  if (widget.trip.status != 'completed') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppConfig.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The certificate will be officially available after the trip is completed.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ],
                ],
              ),
            ),
    );
  }
}
