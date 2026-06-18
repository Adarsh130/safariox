import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/gallery_item.dart';
import '../config/app_config.dart';

class GalleryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPhoto(String tripId, File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref =
        _storage.ref().child('gallery/$tripId/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> addGalleryItem({
    required String tripId,
    required String imageUrl,
    String caption = '',
    String uploadedBy = '',
  }) async {
    final item = GalleryItem(
      id: '',
      tripId: tripId,
      imageUrl: imageUrl,
      caption: caption,
      uploadedBy: uploadedBy,
    );
    final docRef = await _db
        .collection(AppConfig.colGallery)
        .add(item.toMap());
    return docRef.id;
  }

  Future<void> addGooglePhotosAlbum({
    required String tripId,
    required String link,
    String albumTitle = '',
  }) async {
    await _db.collection('gallery_albums').add({
      'tripId': tripId,
      'googlePhotosLink': link,
      'albumTitle': albumTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<GalleryItem>> getTripGallery(String tripId) {
    return _db
        .collection(AppConfig.colGallery)
        .where('tripId', isEqualTo: tripId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GalleryItem.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<GalleryAlbum>> getTripAlbums(String tripId) {
    return _db
        .collection('gallery_albums')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GalleryAlbum.fromMap(d.data(), d.id)).toList());
  }

  Future<void> deleteGalleryItem(String itemId, String imageUrl) async {
    await _db
        .collection(AppConfig.colGallery)
        .doc(itemId)
        .delete();
    // Also delete from storage if it's a Firebase Storage URL
    if (imageUrl.contains('firebasestorage')) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {}
    }
  }
}
