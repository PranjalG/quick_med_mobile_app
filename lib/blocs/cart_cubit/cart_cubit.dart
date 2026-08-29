import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:quick_med/models/cart_item_model.dart';
import 'package:quick_med/models/medicine_model.dart';

part 'cart_state.dart';

/// Cart, persisted across restarts via hydrated_bloc.
///
/// Prices are stored alongside each line only so the cart can render offline.
/// They are never sent to `place_order` — the server re-reads them — so a
/// stale cached price cannot become a stale charge.
class CartCubit extends HydratedCubit<CartState> {
  CartCubit() : super(const CartState());

  /// Adds [medicine], or increases its quantity if already present.
  ///
  /// Refuses to exceed available stock — the server enforces this too, but
  /// failing here means the customer finds out before checkout, not after.
  void add(Medicine medicine, {int quantity = 1}) {
    if (medicine.isOutOfStock) return;

    final lines = [...state.lines];
    final i = lines.indexWhere((l) => l.medicine.id == medicine.id);

    if (i == -1) {
      lines.add(CartLine(
        medicine: medicine,
        quantity: quantity.clamp(1, medicine.stockQty),
      ));
    } else {
      final next = (lines[i].quantity + quantity).clamp(1, medicine.stockQty);
      lines[i] = lines[i].copyWith(quantity: next);
    }
    emit(state.copyWith(lines: lines));
  }

  void setQuantity(String medicineId, int quantity) {
    final lines = [...state.lines];
    final i = lines.indexWhere((l) => l.medicine.id == medicineId);
    if (i == -1) return;

    if (quantity <= 0) {
      lines.removeAt(i);
    } else {
      lines[i] =
          lines[i].copyWith(quantity: quantity.clamp(1, lines[i].medicine.stockQty));
    }
    emit(state.copyWith(lines: lines));
  }

  void remove(String medicineId) {
    emit(state.copyWith(
      lines: state.lines.where((l) => l.medicine.id != medicineId).toList(),
    ));
  }

  /// Empties the cart. Named `clearCart` rather than `clear` because
  /// HydratedMixin already defines `clear()` to drop persisted storage;
  /// the emit below is persisted automatically.
  void clearCart() => emit(const CartState());

  int quantityOf(String medicineId) {
    for (final l in state.lines) {
      if (l.medicine.id == medicineId) return l.quantity;
    }
    return 0;
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final raw = json['lines'] as List<dynamic>? ?? const [];
      return CartState(
        lines: raw
            .map((e) => CartLine(
                  medicine:
                      Medicine.fromJson(e['medicine'] as Map<String, dynamic>),
                  quantity: (e['quantity'] as num?)?.toInt() ?? 1,
                ))
            .toList(),
      );
    } catch (error) {
      // A malformed cache must never stop the app booting.
      debugPrint('CartCubit.fromJson failed, starting empty: $error');
      return const CartState();
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) => {
        'lines': state.lines
            .map((l) => {
                  'medicine': l.medicine.toJson(),
                  'quantity': l.quantity,
                })
            .toList(),
      };
}
