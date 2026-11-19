import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quick_med/services/geocoding_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/map_gesture_utils.dart';
import 'package:quick_med/utils/screen_size.dart';

/// Kota city center — default map pin before GPS is set.
const LatLng kotaDefaultCenter = LatLng(25.1764, 75.8362);

class DeliveryLocationPicker extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onLocationChanged;
  final String? errorText;

  /// Called with the street address found for the pin, so the form can
  /// pre-fill its address fields.
  final ValueChanged<ResolvedAddress>? onAddressResolved;

  const DeliveryLocationPicker({
    super.key,
    this.latitude,
    this.longitude,
    required this.onLocationChanged,
    this.errorText,
    this.onAddressResolved,
  });

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  GoogleMapController? _mapController;
  bool _locating = false;
  String? _locationError;

  final GeocodingService _geocoder = GeocodingService();
  Timer? _lookupDebounce;
  int _lookupId = 0;
  bool _resolving = false;
  ResolvedAddress? _resolved;

  @override
  void initState() {
    super.initState();
    if (_hasPin) _scheduleAddressLookup(delay: Duration.zero);
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    super.dispose();
  }

  /// Looks up the address for the current pin. Debounced because dragging or
  /// tapping around fires many pin changes; only the latest one matters.
  ///
  /// Only called from [initState] and [didUpdateWidget], which are always
  /// followed by a build, so the fields are set without `setState`.
  void _scheduleAddressLookup({
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _lookupDebounce?.cancel();
    _resolving = true;
    _resolved = null;
    _lookupDebounce = Timer(delay, _lookupAddress);
  }

  Future<void> _lookupAddress() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    if (lat == null || lng == null) return;

    final id = ++_lookupId;
    final result = await _geocoder.reverse(lat, lng);
    // Ignore answers for a pin the user has since moved.
    if (!mounted || id != _lookupId) return;

    setState(() {
      _resolving = false;
      _resolved = result;
    });
    if (result != null) widget.onAddressResolved?.call(result);
  }

  LatLng get _pin {
    if (widget.latitude != null && widget.longitude != null) {
      return LatLng(widget.latitude!, widget.longitude!);
    }
    return kotaDefaultCenter;
  }

  bool get _hasPin => widget.latitude != null && widget.longitude != null;

  double _mapHeight(BuildContext context) {
    final scaled = context.sh * 0.28;
    return scaled < 220 ? 220 : scaled;
  }

  @override
  void didUpdateWidget(DeliveryLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latChanged = oldWidget.latitude != widget.latitude;
    final lngChanged = oldWidget.longitude != widget.longitude;
    if (latChanged || lngChanged) {
      _syncCameraToPin(animated: true);
      if (_hasPin) _scheduleAddressLookup();
    }
  }

  Future<void> _syncCameraToPin({bool animated = false}) async {
    final controller = _mapController;
    if (controller == null) return;

    final update = CameraUpdate.newLatLngZoom(_pin, _hasPin ? 16 : 12);
    if (animated) {
      await controller.animateCamera(update);
    } else {
      await controller.moveCamera(update);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission is required to pin your delivery spot.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Turn on location services, then try again.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      widget.onLocationChanged(latLng);
      await _syncCameraToPin(animated: true);
    } catch (_) {
      setState(() {
        _locationError =
            'Could not get your location. Tap the map to set the pin manually.';
      });
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() => _locationError = null);
    widget.onLocationChanged(latLng);
  }

  Set<Marker> _buildMarkers() {
    if (!_hasPin) return {};
    return {
      Marker(
        markerId: const MarkerId('delivery'),
        position: _pin,
        draggable: true,
        onDragEnd: widget.onLocationChanged,
      ),
    };
  }

  Widget _buildPinAddress(BuildContext context) {
    final resolved = _resolved;
    final String title;
    final Color titleColor;
    if (_resolving) {
      title = 'Finding address…';
      titleColor = AppColors.textSecondary;
    } else if (resolved != null && resolved.formatted.isNotEmpty) {
      title = resolved.formatted;
      titleColor = AppColors.textPrimary;
    } else {
      title = 'No street address found for this spot — add details above.';
      titleColor = AppColors.textSecondary;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.fs(14),
        vertical: context.fs(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.fs(12)),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.fs(2)),
            child: _resolving
                ? SizedBox(
                    width: context.fs(18),
                    height: context.fs(18),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandTeal,
                    ),
                  )
                : Icon(
                    Icons.location_on_rounded,
                    color: AppColors.brandTeal,
                    size: context.fs(20),
                  ),
          ),
          SizedBox(width: context.fs(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(context).copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: context.fs(13),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: context.fs(2)),
                Text(
                  '${widget.latitude!.toStringAsFixed(5)}, '
                  '${widget.longitude!.toStringAsFixed(5)}',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.textSecondary,
                    fontSize: context.fs(11),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validationError = widget.errorText;
    final hintError = _locationError;
    final mapHeight = _mapHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delivery location on map',
          style: AppTextStyles.body(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.fs(6)),
        Text(
          'Drag the map to move around. Tap to place the pin, or drag the pin to adjust.',
          style: AppTextStyles.body(context).copyWith(
            color: AppColors.textSecondary,
            fontSize: context.fs(13),
            height: 1.35,
          ),
        ),
        SizedBox(height: context.fs(12)),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.fs(16)),
          child: SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: GoogleMap(
              gestureRecognizers: mapScrollGestures,
              initialCameraPosition: CameraPosition(
                target: _pin,
                zoom: _hasPin ? 16 : 12,
              ),
              onMapCreated: (controller) async {
                _mapController = controller;
                await _syncCameraToPin(animated: false);
              },
              onTap: _onMapTap,
              markers: _buildMarkers(),
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        SizedBox(height: context.fs(10)),
        if (_hasPin) ...[
          _buildPinAddress(context),
          if (!GeocodingService.isInDeliveryArea(
            widget.latitude!,
            widget.longitude!,
          )) ...[
            SizedBox(height: context.fs(8)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: context.fs(16),
                  color: AppColors.accent,
                ),
                SizedBox(width: context.fs(6)),
                Expanded(
                  child: Text(
                    'This pin is outside our Kota delivery area. Move it to '
                    'your address in Kota.',
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.accent,
                      fontSize: context.fs(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ] else
          Text(
            'No pin yet — use GPS or tap the map.',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.textSecondary,
              fontSize: context.fs(13),
            ),
          ),
        if (hintError != null) ...[
          SizedBox(height: context.fs(8)),
          Text(
            hintError,
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.error,
              fontSize: context.fs(12),
            ),
          ),
        ],
        if (validationError != null) ...[
          SizedBox(height: context.fs(8)),
          Text(
            validationError,
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.error,
              fontSize: context.fs(12),
            ),
          ),
        ],
        SizedBox(height: context.fs(12)),
        // Secondary action: the form's Save button is the primary one.
        OutlinedButton.icon(
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? SizedBox(
                  width: context.fs(16),
                  height: context.fs(16),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandTeal,
                  ),
                )
              : Icon(
                  Icons.my_location_rounded,
                  size: context.fs(18),
                  color: AppColors.brandTeal,
                ),
          label: Text(
            _locating ? 'Getting location…' : 'Use my current location',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.brandGreenDeep,
              fontWeight: FontWeight.w600,
              fontSize: context.fs(14),
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(context.fs(48)),
            side: const BorderSide(color: AppColors.brandTeal, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.fs(14)),
            ),
          ),
        ),
      ],
    );
  }
}
