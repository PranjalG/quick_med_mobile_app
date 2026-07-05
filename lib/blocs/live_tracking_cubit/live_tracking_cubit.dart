import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_med/services/live_tracking_repository.dart';
import 'live_tracking_state.dart';

class LiveTrackingCubit extends Cubit<LiveTrackingState> {
  final LiveTrackingRepository _repository = LiveTrackingRepository();
  StreamSubscription<AgentLocation>? _locationSubscription;

  LiveTrackingCubit() : super(LiveTrackingInitial());

  void startTracking(String orderId) async {
    emit(LiveTrackingLoading());
    try {
      final destCoords = await _repository.getDestinationCoordinates(orderId);
      final LatLng destination = LatLng(destCoords['lat']!, destCoords['lng']!);

      _locationSubscription?.cancel();
      _locationSubscription = _repository.getAgentLocationStream(orderId).listen(
        (location) {
          final agentLatLng = LatLng(location.latitude, location.longitude);
          
          // Calculate ETA dynamically (distance / speed + overhead)
          final distanceKm = _calculateDistance(agentLatLng, destination);
          final minutes = ((distanceKm / 30.0) * 60).round() + 2; // 30 km/h average traffic speed
          final eta = minutes <= 2 ? 'Arriving now' : 'Arriving in $minutes mins';

          // Build Markers
          final Set<Marker> markers = {
            Marker(
              markerId: const MarkerId('destination'),
              position: destination,
              infoWindow: const InfoWindow(title: 'Delivery Address'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('agent'),
              position: agentLatLng,
              rotation: location.heading,
              infoWindow: const InfoWindow(title: 'Delivery Partner'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          };

          // Build route Polyline (Connecting line)
          final Set<Polyline> polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: [agentLatLng, destination],
              color: Colors.green,
              width: 5,
              jointType: JointType.round,
            ),
          };

          emit(LiveTrackingActive(
            agentLocation: location,
            destination: destination,
            markers: markers,
            polylines: polylines,
            eta: eta,
          ));
        },
        onError: (error) {
          emit(LiveTrackingError(error: error.toString()));
        },
      );
    } catch (e) {
      emit(LiveTrackingError(error: e.toString()));
    }
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((pos2.latitude - pos1.latitude) * p) / 2 +
        cos(pos1.latitude * p) *
            cos(pos2.latitude * p) *
            (1 - cos((pos2.longitude - pos1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a)); // Earth Diameter: 12742 km
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
