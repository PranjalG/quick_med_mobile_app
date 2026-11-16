import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_med/custom_components/primary_button.dart';
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

  const DeliveryLocationPicker({
    super.key,
    this.latitude,
    this.longitude,
    required this.onLocationChanged,
    this.errorText,
  });

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  GoogleMapController? _mapController;
  bool _locating = false;
  String? _locationError;

  LatLng get _pin {
    if (widget.latitude != null && widget.longitude != null) {
      return LatLng(widget.latitude!, widget.longitude!);
    }
    return kotaDefaultCenter;
  }

  bool get _hasPin =>
      widget.latitude != null && widget.longitude != null;

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
        if (_hasPin)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.fs(14),
              vertical: context.fs(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(context.fs(12)),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pin_drop_outlined,
                  color: AppColors.brandTeal,
                  size: 20,
                ),
                SizedBox(width: context.fs(8)),
                Expanded(
                  child: Text(
                    '${widget.latitude!.toStringAsFixed(5)}, '
                    '${widget.longitude!.toStringAsFixed(5)}',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: context.fs(13),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
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
        PrimaryButton(
          label: _locating ? 'Getting location…' : 'Use my current location',
          enabled: !_locating,
          onTap: _locating ? null : _useCurrentLocation,
        ),
      ],
    );
  }
}
