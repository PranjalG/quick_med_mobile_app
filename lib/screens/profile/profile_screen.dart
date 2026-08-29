import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/blocs/orders_cubit/orders_cubit.dart';
import 'package:quick_med/models/order_model.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final OrdersCubit _orders = OrdersCubit()..load();

  @override
  void dispose() {
    _orders.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header User Info Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String name = 'Guest';
                  String area = 'Kota';
                  String address = 'Kota, Rajasthan';
                  String phone = '';
                  String email = '';
                  
                  if (state is ProfileLoaded) {
                    name = state.profile.name;
                    area = state.profile.kotaArea;
                    address = state.profile.addressDetail.isEmpty 
                        ? '$area, Kota' 
                        : '${state.profile.addressDetail}, $area';
                    phone = state.profile.phone;
                    email = state.profile.email;
                  }

                  return Row(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.mail_outline, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    email,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (phone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        tooltip: 'Log Out',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Log Out'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await AuthService.signOut();
                            if (context.mounted) {
                              context.read<ProfileCubit>().clearProfile();
                              context.go('/login');
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Order History Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Order History",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Orders List
            Expanded(
              child: BlocProvider.value(
                value: _orders,
                child: BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, state) {
                    return switch (state) {
                      OrdersInitial() || OrdersLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      OrdersEmpty() => _ordersMessage(
                          icon: Icons.receipt_long_outlined,
                          title: 'No orders yet',
                          body: 'Your orders will appear here once you place one.',
                        ),
                      OrdersFailure(:final message) => _ordersMessage(
                          icon: Icons.cloud_off_rounded,
                          title: 'Could not load orders',
                          body: message,
                          onRetry: _orders.refresh,
                        ),
                      OrdersLoaded(:final orders) => RefreshIndicator(
                          onRefresh: _orders.refresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: orders.length,
                            itemBuilder: (context, i) => _orderCard(orders[i]),
                          ),
                        ),
                    };
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ordersMessage({
    required IconData icon,
    required String title,
    required String body,
    VoidCallback? onRetry,
  }) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.secondaryBlue),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(body,
                style: text.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 4),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusTint(String status) => switch (status) {
        'delivered' => AppColors.success,
        'rejected' || 'cancelled' => AppColors.error,
        'awaiting_rx' || 'under_review' => AppColors.accent,
        _ => AppColors.primaryDark,
      };

  Widget _orderCard(CustomerOrder order) {
    final text = Theme.of(context).textTheme;
    final tint = _statusTint(order.status);
    final date = order.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.reference, style: text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(order.statusLabel,
                    style: text.labelSmall?.copyWith(
                        color: tint, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(order.itemSummary,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (order.requiresPrescription) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.assignment_outlined,
                    size: AppIconSize.sm, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Text('Prescription required',
                    style: text.labelSmall?.copyWith(color: AppColors.accent)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rs ${order.totalAmount.toStringAsFixed(2)}',
                  style: text.titleMedium),
              Text(
                date == null
                    ? ''
                    : '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: text.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
