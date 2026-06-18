import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../services/trip_service.dart';
import '../../../services/gallery_service.dart';

class CreateTripPage extends StatefulWidget {
  final Trip? tripToEdit;

  const CreateTripPage({super.key, this.tripToEdit});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();
  final _galleryService = GalleryService();

  // Controllers
  final _tripNameCtrl = TextEditingController();
  final _instituteCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _reportingTimeCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _busDetailsCtrl = TextEditingController();
  final _tourManagerNameCtrl = TextEditingController();
  final _tourManagerCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _googlePhotosCtrl = TextEditingController();

  DateTime? _tripDate;
  DateTime? _deadline;
  File? _bannerImage;
  bool _isSubmitting = false;

  Future<void> _pickDate(bool isTripDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppConfig.primaryGreen,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isTripDate) {
          _tripDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  Future<void> _pickBanner() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _bannerImage = File(img.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tripDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trip date')));
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a registration deadline')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Upload banner if selected
      String bannerUrl = '';
      if (_bannerImage != null) {
        bannerUrl = await _galleryService.uploadPhoto('trip_banners', _bannerImage!);
      }

      final trip = Trip(
        id: '',
        tripName: _tripNameCtrl.text.trim(),
        instituteName: _instituteCtrl.text.trim(),
        destination: _destinationCtrl.text.trim(),
        tripDate: _tripDate!,
        registrationDeadline: _deadline!,
        pricePerStudent: double.tryParse(_priceCtrl.text) ?? 0,
        totalSeats: int.tryParse(_seatsCtrl.text) ?? 0,
        availableSeats: int.tryParse(_seatsCtrl.text) ?? 0,
        bannerImageUrl: bannerUrl,
        instructions: _instructionsCtrl.text.trim(),
        tripCode: '',
        schedule: _scheduleCtrl.text.trim(),
        reportingTime: _reportingTimeCtrl.text.trim(),
        pickupPoint: _pickupCtrl.text.trim(),
        busDetails: _busDetailsCtrl.text.trim(),
        tourManagerName: _tourManagerNameCtrl.text.trim(),
        tourManagerContact: _tourManagerCtrl.text.trim(),
        emergencyContactName: _emergencyNameCtrl.text.trim(),
        emergencyContact: _emergencyCtrl.text.trim(),
        googlePhotosLink: _googlePhotosCtrl.text.trim(),
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? 'admin',
      );

      await _tripService.createTrip(trip);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip created successfully!'),
          backgroundColor: AppConfig.primaryGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _tripNameCtrl.dispose();
    _instituteCtrl.dispose();
    _destinationCtrl.dispose();
    _priceCtrl.dispose();
    _seatsCtrl.dispose();
    _instructionsCtrl.dispose();
    _scheduleCtrl.dispose();
    _reportingTimeCtrl.dispose();
    _pickupCtrl.dispose();
    _busDetailsCtrl.dispose();
    _tourManagerNameCtrl.dispose();
    _tourManagerCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyCtrl.dispose();
    _googlePhotosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Create New Trip',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Fill in the trip details below',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConfig.textGrey)),
          const SizedBox(height: 20),

          // Banner Upload
          GestureDetector(
            onTap: _pickBanner,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppConfig.surfaceGreen,
                borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
                border: Border.all(
                    color: AppConfig.primaryGreen.withValues(alpha: 0.3),
                    style: BorderStyle.solid),
                image: _bannerImage != null
                    ? DecorationImage(
                        image: FileImage(_bannerImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _bannerImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded,
                            color: AppConfig.primaryGreen, size: 36),
                        const SizedBox(height: 8),
                        Text('Tap to upload banner image',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppConfig.primaryGreen)),
                      ],
                    )
                  : null,
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),
          _sectionHeader('Basic Info'),
          const SizedBox(height: 12),

          _field(_tripNameCtrl, 'Trip Name', Icons.tour_rounded,
              required: true),
          const SizedBox(height: 12),
          _field(_instituteCtrl, 'Institute Name', Icons.school_rounded,
              required: true),
          const SizedBox(height: 12),
          _field(_destinationCtrl, 'Destination', Icons.location_on_rounded,
              required: true),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _field(_priceCtrl, 'Price (₹)',
                    Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number, required: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                    _seatsCtrl, 'Total Seats', Icons.event_seat_rounded,
                    keyboardType: TextInputType.number, required: true),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Pickers
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(true),
                  child: _dateField(context, 'Trip Date', _tripDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(false),
                  child: _dateField(context, 'Reg. Deadline', _deadline),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionHeader('Trip Details'),
          const SizedBox(height: 12),

          _field(_reportingTimeCtrl, 'Reporting Time',
              Icons.access_time_rounded,
              hint: 'e.g. 6:00 AM at School Gate'),
          const SizedBox(height: 12),
          _field(_pickupCtrl, 'Pickup Point', Icons.location_on_rounded,
              hint: 'Pickup location address'),
          const SizedBox(height: 12),
          _field(_busDetailsCtrl, 'Bus Details', Icons.directions_bus_rounded,
              hint: 'Bus number, capacity, driver name'),
          const SizedBox(height: 12),
          _field(_scheduleCtrl, 'Schedule / Itinerary',
              Icons.event_note_rounded,
              maxLines: 4,
              hint: 'Day 1: ...\nDay 2: ...'),
          const SizedBox(height: 12),
          _field(_instructionsCtrl, 'Instructions',
              Icons.rule_rounded,
              maxLines: 3,
              hint: 'What to bring, dress code, etc.'),

          const SizedBox(height: 20),
          _sectionHeader('Contacts'),
          const SizedBox(height: 12),

          _field(_tourManagerNameCtrl, 'Tour Manager Name',
              Icons.person_rounded),
          const SizedBox(height: 12),
          _field(_tourManagerCtrl, 'Tour Manager Phone',
              Icons.phone_rounded,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _field(_emergencyNameCtrl, 'Emergency Contact Name',
              Icons.emergency_rounded),
          const SizedBox(height: 12),
          _field(_emergencyCtrl, 'Emergency Phone',
              Icons.phone_in_talk_rounded,
              keyboardType: TextInputType.phone),

          const SizedBox(height: 20),
          _sectionHeader('Gallery'),
          const SizedBox(height: 12),
          _field(_googlePhotosCtrl, 'Google Photos Album Link',
              Icons.photo_album_rounded,
              hint: 'https://photos.google.com/...'),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_rounded),
              label: const Text('Create Trip',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: AppConfig.primaryGreen,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
          : null,
    );
  }

  Widget _dateField(BuildContext context, String label, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: AppConfig.dividerColor, width: 1.5),
        borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppConfig.textGrey, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        date != null ? AppConfig.textDark : AppConfig.textLight,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
