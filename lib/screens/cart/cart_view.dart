import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quick_med/blocs/cart_cubit/cart_cubit.dart';
import 'package:quick_med/models/cart_item_model.dart';
import 'package:quick_med/services/address_service.dart';
import 'package:quick_med/custom_components/primary_button.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/supabase_auth_bridge.dart';
import 'package:quick_med/services/order_service.dart';
import 'package:quick_med/utils/prescription_upload_flow.dart';

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
      await SupabaseAuthBridge.syncSessionFromFirebase(forceRefresh: true);
      final address = await _addresses.ensureDefault(uid);
      final placed = await _orders.placeOrder(
        lines: cart.lines,
        addressId: address.id,
      );

      if (!mounted) return;
      context.read<CartCubit>().clearCart();

      if (placed.needsPrescription) {
        final uploadNow = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Upload prescription'),
            content: const Text(
              'This order includes prescription medicine. '
              'Upload a clear photo of your doctor\'s prescription now '
              'so our team can review it.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Upload now'),
              ),
            ],
          ),
        );
        if (uploadNow == true && mounted) {
          await PrescriptionUploadFlow.run(
            context,
            orderId: placed.orderId,
          );
        } else {
          _toast(
            'Order placed. Upload your prescription from Profile when ready.',
          );
        }
      } else {
        _toast('Order placed. Total Rs ${placed.total.toStringAsFixed(2)}.');
      }
    } on SupabaseSessionException catch (e) {
      _toast(e.message);
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.brandGradientStart,
                    AppColors.brandGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Your cart',
                    style: AppTextStyles.title(context).copyWith(
                      color: AppColors.white,
                      fontSize: context.fs(22),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: context.fs(12),
                      ),
                    ),
                  ),
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
                size: 64, color: AppColors.brandTeal),
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
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
            color: AppColors.brandTeal,
          ),
        ),
        Text('${line.quantity}', style: text.titleMedium),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: line.quantity >= line.medicine.stockQty
              ? null
              : () => cubit.setQuantity(line.medicine.id, line.quantity + 1),
          icon: const Icon(Icons.add_circle_outline_rounded,
              size: AppIconSize.lg, color: AppColors.brandTeal),
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
                        ?.copyWith(color: AppColors.brandGreen)),
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
          PrimaryButton(
            label: _placing
                ? 'Placing order...'
                : 'Place order · Rs ${cart.subtotal.toStringAsFixed(2)}',
            enabled: !_placing,
            onTap: _placing ? null : () => _checkout(cart),
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
