import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_med/services/live_tracking_repository.dart';

abstract class LiveTrackingState extends Equatable {
  const LiveTrackingState();

  @override
  List<Object?> get props => [];
}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingLoading extends LiveTrackingState {}

class LiveTrackingActive extends LiveTrackingState {
  final AgentLocation agentLocation;
  final LatLng destination;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final String eta;

  const LiveTrackingActive({
    required this.agentLocation,
    required this.destination,
    required this.markers,
    required this.polylines,
    required this.eta,
  });

  @override
  List<Object?> get props => [agentLocation, destination, markers, polylines, eta];
}

class LiveTrackingError extends LiveTrackingState {
  final String error;

  const LiveTrackingError({required this.error});

  @override
  List<Object?> get props => [error];
}
