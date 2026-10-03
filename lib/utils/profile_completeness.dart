import 'package:quick_med/services/profile_service.dart';

/// Whether the customer can leave profile setup and use the app.
bool isProfileComplete(UserProfile? profile) {
  if (profile == null) return false;
  return profile.name.trim().isNotEmpty &&
      profile.addressDetail.trim().isNotEmpty &&
      profile.hasDeliveryCoordinates;
}
