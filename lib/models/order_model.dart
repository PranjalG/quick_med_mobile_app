class OrderItemLine {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double priceAtOrder;

  const OrderItemLine({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.priceAtOrder,
  });

  double get lineTotal => priceAtOrder * quantity;

  /// Built from a PostgREST row with `medicines(name)` embedded.
  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    final med = json['medicines'];
    return OrderItemLine(
      medicineId: json['medicine_id'] as String? ?? '',
      medicineName: med is Map<String, dynamic>
          ? (med['name'] as String? ?? 'Unknown medicine')
          : 'Unknown medicine',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      priceAtOrder: (json['price_at_order'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CustomerOrder {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime? createdAt;
  final bool requiresPrescription;
  final List<OrderItemLine> items;

  const CustomerOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.createdAt,
    this.requiresPrescription = false,
    this.items = const [],
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final raw = json['order_items'] as List<dynamic>? ?? const [];
    return CustomerOrder(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'placed',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      items: raw
          .map((e) => OrderItemLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Short human-facing reference. Order ids are uuids; showing the whole
  /// thing is unreadable, and there is no separate order-number column.
  String get reference => '#${id.substring(0, 8).toUpperCase()}';

  String get itemSummary => items.isEmpty
      ? 'No items'
      : items.map((i) => i.medicineName).join(', ');

  bool get isTerminal => status == 'delivered' || status == 'cancelled';

  bool get needsPrescriptionUpload => status == 'awaiting_rx';

  /// Label for each of the ten lifecycle states in the orders CHECK constraint.
  String get statusLabel => switch (status) {
        'placed' => 'Placed',
        'awaiting_rx' => 'Prescription needed',
        'under_review' => 'Under review',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        'preparing' => 'Preparing',
        'assigned' => 'Rider assigned',
        'out_for_delivery' => 'Out for delivery',
        'delivered' => 'Delivered',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  /// Ordered lifecycle for the detail-view timeline. Terminal failure states
  /// are excluded: they end the journey rather than sitting on it.
  static const List<String> happyPath = [
    'placed',
    'awaiting_rx',
    'under_review',
    'approved',
    'preparing',
    'assigned',
    'out_for_delivery',
    'delivered',
  ];
}
