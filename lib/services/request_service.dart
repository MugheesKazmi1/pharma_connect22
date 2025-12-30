import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class RequestService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = const Uuid();

  /// Uploads a prescription image and returns a download URL.
  /// Accepts a File (mobile/desktop), XFile (image_picker) or Uint8List (web).
  static Future<String> uploadPrescription(dynamic image) async {
    if (image == null) throw Exception('No image provided');

    final id = _uuid.v4();
    final ref = _storage.ref().child('prescriptions/$id.jpg');

    try {
      TaskSnapshot task;
      if (image is File) {
        task = await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
      } else if (image is XFile) {
        final bytes = await image.readAsBytes();
        task = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else if (image is Uint8List) {
        task = await ref.putData(image, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        throw Exception('Unsupported image type: ${image.runtimeType}');
      }

      final url = await task.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Storage error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload prescription: $e');
    }
  }

  /// Creates a request document in Firestore.
  /// If [broadcast] is true the request is intended for all nearby pharmacies.
  /// If [pharmacyId] is provided and broadcast==false the request targets that pharmacy.
  /// Returns the created DocumentReference.
  static Future<DocumentReference> createRequest({
    required String userId,
    required String medicineName,
    String? prescriptionUrl,
    bool broadcast = false,
    String? pharmacyId,
    Map<String, dynamic>? location,
    Map<String, dynamic>? meta,
  }) async {
    final docRef = _db.collection('requests').doc();
    final payload = <String, dynamic>{
      'userId': userId,
      'medicineName': medicineName.trim().toLowerCase(),
      'prescriptionUrl': prescriptionUrl,
      'broadcast': broadcast,
      'pharmacyId': pharmacyId,
      'status': 'open', // open, accepted, cancelled, completed
      'createdAt': FieldValue.serverTimestamp(),
      'location': location ?? {},
      'meta': meta ?? {},
    };

    try {
      await docRef.set(payload);
      return docRef;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  /// Streams requests for a given user (most recent first).
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamRequestsForUser(String userId) {
    return _db
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Fetch open broadcast requests (useful for pharmacy apps).
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamOpenBroadcastRequests() {
    return _db
        .collection('requests')
        .where('broadcast', isEqualTo: true)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Cancel a request (user action).
  static Future<void> cancelRequest(String requestId) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }

  /// Mark request accepted by a pharmacy.
  static Future<void> acceptRequest(String requestId, String pharmacyId) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'acceptedBy': pharmacyId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Failed to accept request: $e');
    }
  }

  /// Utility: attempt to read a request doc once.
  static Future<DocumentSnapshot<Map<String, dynamic>>> fetchRequest(String requestId) {
    return _db.collection('requests').doc(requestId).get();
  }
}