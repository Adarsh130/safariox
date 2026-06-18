import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../models/trip.dart';
import '../../models/gallery_item.dart';
import '../../services/gallery_service.dart';

class GalleryPage extends StatelessWidget {
  final Trip trip;

  const GalleryPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final galleryService = GalleryService();

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.tripName} Gallery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Google Photos Album Link
          if (trip.googlePhotosLink.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(trip.googlePhotosLink);
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_album_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Google Photos Album',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.white)),
                          Text('Tap to view shared album',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

          if (trip.googlePhotosLink.isNotEmpty) const SizedBox(height: 20),

          Text('Trip Photos',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          // Firebase Storage Photos
          StreamBuilder<List<GalleryItem>>(
            stream: galleryService.getTripGallery(trip.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppConfig.primaryGreen));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                              color: AppConfig.surfaceGreen,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.photo_library_outlined,
                              color: AppConfig.primaryGreen, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Text('No Photos Yet',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Photos will be uploaded by the admin after the trip.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppConfig.textGrey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () => _showFullImage(context, items, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppConfig.surfaceGreen,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppConfig.primaryGreen, strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppConfig.surfaceGreen,
                          child: const Icon(Icons.broken_image_rounded,
                              color: AppConfig.textLight),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: Duration(milliseconds: 50 * index),
                          duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFullImage(
      BuildContext context, List<GalleryItem> items, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullImageViewer(items: items, initialIndex: initialIndex),
      ),
    );
  }
}

class _FullImageViewer extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const _FullImageViewer(
      {required this.items, required this.initialIndex});

  @override
  State<_FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<_FullImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.items.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image_rounded,
                            color: Colors.white54, size: 60),
                  ),
                ),
              ),
              if (item.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(item.caption,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center),
                ),
            ],
          );
        },
      ),
    );
  }
}
