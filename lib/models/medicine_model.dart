class Medicine {
  final String id;
  final String name;
  final String saltId;
  final String manufacturer;
  final double mrp;
  final double price;
  final String discount;
  final String deliveryTime;
  final bool rxRequired;
  bool isFavorite;

  Medicine({
    required this.id,
    required this.name,
    required this.saltId,
    required this.manufacturer,
    required this.mrp,
    required this.price,
    required this.discount,
    required this.deliveryTime,
    this.rxRequired = false,
    this.isFavorite = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final double mrpVal = (json['mrp'] as num?)?.toDouble() ?? 0.0;
    final double priceVal = (json['discounted_price'] as num?)?.toDouble() ?? 0.0;
    
    // Calculate discount percentage dynamically based on MRP and discounted price
    int discountPct = 0;
    if (mrpVal > 0 && mrpVal > priceVal) {
      discountPct = (((mrpVal - priceVal) / mrpVal) * 100).round();
    }
    final discountStr = discountPct > 0 ? '$discountPct% OFF' : '0% OFF';

    return Medicine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      saltId: json['salt_id'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
      mrp: mrpVal,
      price: priceVal,
      discount: discountStr,
      deliveryTime: '30 min delivery',
      rxRequired: json['prescription_required'] as bool? ?? false,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'salt_id': saltId,
      'manufacturer': manufacturer,
      'mrp': mrp,
      'discounted_price': price,
      'prescription_required': rxRequired,
    };
  }
}
