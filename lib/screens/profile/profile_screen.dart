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
import 'package:quick_med/services/geocoding_service.dart';
import 'package:quick_med/services/profile_service.dart';
import 'package:quick_med/services/strings.dart';
import 'package:quick_med/utils/prescription_upload_flow.dart';
import 'package:quick_med/utils/screen_size.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final OrdersCubit _orders = OrdersCubit()..load();

  /// Last profile shown, so a save or a failed reload does not blank the
  /// header and address card.
  UserProfile? _lastProfile;

  @override
  void dispose() {
    _orders.close();
    super.dispose();
  }

  UserProfile? _profileFrom(ProfileState state) => switch (state) {
        ProfileLoaded(:final profile) => profile,
        ProfileUpdateSuccess(:final profile) => profile,
        ProfileUpdating(:final profile) => profile ?? _lastProfile,
        _ => _lastProfile,
      };

  Future<void> _onRefresh() async {
    final uid = AuthService.currentUserId;
    await Future.wait([
      if (uid != null) context.read<ProfileCubit>().refreshProfile(uid),
      _orders.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.savedToServer
                    ? 'Delivery address saved'
                    : 'Saved on this phone only — we could not reach the '
                        'server, so this address can\'t be used for orders yet.',
              ),
              backgroundColor: state.savedToServer
                  ? AppColors.brandGreenDeep
                  : AppColors.accent,
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
            final profile = _profileFrom(profileState);
            if (profile != null) _lastProfile = profile;

            return RefreshIndicator(
              color: AppColors.brandTeal,
              backgroundColor: AppColors.white,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.sm,
                      ),
                      child: _DeliveryCard(
                        profile: profile,
                        isSaving: isSaving,
                        onEdit: profile == null || isSaving
                            ? null
                            : () => _openEditSheet(context, profile),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.md,
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
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context),
                        icon: Icon(
                          Icons.logout_rounded,
                          size: context.fs(18),
                          color: AppColors.error,
                        ),
                        label: Text(
                          'Log out',
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: context.fs(14),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(context.fs(48)),
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.fs(14)),
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

  Future<void> _openEditSheet(BuildContext context, UserProfile profile) async {
    final cubit = context.read<ProfileCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.scaffoldBackground,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return _EditDeliverySheet(
          initial: profile,
          onSave: (updated) {
            cubit.saveProfile(updated);
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
            OrdersInitial() || OrdersLoading() => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.brandTeal),
                  ),
                ),
              ),
            OrdersEmpty() => SliverToBoxAdapter(
                child: _ordersMessage(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  body: 'Your orders will appear here once you place one.',
                ),
              ),
            OrdersFailure(:final message) => SliverToBoxAdapter(
                child: _ordersMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load orders',
                  body: message,
                  onRetry: _orders.refresh,
                ),
              ),
            OrdersLoaded(:final orders) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
        content:
            const Text('You will need to sign in again to order medicines.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.xl, color: AppColors.brandTeal),
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
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: const Text(
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

  IconData _statusIcon(String status) => switch (status) {
        'delivered' => Icons.check_circle_outline_rounded,
        'rejected' || 'cancelled' => Icons.cancel_outlined,
        'awaiting_rx' || 'under_review' => Icons.assignment_outlined,
        _ => Icons.local_shipping_outlined,
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
            color: AppColors.secondaryNavy.withValues(alpha: 0.05),
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
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  _statusIcon(order.status),
                  size: AppIconSize.md,
                  color: tint,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.reference,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (date != null)
                      Text(
                        '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/${date.year}',
                        style: text.bodySmall,
                      ),
                  ],
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
          const SizedBox(height: AppSpacing.md),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            children: [
              Text(
                '${Strings.rupeeSymbol}${order.totalAmount.toStringAsFixed(2)}',
                style:
                    text.titleMedium?.copyWith(color: AppColors.brandGreenDeep),
              ),
              const Spacer(),
              if (order.needsPrescriptionUpload)
                TextButton.icon(
                  onPressed: () async {
                    await PrescriptionUploadFlow.run(
                      context,
                      orderId: order.id,
                    );
                    if (mounted) _orders.refresh();
                  },
                  icon: const Icon(
                    Icons.upload_file_outlined,
                    size: AppIconSize.md,
                    color: AppColors.brandTeal,
                  ),
                  label: const Text(
                    'Upload prescription',
                    style: TextStyle(color: AppColors.brandGreenDeep),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gradient header with an initials avatar, name and phone number.
class _ProfileHeader extends StatelessWidget {
  final UserProfile? profile;

  const _ProfileHeader({required this.profile});

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile?.name.trim().isNotEmpty ?? false)
        ? profile!.name.trim()
        : 'Guest';
    final phone = (profile?.phone.isNotEmpty ?? false)
        ? profile!.phone
        : (AuthService.currentUserPhone ?? '');
    final initials = name == 'Guest' ? '' : _initials(name);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandGradientStart, AppColors.brandGradientEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My profile',
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: context.fs(13),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    height: context.fs(64),
                    width: context.fs(64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: initials.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: context.fs(34),
                            color: AppColors.brandTeal,
                          )
                        : Text(
                            initials,
                            style: AppTextStyles.title(context).copyWith(
                              color: AppColors.brandGreenDeep,
                              fontSize: context.fs(22),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title(context).copyWith(
                            color: AppColors.white,
                            fontSize: context.fs(20),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_iphone_rounded,
                                size: context.fs(15),
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                phone,
                                style: AppTextStyles.body(context).copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: context.fs(13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Delivery address summary, with a status that tells the user whether the
/// address is complete enough to place an order.
class _DeliveryCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isSaving;
  final VoidCallback? onEdit;

  const _DeliveryCard({
    required this.profile,
    required this.isSaving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Login stores the city ("Kota") as a placeholder area; only a real
    // neighbourhood from the list counts as a chosen area.
    final rawArea = profile?.kotaArea.trim() ?? '';
    final area = kotaAreas.contains(rawArea) ? rawArea : '';
    final detail = profile?.addressDetail.trim() ?? '';
    final hasAddress = area.isNotEmpty || detail.isNotEmpty;
    final hasPin = profile?.hasDeliveryCoordinates ?? false;
    final isReady = area.isNotEmpty && detail.isNotEmpty && hasPin;

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
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: AppIconSize.md,
                  color: AppColors.brandTeal,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery address',
                      style: AppTextStyles.title(context).copyWith(
                        fontSize: context.fs(16),
                      ),
                    ),
                    if (hasAddress) ...[
                      const SizedBox(height: 2),
                      _StatusBadge(isReady: isReady),
                    ],
                  ],
                ),
              ),
              if (hasAddress)
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, context.fs(36)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    side: const BorderSide(color: AppColors.brandTeal),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Edit',
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.brandGreenDeep,
                      fontWeight: FontWeight.w700,
                      fontSize: context.fs(13),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!hasAddress) ...[
            Text(
              'Add your area, house details and a map pin so riders can find '
              'you quickly.',
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Add delivery address',
              onTap: onEdit,
              enabled: onEdit != null,
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  if (detail.isNotEmpty) const SizedBox(height: 2),
                  Text(
                    area.isNotEmpty ? '$area, Kota' : 'Area not selected',
                    style: AppTextStyles.body(context).copyWith(
                      color: area.isNotEmpty
                          ? AppColors.textSecondary
                          : AppColors.accent,
                      fontSize: context.fs(13),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        hasPin
                            ? Icons.where_to_vote_rounded
                            : Icons.wrong_location_outlined,
                        size: AppIconSize.sm,
                        color: hasPin ? AppColors.brandGreen : AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          hasPin
                              ? 'Location pinned on map'
                              : 'Map pin missing — tap Edit to pin your location',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: context.fs(12),
                            color: hasPin
                                ? AppColors.brandGreenDeep
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (isSaving) ...[
            const SizedBox(height: AppSpacing.md),
            const ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                color: AppColors.brandTeal,
                backgroundColor: AppColors.inputBorder,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isReady;

  const _StatusBadge({required this.isReady});

  @override
  Widget build(BuildContext context) {
    final tint = isReady ? AppColors.brandGreen : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        isReady ? 'Ready for delivery' : 'Incomplete',
        style: AppTextStyles.body(context).copyWith(
          color: isReady ? AppColors.brandGreenDeep : AppColors.accent,
          fontWeight: FontWeight.w600,
          fontSize: context.fs(11),
        ),
      ),
    );
  }
}

/// Bottom sheet for editing the delivery address.
///
/// The header and the Save button stay fixed; only the form between them
/// scrolls, so the main action is always reachable — including with the
/// keyboard open.
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

  // Values filled in from the map pin. Moving the pin may replace these, but
  // never something the user typed or picked themselves.
  String? _autoFilledStreet;
  String? _autoSelectedArea;

  void _applyResolvedAddress(ResolvedAddress address) {
    setState(() {
      final typed = _addressController.text.trim();
      if (address.streetLine.isNotEmpty &&
          (typed.isEmpty || typed == _autoFilledStreet)) {
        _addressController.text = address.streetLine;
        _autoFilledStreet = address.streetLine;
      }
      final match = address.matchArea(kotaAreas);
      if (match != null &&
          (_selectedArea == null || _selectedArea == _autoSelectedArea)) {
        _selectedArea = match;
        _autoSelectedArea = match;
      }
    });
  }

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
    final formValid = _formKey.currentState!.validate();
    if (!formValid || !hasCoords) return;

    widget.onSave(
      widget.initial.copyWith(
        kotaArea: _selectedArea,
        addressDetail: _addressController.text.trim(),
        addressLatitude: _latitude,
        addressLongitude: _longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      // Lift the whole sheet above the keyboard; the body shrinks to fit.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(step: 1, title: 'Your area'),
                      const SizedBox(height: AppSpacing.md),
                      _buildAreaChips(context),
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionTitle(step: 2, title: 'House & street'),
                      const SizedBox(height: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionTitle(step: 3, title: 'Pin on map'),
                      const SizedBox(height: AppSpacing.md),
                      DeliveryLocationPicker(
                        latitude: _latitude,
                        longitude: _longitude,
                        errorText: _locationValidationError,
                        onAddressResolved: _applyResolvedAddress,
                        onLocationChanged: (latLng) {
                          setState(() {
                            _latitude = latLng.latitude;
                            _longitude = latLng.longitude;
                            _locationValidationError = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery address',
                      style: AppTextStyles.title(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We currently deliver within Kota city.',
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: context.fs(13),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChips(BuildContext context) {
    return FormField<String>(
      initialValue: _selectedArea,
      validator: (_) => (_selectedArea == null || _selectedArea!.isEmpty)
          ? 'Please select your area'
          : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final area in kotaAreas)
                  _AreaChip(
                    label: area,
                    selected: _selectedArea == area,
                    onTap: () {
                      setState(() => _selectedArea = area);
                      field.didChange(area);
                    },
                  ),
              ],
            ),
            if (field.hasError) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                field.errorText!,
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.error,
                  fontSize: context.fs(12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: PrimaryButton(label: 'Save address', onTap: _submit),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int step;
  final String title;

  const _SectionTitle({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: context.fs(24),
          width: context.fs(24),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.brandTeal,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: context.fs(12),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.body(context).copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: context.fs(15),
          ),
        ),
      ],
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.brandTeal.withValues(alpha: 0.12)
          : AppColors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.brandTeal : AppColors.inputBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check_rounded,
                  size: context.fs(16),
                  color: AppColors.brandTeal,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: context.fs(13),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.brandGreenDeep
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
