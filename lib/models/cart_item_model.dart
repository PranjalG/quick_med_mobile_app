import 'package:quick_med/models/medicine_model.dart';

class CartLine {
  final Medicine medicine;
  final int quantity;

  const CartLine({required this.medicine, required this.quantity});

  double get lineTotal => medicine.price * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(medicine: medicine, quantity: quantity ?? this.quantity);

  /// Shape the `place_order` RPC expects. Deliberately carries no price:
  /// the server re-reads it, and anything sent here would be ignored.
  Map<String, dynamic> toRpcJson() => {
        'medicine_id': medicine.id,
        'quantity': quantity,
      };
}
