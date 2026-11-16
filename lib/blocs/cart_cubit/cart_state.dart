part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<CartLine> lines;

  const CartState({this.lines = const []});

  bool get isEmpty => lines.isEmpty;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  double get subtotal => lines.fold(0.0, (sum, l) => sum + l.lineTotal);

  /// Total the customer would have paid at MRP — used for the "you saved" line.
  double get mrpTotal =>
      lines.fold(0.0, (sum, l) => sum + (l.medicine.mrp * l.quantity));

  double get savings => mrpTotal - subtotal;

  bool get hasPrescriptionItem => lines.any((l) => l.medicine.rxRequired);

  CartState copyWith({List<CartLine>? lines}) =>
      CartState(lines: lines ?? this.lines);

  @override
  List<Object?> get props => [lines];
}
