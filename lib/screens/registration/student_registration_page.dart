import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/registration.dart';
import '../../services/registration_service.dart';
import '../../services/trip_service.dart';
import '../../services/gallery_service.dart';

class StudentRegistrationPage extends StatefulWidget {
  final Trip trip;

  const StudentRegistrationPage({super.key, required this.trip});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _studentMobileCtrl = TextEditingController();
  final _parentMobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _regService = RegistrationService();
  final _tripService = TripService();
  final _galleryService = GalleryService();

  String _selectedGender = 'Male';
  File? _selectedPhoto;
  bool _isSubmitting = false;

  static const List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppConfig.primaryGreen),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final img = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 70);
                if (img != null) setState(() => _selectedPhoto = File(img.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppConfig.primaryGreen),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final img = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (img != null) setState(() => _selectedPhoto = File(img.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Check duplicate registration
      final alreadyRegistered = await _regService.hasAlreadyRegistered(
          user.uid, widget.trip.id);
      if (alreadyRegistered) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You have already registered for this trip.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Upload photo if selected
      String photoUrl = '';
      if (_selectedPhoto != null) {
        try {
          photoUrl = await _galleryService.uploadPhoto(
              'student_photos', _selectedPhoto!);
        } catch (_) {}
      }

      final registration = Registration(
        id: '',
        tripId: widget.trip.id,
        userId: user.uid,
        tripCode: widget.trip.tripCode,
        fullName: _nameCtrl.text.trim(),
        className: _classCtrl.text.trim(),
        section: _sectionCtrl.text.trim().toUpperCase(),
        rollNumber: _rollCtrl.text.trim(),
        studentMobile: _studentMobileCtrl.text.trim(),
        parentMobile: _parentMobileCtrl.text.trim(),
        gender: _selectedGender,
        address: _addressCtrl.text.trim(),
        photoUrl: photoUrl,
        status: AppConfig.statusPending,
        paymentStatus: AppConfig.paymentPending,
      );

      await _regService.createRegistration(registration);
      await _tripService.decrementSeat(widget.trip.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted successfully! Awaiting approval.'),
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
    _nameCtrl.dispose();
    _classCtrl.dispose();
    _sectionCtrl.dispose();
    _rollCtrl.dispose();
    _studentMobileCtrl.dispose();
    _parentMobileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Trip Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppConfig.primaryGradient,
                borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tour_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.trip.tripName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white)),
                        Text('${widget.trip.destination} • Code: ${widget.trip.tripCode}',
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
            const SizedBox(height: 24),

            // Photo Upload
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConfig.surfaceGreen,
                      backgroundImage: _selectedPhoto != null
                          ? FileImage(_selectedPhoto!)
                          : null,
                      child: _selectedPhoto == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_rounded,
                                    color: AppConfig.primaryGreen, size: 28),
                                const SizedBox(height: 4),
                                Text('Photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppConfig.primaryGreen)),
                              ],
                            )
                          : null,
                    ),
                    if (_selectedPhoto != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppConfig.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 8),
            Center(
              child: Text('Student Photo (Optional)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppConfig.textGrey)),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Personal Information'),
            const SizedBox(height: 12),

            _buildField(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Full name is required' : null,
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            const SizedBox(height: 14),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: const Icon(Icons.wc_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.radiusMedium)),
              ),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 24),

            _sectionLabel('Academic Details'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    controller: _classCtrl,
                    label: 'Class',
                    icon: Icons.class_rounded,
                    hint: 'e.g. 10',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _sectionCtrl,
                    label: 'Section',
                    icon: Icons.group_rounded,
                    hint: 'A',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            const SizedBox(height: 14),

            _buildField(
              controller: _rollCtrl,
              label: 'Roll Number',
              icon: Icons.tag_rounded,
              keyboardType: TextInputType.text,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Roll number is required' : null,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 24),

            _sectionLabel('Contact Details'),
            const SizedBox(height: 12),

            _buildField(
              controller: _studentMobileCtrl,
              label: 'Student Mobile Number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (v) {
                if (v == null || v.trim().length != 10) {
                  return 'Enter valid 10-digit number';
                }
                return null;
              },
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            const SizedBox(height: 14),

            _buildField(
              controller: _parentMobileCtrl,
              label: 'Parent Mobile Number',
              icon: Icons.phone_in_talk_rounded,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (v) {
                if (v == null || v.trim().length != 10) {
                  return 'Enter valid 10-digit number';
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            const SizedBox(height: 14),

            _buildField(
              controller: _addressCtrl,
              label: 'Home Address',
              icon: Icons.home_rounded,
              maxLines: 3,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Address is required' : null,
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit Registration',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 16),

            Text(
              '* Your registration will be reviewed by the admin. You\'ll be notified upon approval.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppConfig.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppConfig.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        counterText: '',
      ),
      validator: validator,
    );
  }
}
