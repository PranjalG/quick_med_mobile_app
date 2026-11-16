import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String kotaArea;
  final String addressDetail;
  final double? addressLatitude;
  final double? addressLongitude;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.kotaArea,
    required this.addressDetail,
    this.addressLatitude,
    this.addressLongitude,
  });

  bool get hasDeliveryCoordinates {
    final lat = addressLatitude;
    final lng = addressLongitude;
    if (lat == null || lng == null) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      kotaArea: json['kota_area'] as String? ?? '',
      addressDetail: json['address_detail'] as String? ?? '',
      addressLatitude: _readDouble(json['address_latitude']),
      addressLongitude: _readDouble(json['address_longitude']),
    );
  }

  static double? _readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'kota_area': kotaArea,
      'address_detail': addressDetail,
      'address_latitude': addressLatitude,
      'address_longitude': addressLongitude,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? kotaArea,
    String? addressDetail,
    double? addressLatitude,
    double? addressLongitude,
    bool clearCoordinates = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      kotaArea: kotaArea ?? this.kotaArea,
      addressDetail: addressDetail ?? this.addressDetail,
      addressLatitude:
          clearCoordinates ? null : (addressLatitude ?? this.addressLatitude),
      addressLongitude: clearCoordinates
          ? null
          : (addressLongitude ?? this.addressLongitude),
    );
  }
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  File _getLocalFile(String userId) {
    final tempDir = Directory.systemTemp;
    return File('${tempDir.path}/quick_med_profile_$userId.json');
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      // 1. Try querying Supabase
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final profile = UserProfile.fromJson(response);
        // Sync local cache
        await _saveLocal(profile);
        return profile;
      }
    } catch (e) {
      debugPrint('Supabase fetchProfile failed, attempting local fallback: $e');
    }

    // 2. Fallback to local file cache
    return await _fetchLocal(userId);
  }

  Future<void> saveProfile(UserProfile profile) async {
    // Always save to local cache first
    await _saveLocal(profile);

    try {
      // Try saving to Supabase
      await _client.from('profiles').upsert(profile.toJson());
      debugPrint('Profile successfully saved to Supabase');
    } catch (e) {
      debugPrint('Supabase saveProfile failed, relying on local fallback: $e');
      // We don't rethrow because local saving succeeded. The app continues normally.
    }
  }

  Future<UserProfile?> _fetchLocal(String userId) async {
    try {
      final file = _getLocalFile(userId);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return UserProfile.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to read local profile: $e');
    }
    return null;
  }

  Future<void> _saveLocal(UserProfile profile) async {
    try {
      final file = _getLocalFile(profile.id);
      await file.writeAsString(jsonEncode(profile.toJson()));
      debugPrint('Profile successfully saved to local file: ${file.path}');
    } catch (e) {
      debugPrint('Failed to write local profile: $e');
    }
  }
}
