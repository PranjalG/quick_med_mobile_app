import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/supabase_auth_bridge.dart';
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
      imageQuality: 85,
      maxWidth: 2000,
    );
  }

  Future<void> _ensureSupabaseSession() async {
    try {
      await SupabaseAuthBridge.syncSessionFromFirebase(forceRefresh: true);
    } on SupabaseSessionException catch (error) {
      throw PrescriptionException(error.message);
    }
  }

  String? _resolveUserId() {
    return AuthService.currentUserId ?? _firebaseSubjectFromJwt();
  }

  static String _mimeForExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Uploads [file] for [orderId] and records it for doctor review.
  Future<Prescription> upload({
    required XFile file,
    String? orderId,
  }) async {
    await _ensureSupabaseSession();

    final subject = _resolveUserId();
    if (subject == null) {
      throw const PrescriptionException(
        'You need to be signed in to upload a prescription.',
      );
    }

    final ext = file.name.split('.').last.toLowerCase();
    final safeExt =
        (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp')
            ? ext
            : 'jpg';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$subject/${orderId ?? 'standalone'}-$stamp.$safeExt';
    final mime = _mimeForExtension(safeExt);

    try {
      await _client.storage.from(bucket).upload(
            path,
            File(file.path),
            fileOptions: FileOptions(
              contentType: mime,
              upsert: false,
            ),
          );
    } on StorageException catch (error) {
      debugPrint(
        'prescription upload failed: ${error.statusCode} ${error.message}',
      );
      throw PrescriptionException(_friendlyStorage(error));
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
      debugPrint('prescription row insert failed: ${error.message}');
      throw PrescriptionException(_friendlyPostgrest(error));
    }
  }

  String _friendlyStorage(StorageException error) {
    final code = error.statusCode ?? '';
    final message = error.message.toLowerCase();
    if (code == '404' || message.contains('bucket')) {
      return 'Prescription storage is not set up. Apply migration 007 on Supabase.';
    }
    if (code == '403' ||
        message.contains('row-level security') ||
        message.contains('jwt')) {
      return 'Upload blocked — app could not verify your login with Supabase. '
          'Enable Firebase under Supabase Third-party auth, then sign out and sign in again.';
    }
    if (message.contains('mime') || message.contains('mimetype')) {
      return 'That image type is not supported. Use JPG or PNG.';
    }
    return 'Could not upload the prescription. Please try again.';
  }

  String _friendlyPostgrest(PostgrestException error) {
    return switch (error.code) {
      '42501' => 'Upload blocked. Complete profile setup, then sign out and sign in again.',
      '23503' => 'Profile not found. Complete profile setup and try again.',
      _ =>
        'The image uploaded but could not be saved. Please try again.',
    };
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

  String? _firebaseSubjectFromJwt() {
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

  String get reference => orderId.isEmpty
      ? '#${id.substring(0, 8).toUpperCase()}'
      : '#${orderId.substring(0, 8).toUpperCase()}';
}
