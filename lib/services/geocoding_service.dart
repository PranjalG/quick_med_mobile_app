import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Kota city centre, used for the delivery-area check.
const double kotaCenterLatitude = 25.1764;
const double kotaCenterLongitude = 75.8362;

/// Pins further than this from the city centre are outside the delivery area.
const double kotaDeliveryRadiusMeters = 25000;

/// A human-readable address for a map pin.
class ResolvedAddress {
  /// House number / street / building, e.g. "12, Station Road".
  /// Empty when the geocoder only knows the neighbourhood.
  final String streetLine;

  /// Neighbourhood, e.g. "Talwandi".
  final String locality;

  /// Full single-line address for display.
  final String formatted;

  /// Whether the pin is inside the Kota delivery radius.
  final bool isInDeliveryArea;

  const ResolvedAddress({
    required this.streetLine,
    required this.locality,
    required this.formatted,
    required this.isInDeliveryArea,
  });

  /// The entry from [areas] that this address falls in, if any.
  String? matchArea(List<String> areas) {
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final haystack = norm('$locality $formatted');
    for (final area in areas) {
      if (haystack.contains(norm(area))) return area;
    }
    return null;
  }
}

/// Reverse geocoding through the phone's built-in geocoder (Google Play
/// services on Android, Apple on iOS). Free, no API key or billing needed.
class GeocodingService {
  GeocodingService({Geocoding? geocoding})
      : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  static bool isInDeliveryArea(double latitude, double longitude) {
    final meters = Geolocator.distanceBetween(
      latitude,
      longitude,
      kotaCenterLatitude,
      kotaCenterLongitude,
    );
    return meters <= kotaDeliveryRadiusMeters;
  }

  /// Returns `null` when no address is found or the geocoder is unavailable
  /// (offline, rate-limited, no Play services). Callers fall back to showing
  /// the pin without an address.
  Future<ResolvedAddress?> reverse(double latitude, double longitude) async {
    try {
      final placemarks =
          await _geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      return _format(placemarks.first, latitude, longitude);
    } catch (error) {
      debugPrint('Reverse geocoding failed: $error');
      return null;
    }
  }

  ResolvedAddress _format(Placemark p, double latitude, double longitude) {
    String clean(String? value) => (value ?? '').trim();

    // Android often returns a Plus Code (e.g. "5RG8+QX") as the name/street;
    // it means nothing to a delivery rider, so drop it.
    bool isPlusCode(String value) =>
        RegExp(r'^[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{0,3}',
                caseSensitive: false)
            .hasMatch(value);

    final numbered = [clean(p.subThoroughfare), clean(p.thoroughfare)]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final streetCandidates = [numbered, clean(p.street), clean(p.name)];
    final streetLine = streetCandidates.firstWhere(
      (s) => s.isNotEmpty && !isPlusCode(s),
      orElse: () => '',
    );

    final locality = clean(p.subLocality);
    final city = clean(p.locality).isNotEmpty
        ? clean(p.locality)
        : clean(p.subAdministrativeArea);
    final stateAndPin = [clean(p.administrativeArea), clean(p.postalCode)]
        .where((s) => s.isNotEmpty)
        .join(' ');

    // Join the parts, skipping blanks and repeats ("Kota, Kota").
    final seen = <String>{};
    final parts = <String>[];
    for (final part in [streetLine, locality, city, stateAndPin]) {
      final key = part.toLowerCase();
      if (part.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      parts.add(part);
    }

    return ResolvedAddress(
      streetLine: streetLine,
      locality: locality,
      formatted: parts.join(', '),
      isInDeliveryArea: isInDeliveryArea(latitude, longitude),
    );
  }
}
