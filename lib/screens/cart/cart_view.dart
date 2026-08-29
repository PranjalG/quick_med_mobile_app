import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quick_med/blocs/cart_cubit/cart_cubit.dart';
import 'package:quick_med/models/cart_item_model.dart';
import 'package:quick_med/services/address_service.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/order_service.dart';

/// The real cart.
///
/// Replaces the previous tab-3 screen, which was a live delivery map with a
/// hardcoded three-item list and duplicated live_tracking_screen.dart.
class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final OrderService _orders = OrderService();
  final AddressService _addresses = AddressService();

  bool _placing = false;

  Future<void> _checkout(CartState cart) async {
    final uid = AuthService.currentUserId;
    if (uid == null) {
      _toast('Please sign in to place an order.');
      return;
    }

    setState(() => _placing = true);
    try {
      final address = await _addresses.ensureDefault(uid);
      final placed = await _orders.placeOrder(
        lines: cart.lines,
        addressId: address.id,
      );

      if (!mounted) return;
      context.read<CartCubit>().clearCart();

      _toast(
        placed.needsPrescription
            ? 'Order placed. Upload your prescription so our doctors can review it.'
            : 'Order placed. Total Rs ${placed.total.toStringAsFixed(2)}.',
      );
    } on AddressException catch (e) {
      _toast(e.message);
    } on OrderException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Could not place the order. Please try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        if (cart.isEmpty) return _empty(text);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Row(
                children: [
                  Text('Your Cart', style: text.headlineSmall),
                  const Spacer(),
                  Text('${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                      style: text.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                itemCount: cart.lines.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _line(cart.lines[i], text),
              ),
            ),
            _summary(cart, text),
          ],
        );
      },
    );
  }

  Widget _empty(TextTheme text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 64, color: AppColors.secondaryBlue),
            const SizedBox(height: AppSpacing.lg),
            Text('Your cart is empty', style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Browse the catalogue and add medicines to get started.',
                style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _line(CartLine line, TextTheme text) {
    final m = line.medicine;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: text.titleSmall, maxLines: 2),
                const SizedBox(height: 2),
                Text(m.manufacturer, style: text.bodySmall, maxLines: 1),
                if (m.rxRequired) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('Prescription required',
                      style: text.labelSmall?.copyWith(color: AppColors.accent)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text('Rs ${line.lineTotal.toStringAsFixed(2)}',
                    style: text.titleMedium),
              ],
            ),
          ),
          _stepper(line, text),
        ],
      ),
    );
  }

  Widget _stepper(CartLine line, TextTheme text) {
    final cubit = context.read<CartCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () =>
              cubit.setQuantity(line.medicine.id, line.quantity - 1),
          icon: Icon(
            line.quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_circle_outline_rounded,
            size: AppIconSize.lg,
            color: AppColors.secondaryTeal,
          ),
        ),
        Text('${line.quantity}', style: text.titleMedium),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: line.quantity >= line.medicine.stockQty
              ? null
              : () => cubit.setQuantity(line.medicine.id, line.quantity + 1),
          icon: const Icon(Icons.add_circle_outline_rounded,
              size: AppIconSize.lg, color: AppColors.secondaryTeal),
        ),
      ],
    );
  }

  Widget _summary(CartState cart, TextTheme text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Subtotal', cart.subtotal, text),
          if (cart.savings > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('You save', style: text.bodyLarge),
                Text('Rs ${cart.savings.toStringAsFixed(2)}',
                    style: text.bodyLarge
                        ?.copyWith(color: AppColors.secondaryTeal)),
              ],
            ),
          ],
          if (cart.hasPrescriptionItem) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.assignment_outlined,
                    size: AppIconSize.sm, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Contains prescription medicine. Our doctors review it before dispatch.',
                    style: text.bodySmall?.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placing ? null : () => _checkout(cart),
              child: _placing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.white),
                    )
                  : Text('Place order  ·  Rs ${cart.subtotal.toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, TextTheme text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: text.titleSmall),
        Text('Rs ${value.toStringAsFixed(2)}', style: text.titleSmall),
      ],
    );
  }
}
