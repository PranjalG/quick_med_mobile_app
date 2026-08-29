import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:quick_med/models/cart_item_model.dart';
import 'package:quick_med/models/order_model.dart';

/// Result of a successful `place_order` call.
class PlacedOrder {
  final String orderId;
  final double total;
  final String status;

  const PlacedOrder({
    required this.orderId,
    required this.total,
    required this.status,
  });

  /// The order is parked until a prescription is uploaded and reviewed.
  bool get needsPrescription => status == 'awaiting_rx';
}

/// Raised when the server rejects a checkout for a reason worth showing.
class OrderException implements Exception {
  final String message;
  const OrderException(this.message);

  @override
  String toString() => message;
}

class OrderService {
  OrderService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Places an order through the `place_order` RPC.
  ///
  /// No price or total is sent: the function re-reads both from `medicines`.
  /// Clients have no INSERT grant on `orders`/`order_items`, so this is the
  /// only way an order can come into existence.
  Future<PlacedOrder> placeOrder({
    required List<CartLine> lines,
    required String addressId,
  }) async {
    if (lines.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }

    try {
      final List<dynamic> rows = await _client.rpc(
        'place_order',
        params: {
          'items': lines.map((l) => l.toRpcJson()).toList(),
          'address_id': addressId,
        },
      );

      if (rows.isEmpty) {
        throw const OrderException('The order could not be created.');
      }

      final row = rows.first as Map<String, dynamic>;
      return PlacedOrder(
        orderId: row['order_id'] as String,
        total: (row['total'] as num?)?.toDouble() ?? 0,
        status: row['status'] as String? ?? 'placed',
      );
    } on PostgrestException catch (error) {
      debugPrint('place_order failed: ${error.code} ${error.message}');
      throw OrderException(_friendly(error));
    }
  }

  /// Maps the RPC's SQLSTATE codes onto something a customer can act on.
  String _friendly(PostgrestException error) {
    final raw = error.message;
    return switch (error.code) {
      '28000' => 'Please sign in again to place this order.',
      '22023' => raw.contains('cart is empty')
          ? 'Your cart is empty.'
          : 'Something in your cart is invalid.',
      '42501' => 'That delivery address is not available. Pick another.',
      '23503' => 'A medicine in your cart is no longer available.',
      // The RPC formats this one with the medicine name and counts.
      '23514' => raw,
      'PGRST202' =>
        'Checkout is unavailable — run supabase/migrations/006_place_order.sql.',
      _ => raw.isNotEmpty ? raw : 'Could not place the order. Please try again.',
    };
  }

  /// Orders for the signed-in user, newest first, with line items and the
  /// medicine names embedded — one round trip, not one query per order.
  ///
  /// RLS scopes this to the caller; no user_id filter is needed or trusted.
  Future<List<CustomerOrder>> fetchOrders({int limit = 20, int offset = 0}) async {
    final List<dynamic> rows = await _client
        .from('orders')
        .select(
          'id, status, total_amount, created_at, requires_prescription, '
          'order_items(medicine_id, quantity, price_at_order, medicines(name))',
        )
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return rows
        .map((r) => CustomerOrder.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerOrder?> fetchOrder(String orderId) async {
    final row = await _client
        .from('orders')
        .select(
          'id, status, total_amount, created_at, requires_prescription, '
          'order_items(medicine_id, quantity, price_at_order, medicines(name))',
        )
        .eq('id', orderId)
        .maybeSingle();
    return row == null ? null : CustomerOrder.fromJson(row);
  }
}
