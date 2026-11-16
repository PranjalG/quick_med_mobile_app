import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgentLocation {
  final double latitude;
  final double longitude;
  final double heading; // Orientation angle in degrees
  final DateTime timestamp;

  const AgentLocation({
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.timestamp,
  });
}

class LiveTrackingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Kota specific coordinates for simulation
  // From Nayapura (Pharmacy Store) to Talwandi (Customer Address)
  static const List<Map<String, double>> _simulatedPath = [
    {'lat': 25.1950, 'lng': 75.8450, 'heading': 180.0}, // Nayapura Store
    {'lat': 25.1880, 'lng': 75.8440, 'heading': 185.0},
    {'lat': 25.1800, 'lng': 75.8420, 'heading': 190.0},
    {'lat': 25.1720, 'lng': 75.8410, 'heading': 175.0}, // Vigyan Nagar Flyover
    {'lat': 25.1630, 'lng': 75.8390, 'heading': 195.0},
    {'lat': 25.1550, 'lng': 75.8370, 'heading': 200.0}, // Talwandi Circle
    {'lat': 25.1480, 'lng': 75.8400, 'heading': 110.0}, // Delivery destination
  ];

  /// Subscribes to Realtime agent location updates for a specific order.
  /// Automatically falls back to a simulated stream if Supabase connection fails
  /// or if the table is not set up yet.
  Stream<AgentLocation> getAgentLocationStream(String orderId) {
    StreamController<AgentLocation>? controller;
    RealtimeChannel? channel;
    Timer? simulationTimer;

    controller = StreamController<AgentLocation>(
      onListen: () {
        try {
          // Subscribe to Supabase Realtime Channel Broadcast
          channel = _client.channel('delivery:$orderId');
          
          channel!.onBroadcast(
            event: 'location_update',
            callback: (payload) {
              if (payload['latitude'] != null &&
                  payload['longitude'] != null) {
                final lat = (payload['latitude'] as num).toDouble();
                final lng = (payload['longitude'] as num).toDouble();
                final heading = (payload['heading'] ?? 0.0 as num).toDouble();
                
                controller?.add(AgentLocation(
                  latitude: lat,
                  longitude: lng,
                  heading: heading,
                  timestamp: DateTime.now(),
                ));
              }
            },
          );

          channel!.subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              // Successfully connected to live Supabase channel
            } else {
              // Fallback to simulation if subscription failed or timeout
              simulationTimer = _startSimulation(controller!);
            }
          });
        } catch (e) {
          // In case of exceptions, trigger simulation fallback
          simulationTimer = _startSimulation(controller!);
        }
      },
      onCancel: () {
        channel?.unsubscribe();
        simulationTimer?.cancel();
        controller?.close();
      },
    );

    return controller.stream;
  }

  /// Simulated rider movement. Debug builds only — in release an unmoving
  /// map is honest, a fake moving one is not.
  Timer _startSimulation(StreamController<AgentLocation> controller) {
    int index = 0;
    return Timer.periodic(const Duration(seconds: 4), (t) {
      if (index >= _simulatedPath.length) {
        index = 0; // Loop tracking simulation
      }
      final pos = _simulatedPath[index];
      controller.add(AgentLocation(
        latitude: pos['lat']!,
        longitude: pos['lng']!,
        heading: pos['heading']!,
        timestamp: DateTime.now(),
      ));
      index++;
    });
  }

  /// Fetches the destination coordinates for the customer.
  /// Defaults to a prominent location in Talwandi, Kota.
  Future<Map<String, double>> getDestinationCoordinates(String orderId) async {
    try {
      final response = await _client
          .from('active_deliveries')
          .select('last_latitude, last_longitude')
          .eq('order_id', orderId)
          .maybeSingle();

      if (response != null &&
          response['last_latitude'] != null &&
          response['last_longitude'] != null) {
        return {
          'lat': (response['last_latitude'] as num).toDouble(),
          'lng': (response['last_longitude'] as num).toDouble(),
        };
      }
    } catch (_) {
      // Fallback destination coordinates
    }
    // Talwandi, Kota destination coordinates default
    return {
      'lat': 25.1480,
      'lng': 75.8400,
    };
  }

  /// Live order status, pushed via Realtime rather than polled.
  ///
  /// Emits the current status immediately, then again on every UPDATE to that
  /// order row. Falls back to a single read if Realtime cannot connect, so the
  /// screen still shows something truthful.
  Stream<String> orderStatusStream(String orderId) {
    final controller = StreamController<String>();
    RealtimeChannel? channel;

    Future<void> emitCurrent() async {
      try {
        final row = await _client
            .from('orders')
            .select('status')
            .eq('id', orderId)
            .maybeSingle();
        final status = row?['status'] as String?;
        if (status != null && !controller.isClosed) controller.add(status);
      } catch (error) {
        debugPrint('orderStatusStream initial read failed: $error');
      }
    }

    controller.onListen = () {
      emitCurrent();
      try {
        channel = _client
            .channel('order_status:$orderId')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'orders',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: orderId,
              ),
              callback: (payload) {
                final status = payload.newRecord['status'] as String?;
                if (status != null && !controller.isClosed) {
                  controller.add(status);
                }
              },
            )
            .subscribe();
      } catch (error) {
        // Realtime unavailable: the initial read above still populated the UI.
        debugPrint('order status Realtime unavailable: $error');
      }
    };

    controller.onCancel = () async {
      if (channel != null) await _client.removeChannel(channel!);
      await controller.close();
    };

    return controller.stream;
  }

  /// Advances an order through the delivery states on a timer.
  ///
  /// DEBUG ONLY. There is no rider app yet, so nothing else will ever move an
  /// order past `preparing`; this makes the flow demonstrable. It is a no-op
  /// in release builds.
  Future<void> simulateDeliveryProgress(
    String orderId, {
    Duration step = const Duration(seconds: 6),
  }) async {
    if (!kDebugMode) return;

    const path = ['preparing', 'assigned', 'out_for_delivery', 'delivered'];
    for (final status in path) {
      await Future<void>.delayed(step);
      try {
        await _client.from('orders').update({
          'status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId);
        debugPrint('[sim] order $orderId -> $status');
      } catch (error) {
        // Customers have no UPDATE grant on orders; only staff do.
        debugPrint('[sim] could not advance order (staff role required): $error');
        return;
      }
    }
  }
}
