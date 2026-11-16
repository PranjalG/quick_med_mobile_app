import 'package:flutter/material.dart';

import 'package:quick_med/models/order_model.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_theme.dart';

/// Vertical progress timeline for an order's lifecycle.
///
/// Driven by `orders.status`, which the CHECK constraint limits to ten values.
/// `rejected` and `cancelled` end the journey rather than sitting on it, so
/// they render as a single terminal row instead of a path.
class OrderStatusTimeline extends StatelessWidget {
  final String status;

  const OrderStatusTimeline({super.key, required this.status});

  static const _labels = {
    'placed': 'Order placed',
    'awaiting_rx': 'Prescription needed',
    'under_review': 'Doctor reviewing',
    'approved': 'Approved',
    'preparing': 'Pharmacy preparing',
    'assigned': 'Rider assigned',
    'out_for_delivery': 'Out for delivery',
    'delivered': 'Delivered',
  };

  bool get _isTerminalFailure => status == 'rejected' || status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (_isTerminalFailure) {
      final rejected = status == 'rejected';
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                rejected
                    ? 'Prescription rejected. No charge has been made.'
                    : 'Order cancelled.',
                style: text.bodyLarge?.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    // An order without prescription medicine never passes through the two
    // review states, so they are dropped from its path entirely.
    final path = CustomerOrder.happyPath.where((s) {
      if (s == 'awaiting_rx' || s == 'under_review') {
        return _reviewRelevant;
      }
      return true;
    }).toList();

    final currentIndex = path.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < path.length; i++)
          _step(
            text: text,
            label: _labels[path[i]] ?? path[i],
            done: currentIndex >= 0 && i < currentIndex,
            current: i == currentIndex,
            isLast: i == path.length - 1,
          ),
      ],
    );
  }

  bool get _reviewRelevant =>
      status == 'awaiting_rx' ||
      status == 'under_review' ||
      CustomerOrder.happyPath.indexOf(status) >
          CustomerOrder.happyPath.indexOf('under_review');

  Widget _step({
    required TextTheme text,
    required String label,
    required bool done,
    required bool current,
    required bool isLast,
  }) {
    final active = done || current;
    final tint = current
        ? AppColors.secondaryTeal
        : done
            ? AppColors.primaryDark
            : AppColors.neutralLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: active ? tint : Colors.transparent,
                  border: Border.all(color: tint, width: 2),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check,
                        size: 12, color: AppColors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? AppColors.primaryDark : AppColors.neutralLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
            child: Text(
              label,
              style: current
                  ? text.titleSmall?.copyWith(color: AppColors.secondaryTeal)
                  : text.bodyLarge?.copyWith(
                      color: done ? AppColors.textPrimary : AppColors.neutral,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
