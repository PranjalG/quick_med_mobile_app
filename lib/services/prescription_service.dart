import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrescriptionException implements Exception {
  final String message;
  const PrescriptionException(this.message);

  @override
  String toString() => message;
}

class Prescription {
  final String id;
  final String orderId;
  final String storagePath;
  final String status; // pending_review | approved | rejected
  final String? reviewNotes;

  const Prescription({
    required this.id,
    required this.orderId,
    required this.storagePath,
    required this.status,
    this.reviewNotes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as String? ?? '',
        orderId: json['order_id'] as String? ?? '',
        storagePath: json['storage_path'] as String? ?? '',
        status: json['status'] as String? ?? 'pending_review',
        reviewNotes: json['review_notes'] as String?,
      );

  bool get isPending => status == 'pending_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

/// Uploads prescription images and tracks their review state.
///
/// Images live in the private `prescriptions` bucket under `{uid}/...`, which
/// is what the storage policies key on. They are never publicly readable —
/// display always goes through a short-lived signed URL.
class PrescriptionService {
  PrescriptionService({SupabaseClient? client, ImagePicker? picker})
      : _client = client ?? Supabase.instance.client,
        _picker = picker ?? ImagePicker();

  final SupabaseClient _client;
  final ImagePicker _picker;

  static const String bucket = 'prescriptions';

  /// Prompts for an image. Returns null if the user backs out.
  Future<XFile?> pick({required bool fromCamera}) {
    return _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      // Prescriptions must stay legible; compress, but not to mush.
      imageQuality: 85,
      maxWidth: 2000,
    );
  }

  /// Uploads [file] for [orderId] and records it for doctor review.
  /// [orderId] is optional: a customer can upload a prescription before any
  /// order exists (the landing-screen entry point). `prescriptions.order_id`
  /// is nullable for exactly this case, and it is attached at checkout.
  Future<Prescription> upload({
    required XFile file,
    String? orderId,
  }) async {
    final uid = _client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;

    // Firebase third-party auth means Supabase has no local user row; the uid
    // we key storage on is the Firebase UID carried in the JWT `sub` claim.
    final subject = uid ?? _firebaseSubject();
    if (subject == null) {
      throw const PrescriptionException(
        'You need to be signed in to upload a prescription.',
      );
    }

    final ext = file.name.split('.').last.toLowerCase();
    final safeExt = (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp')
        ? ext
        : 'jpg';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$subject/${orderId ?? 'standalone'}-$stamp.$safeExt';

    try {
      await _client.storage.from(bucket).upload(
            path,
            File(file.path),
            fileOptions: FileOptions(
              contentType: 'image/$safeExt',
              upsert: false,
            ),
          );
    } on StorageException catch (error) {
      debugPrint('prescription upload failed: ${error.statusCode} ${error.message}');
      throw PrescriptionException(
        error.statusCode == '404'
            ? 'Prescription storage is not set up. Run migration 007.'
            : 'Could not upload the prescription. Please try again.',
      );
    }

    try {
      final row = await _client
          .from('prescriptions')
          .insert({
            'user_id': subject,
            if (orderId != null) 'order_id': orderId,
            'storage_path': path,
          })
          .select()
          .single();
      return Prescription.fromJson(row);
    } on PostgrestException catch (error) {
      // The image is already uploaded; leaving an orphan is better than
      // leaving the customer unable to retry, so surface and move on.
      debugPrint('prescription row insert failed: ${error.message}');
      throw const PrescriptionException(
        'The image uploaded but could not be recorded. Please try again.',
      );
    }
  }

  /// Short-lived signed URL for viewing a private prescription image.
  Future<String> signedUrl(String storagePath,
      {Duration validFor = const Duration(minutes: 10)}) {
    return _client.storage
        .from(bucket)
        .createSignedUrl(storagePath, validFor.inSeconds);
  }

  Future<Prescription?> forOrder(String orderId) async {
    final row = await _client
        .from('prescriptions')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : Prescription.fromJson(row);
  }

  String? _firebaseSubject() {
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = String.fromCharCodes(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return (jsonDecode(payload) as Map<String, dynamic>)['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// True when the signed-in profile has role doctor or admin.
  ///
  /// Read from `profiles`, not from the JWT: role is our data, and putting it
  /// in a Firebase custom claim would mean re-issuing tokens to change it.
  Future<bool> isStaff(String uid) async {
    try {
      final row = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      final role = row?['role'] as String?;
      return role == 'doctor' || role == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// Prescriptions awaiting review, oldest first, with the order and its
  /// medicine names embedded.
  Future<List<PendingReview>> fetchQueue({int limit = 50}) async {
    final List<dynamic> rows = await _client
        .from('prescriptions')
        .select(
          'id, order_id, storage_path, status, created_at, user_id, '
          'orders(total_amount, status, '
          'order_items(quantity, medicines(name, prescription_required)))',
        )
        .eq('status', 'pending_review')
        .order('created_at', ascending: true)
        .limit(limit);

    return rows
        .map((r) => PendingReview.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Approves or rejects, moving the prescription and its order together.
  Future<void> review({
    required String prescriptionId,
    required bool approve,
    String? notes,
  }) async {
    try {
      await _client.rpc('review_prescription', params: {
        'prescription_id': prescriptionId,
        'approve': approve,
        'notes': notes,
      });
    } on PostgrestException catch (error) {
      throw PrescriptionException(switch (error.code) {
        '42501' => 'Only doctors can review prescriptions.',
        '23505' => 'This prescription has already been reviewed.',
        '23503' => 'That prescription no longer exists.',
        'PGRST202' =>
          'Review is unavailable — run supabase/migrations/009_review_prescription.sql.',
        _ => error.message,
      });
    }
  }
}

/// One row of the doctor review queue.
class PendingReview {
  final String id;
  final String orderId;
  final String storagePath;
  final DateTime? createdAt;
  final double orderTotal;
  final List<String> itemNames;

  const PendingReview({
    required this.id,
    required this.orderId,
    required this.storagePath,
    this.createdAt,
    this.orderTotal = 0,
    this.itemNames = const [],
  });

  factory PendingReview.fromJson(Map<String, dynamic> json) {
    final order = json['orders'];
    final items = order is Map<String, dynamic>
        ? (order['order_items'] as List<dynamic>? ?? const [])
        : const [];

    return PendingReview(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      storagePath: json['storage_path'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      orderTotal: order is Map<String, dynamic>
          ? (order['total_amount'] as num?)?.toDouble() ?? 0
          : 0,
      itemNames: items.map((e) {
        final m = (e as Map<String, dynamic>)['medicines'];
        final qty = (e['quantity'] as num?)?.toInt() ?? 1;
        final name = m is Map<String, dynamic>
            ? (m['name'] as String? ?? 'Unknown')
            : 'Unknown';
        return qty > 1 ? '$name x$qty' : name;
      }).toList(),
    );
  }

  String get reference => '#${orderId.substring(0, 8).toUpperCase()}';
}
