import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_med/blocs/live_tracking_cubit/live_tracking_cubit.dart';
import 'package:quick_med/blocs/live_tracking_cubit/live_tracking_state.dart';
import 'package:quick_med/services/app_colors.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String orderId;

  const LiveTrackingScreen({
    super.key,
    this.orderId = 'mock_order_123',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveTrackingCubit()..startTracking(orderId),
      child: const LiveTrackingView(),
    );
  }
}

class LiveTrackingView extends StatefulWidget {
  const LiveTrackingView({super.key});

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LiveTrackingCubit, LiveTrackingState>(
        listener: (context, state) {
          if (state is LiveTrackingActive && _mapController != null) {
            // Animate camera to center both agent and customer destination
            final agent = LatLng(
              state.agentLocation.latitude,
              state.agentLocation.longitude,
            );
            final dest = state.destination;

            // Bounds computation
            final bounds = LatLngBounds(
              southwest: LatLng(
                agent.latitude < dest.latitude ? agent.latitude : dest.latitude,
                agent.longitude < dest.longitude ? agent.longitude : dest.longitude,
              ),
              northeast: LatLng(
                agent.latitude > dest.latitude ? agent.latitude : dest.latitude,
                agent.longitude > dest.longitude ? agent.longitude : dest.longitude,
              ),
            );

            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100),
            );
          }
        },
        builder: (context, state) {
          if (state is LiveTrackingLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is LiveTrackingError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tracking map',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<LiveTrackingCubit>().startTracking('mock_order_123');
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.montserrat(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          LatLng initialCenter = const LatLng(25.1764, 75.8362); // Kota center coordinates
          Set<Marker> markers = {};
          Set<Polyline> polylines = {};
          String etaText = 'Calculating ETA...';

          if (state is LiveTrackingActive) {
            initialCenter = LatLng(
              state.agentLocation.latitude,
              state.agentLocation.longitude,
            );
            markers = state.markers;
            polylines = state.polylines;
            etaText = state.eta;
          }

          return Stack(
            children: [
              // Google Map Widget
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCenter,
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: markers,
                polylines: polylines,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Floating Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.textPrimary,
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home_screen');
                    }
                  },
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),

              // Bottom Sheet Overlay Details
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F000000),
                        offset: Offset(0, -4),
                        blurRadius: 16,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ETA and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Progress',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                etaText,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'In Transit',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 16),

                      // Delivery Agent Profile details
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0F2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delivery_dining_rounded,
                              size: 28,
                              color: Color(0xFF00796B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rahul Sharma',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hero Splendor Plus (RJ-20-DE-1234)',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons (Call / Support)
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Calling Rahul Sharma (Simulated)...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
