import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../config/app_config.dart';
import '../../../models/trip.dart';
import '../../../services/trip_service.dart';
import '../../../services/gallery_service.dart';

class UploadGalleryPage extends StatefulWidget {
  const UploadGalleryPage({super.key});

  @override
  State<UploadGalleryPage> createState() => _UploadGalleryPageState();
}

class _UploadGalleryPageState extends State<UploadGalleryPage> {
  final _tripService = TripService();
  final _galleryService = GalleryService();
  final _captionCtrl = TextEditingController();
  final _albumLinkCtrl = TextEditingController();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  List<File> _selectedPhotos = [];
  bool _isUploading = false;
  int _uploadedCount = 0;

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

  Future<void> _pickPhotos() async {
    final imgs = await ImagePicker().pickMultiImage(imageQuality: 75);
    if (imgs.isNotEmpty) {
      setState(() =>
          _selectedPhotos = imgs.map((i) => File(i.path)).toList());
    }
  }

  Future<void> _uploadPhotos() async {
    if (_selectedTrip == null || _selectedPhotos.isEmpty) return;
    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
    });
    try {
      for (final photo in _selectedPhotos) {
        final url =
            await _galleryService.uploadPhoto(_selectedTrip!.id, photo);
        await _galleryService.addGalleryItem(
          tripId: _selectedTrip!.id,
          imageUrl: url,
          caption: _captionCtrl.text.trim(),
          uploadedBy:
              FirebaseAuth.instance.currentUser?.uid ?? 'admin',
        );
        setState(() => _uploadedCount++);
      }
      if (!mounted) return;
      setState(() => _selectedPhotos = []);
      _captionCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_uploadedCount photos uploaded!'),
          backgroundColor: AppConfig.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveAlbumLink() async {
    if (_selectedTrip == null || _albumLinkCtrl.text.trim().isEmpty) return;
    await _galleryService.addGooglePhotosAlbum(
      tripId: _selectedTrip!.id,
      link: _albumLinkCtrl.text.trim(),
    );
    // Also update the trip's googlePhotosLink field
    await _tripService.updateTrip(_selectedTrip!.id, {
      'googlePhotosLink': _albumLinkCtrl.text.trim(),
    });
    if (!mounted) return;
    _albumLinkCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Photos link saved!'),
        backgroundColor: AppConfig.primaryGreen,
      ),
    );
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _albumLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Gallery',
              style: Theme.of(context).textTheme.headlineLarge),
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

          // Google Photos Album
          Text('Google Photos Album',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _albumLinkCtrl,
                  decoration: const InputDecoration(
                    hintText: 'https://photos.google.com/...',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _saveAlbumLink,
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upload Photos
          Text('Upload Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppConfig.surfaceGreen,
                borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
                border: Border.all(
                    color: AppConfig.primaryGreen.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_rounded,
                      color: AppConfig.primaryGreen, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPhotos.isEmpty
                        ? 'Tap to select photos'
                        : '${_selectedPhotos.length} photos selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConfig.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedPhotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPhotos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
                  child: Image.file(_selectedPhotos[i],
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                prefixIcon: Icon(Icons.text_fields_rounded),
              ),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadedCount / _selectedPhotos.length,
                    backgroundColor: AppConfig.dividerColor,
                    color: AppConfig.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  Text('Uploading $_uploadedCount / ${_selectedPhotos.length}...'),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _uploadPhotos,
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                      'Upload ${_selectedPhotos.length} Photos'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
