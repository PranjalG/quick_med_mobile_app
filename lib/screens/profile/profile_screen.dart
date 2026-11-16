import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/orders_cubit/orders_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/constants/kota_areas.dart';
import 'package:quick_med/custom_components/custom_text_field.dart';
import 'package:quick_med/custom_components/delivery_location_picker.dart';
import 'package:quick_med/custom_components/primary_button.dart';
import 'package:quick_med/models/order_model.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/profile_service.dart';
import 'package:quick_med/utils/prescription_upload_flow.dart';
import 'package:quick_med/utils/screen_size.dart';

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
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery details updated'),
              backgroundColor: AppColors.brandGreen,
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final isSaving = profileState is ProfileUpdating;

            return RefreshIndicator(
              color: AppColors.brandTeal,
              onRefresh: () async {
                final uid = AuthService.currentUserId;
                if (uid != null) {
                  await context.read<ProfileCubit>().loadProfile(uid);
                }
                await _orders.refresh();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _profileHeader(context, profileState)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.sm,
                      ),
                      child: _deliveryCard(
                        context,
                        profileState,
                        isSaving: isSaving,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        'Order history',
                        style: AppTextStyles.homeSectionHeader(context),
                      ),
                    ),
                  ),
                  _ordersSliver(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () => _confirmLogout(context),
                          child: Text(
                            'Log out',
                            style: AppTextStyles.body(context).copyWith(
                              color: AppColors.textSecondary,
                              fontSize: context.fs(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, ProfileState state) {
    String name = 'Guest';
    String phone = AuthService.currentUserPhone ?? '';

    if (state is ProfileLoaded) {
      name = state.profile.name.isNotEmpty ? state.profile.name : 'Guest';
      phone = state.profile.phone.isNotEmpty
          ? state.profile.phone
          : (AuthService.currentUserPhone ?? '');
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandGradientStart,
            AppColors.brandGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: AppColors.brandTeal,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.title(context).copyWith(
                        color: AppColors.white,
                        fontSize: context.fs(20),
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: context.fs(13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryCard(
    BuildContext context,
    ProfileState state, {
    required bool isSaving,
  }) {
    UserProfile? profile;
    if (state is ProfileLoaded) {
      profile = state.profile;
    }

    final area = profile?.kotaArea ?? 'Kota';
    final detail = profile?.addressDetail ?? '';
    final hasAddress = detail.isNotEmpty || area.isNotEmpty;
    final hasCoords = profile?.hasDeliveryCoordinates ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: context.fs(20),
                color: AppColors.brandTeal,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Delivery address',
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: context.fs(16),
                  ),
                ),
              ),
              TextButton(
                onPressed: isSaving || profile == null
                    ? null
                    : () => _openEditSheet(context, profile!),
                child: Text(
                  hasAddress ? 'Edit' : 'Add',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.brandGreenDeep,
                    fontWeight: FontWeight.bold,
                    fontSize: context.fs(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!hasAddress)
            Text(
              'Add your Kota area, street details, and map pin for faster delivery.',
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.isNotEmpty ? '$area, Kota' : 'Kota',
                    style: AppTextStyles.body(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandGreenDeep,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (hasCoords) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined,
                          size: context.fs(16),
                          color: AppColors.brandTeal,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${profile!.addressLatitude!.toStringAsFixed(5)}, '
                            '${profile.addressLongitude!.toStringAsFixed(5)}',
                            style: AppTextStyles.body(context).copyWith(
                              fontSize: context.fs(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Map pin missing — edit to add delivery coordinates.',
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: context.fs(12),
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (isSaving) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(
              color: AppColors.brandTeal,
              backgroundColor: AppColors.inputBorder,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openEditSheet(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _EditDeliverySheet(
          initial: profile,
          onSave: (updated) {
            context.read<ProfileCubit>().saveProfile(updated);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  Widget _ordersSliver(BuildContext context) {
    return BlocProvider.value(
      value: _orders,
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          return switch (state) {
            OrdersInitial() || OrdersLoading() => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brandTeal),
                ),
              ),
            OrdersEmpty() => SliverFillRemaining(
                hasScrollBody: false,
                child: _ordersMessage(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  body: 'Your orders will appear here once you place one.',
                ),
              ),
            OrdersFailure(:final message) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ordersMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load orders',
                  body: message,
                  onRetry: _orders.refresh,
                ),
              ),
            OrdersLoaded(:final orders) => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _orderCard(orders[i]),
                    childCount: orders.length,
                  ),
                ),
              ),
          };
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to order medicines.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log out',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
  }

  Widget _ordersMessage({
    required IconData icon,
    required String title,
    required String body,
    VoidCallback? onRetry,
  }) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.brandTeal),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: text.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(color: AppColors.brandGreenDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusTint(String status) => switch (status) {
        'delivered' => AppColors.brandGreen,
        'rejected' || 'cancelled' => AppColors.error,
        'awaiting_rx' || 'under_review' => AppColors.accent,
        _ => AppColors.brandTeal,
      };

  Widget _orderCard(CustomerOrder order) {
    final text = Theme.of(context).textTheme;
    final tint = _statusTint(order.status);
    final date = order.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.reference,
                style: text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  order.statusLabel,
                  style: text.labelSmall?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.itemSummary,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (order.requiresPrescription) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: AppIconSize.sm,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Prescription required',
                  style: text.labelSmall?.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ],
          if (order.needsPrescriptionUpload) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await PrescriptionUploadFlow.run(
                    context,
                    orderId: order.id,
                  );
                  if (mounted) _orders.refresh();
                },
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: const Text('Upload prescription'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs ${order.totalAmount.toStringAsFixed(2)}',
                style:
                    text.titleMedium?.copyWith(color: AppColors.brandGreenDeep),
              ),
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

class _EditDeliverySheet extends StatefulWidget {
  final UserProfile initial;
  final ValueChanged<UserProfile> onSave;

  const _EditDeliverySheet({
    required this.initial,
    required this.onSave,
  });

  @override
  State<_EditDeliverySheet> createState() => _EditDeliverySheetState();
}

class _EditDeliverySheetState extends State<_EditDeliverySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  String? _selectedArea;
  double? _latitude;
  double? _longitude;
  String? _locationValidationError;

  @override
  void initState() {
    super.initState();
    _addressController =
        TextEditingController(text: widget.initial.addressDetail);
    final area = widget.initial.kotaArea;
    _selectedArea = kotaAreas.contains(area) ? area : null;
    _latitude = widget.initial.addressLatitude;
    _longitude = widget.initial.addressLongitude;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final hasCoords = _latitude != null && _longitude != null;
    setState(() {
      _locationValidationError = hasCoords
          ? null
          : 'Pin your delivery location on the map before saving.';
    });
    if (!_formKey.currentState!.validate() || !hasCoords) return;

    widget.onSave(
      widget.initial.copyWith(
        kotaArea: _selectedArea ?? widget.initial.kotaArea,
        addressDetail: _addressController.text.trim(),
        addressLatitude: _latitude,
        addressLongitude: _longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl + bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: context.fs(16)),
            Text(
              'Edit delivery address',
              style: AppTextStyles.title(context),
            ),
            SizedBox(height: context.fs(8)),
            Text(
              'Orders are delivered within Kota city.',
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.fs(20)),
            DropdownButtonFormField<String>(
              value: _selectedArea,
              hint: Text(
                'Select area in Kota',
                style: AppTextStyles.hintText(context),
              ),
              decoration: InputDecoration(
                labelText: 'Kota area',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: kotaAreas
                  .map(
                    (area) => DropdownMenuItem(
                      value: area,
                      child: Text(area, style: AppTextStyles.inputText(context)),
                    ),
                  )
                  .toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your area';
                }
                return null;
              },
              onChanged: (value) => setState(() => _selectedArea = value),
            ),
            SizedBox(height: context.fs(16)),
            CustomTextField(
              controller: _addressController,
              labelText: 'Flat / street / landmark',
              hintText: 'e.g. 12, Station Road, near City Mall',
              maxLines: 3,
              prefixIcon: const Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your delivery address';
                }
                if (value.trim().length < 5) {
                  return 'Address must be at least 5 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.fs(16)),
            DeliveryLocationPicker(
              latitude: _latitude,
              longitude: _longitude,
              errorText: _locationValidationError,
              onLocationChanged: (latLng) {
                setState(() {
                  _latitude = latLng.latitude;
                  _longitude = latLng.longitude;
                  _locationValidationError = null;
                });
              },
            ),
            SizedBox(height: context.fs(24)),
            PrimaryButton(
              label: 'Save address',
              onTap: _submit,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
