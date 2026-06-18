import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String tripId;
  final String imageUrl;
  final String caption;
  final String uploadedBy;
  final DateTime? uploadedAt;

  GalleryItem({
    required this.id,
    required this.tripId,
    required this.imageUrl,
    this.caption = '',
    this.uploadedBy = '',
    this.uploadedAt,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> data, String id) {
    return GalleryItem(
      id: id,
      tripId: data['tripId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'imageUrl': imageUrl,
      'caption': caption,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt != null
          ? Timestamp.fromDate(uploadedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

class GalleryAlbum {
  final String id;
  final String tripId;
  final String googlePhotosLink;
  final String albumTitle;
  final DateTime? createdAt;

  GalleryAlbum({
    required this.id,
    required this.tripId,
    required this.googlePhotosLink,
    this.albumTitle = '',
    this.createdAt,
  });

  factory GalleryAlbum.fromMap(Map<String, dynamic> data, String id) {
    return GalleryAlbum(
      id: id,
      tripId: data['tripId'] ?? '',
      googlePhotosLink: data['googlePhotosLink'] ?? '',
      albumTitle: data['albumTitle'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'googlePhotosLink': googlePhotosLink,
      'albumTitle': albumTitle,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
