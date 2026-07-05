class Medicine {
  final String id;
  final String name;
  final String salt;
  final double mrp;
  final double price;
  final String discount;
  final String deliveryTime;
  final bool rxRequired;
  bool isFavorite;

  Medicine({
    required this.id,
    required this.name,
    required this.salt,
    required this.mrp,
    required this.price,
    required this.discount,
    required this.deliveryTime,
    this.rxRequired = false,
    this.isFavorite = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      salt: json['salt'] as String? ?? '',
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: json['discount'] as String? ?? '0% OFF',
      deliveryTime: json['delivery_time'] as String? ?? '30 min delivery',
      rxRequired: json['rx_required'] as bool? ?? false,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'salt': salt,
      'mrp': mrp,
      'price': price,
      'discount': discount,
      'delivery_time': deliveryTime,
      'rx_required': rxRequired,
    };
  }
}
