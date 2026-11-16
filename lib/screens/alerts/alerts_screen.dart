import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/models/app_alert.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/utils/screen_size.dart';

/// Alerts & offers inbox. Push (FCM) will feed this list later.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AppAlertCategory? _filter;

  /// Replace with repository / local store synced from FCM.
  final List<AppAlert> _alerts = [];

  List<AppAlert> get _visible {
    if (_filter == null) return _alerts;
    return _alerts.where((a) => a.category == _filter).toList();
  }

  int get _unreadCount => _alerts.where((a) => !a.read).length;

  void _markAllRead() {
    if (_alerts.isEmpty) return;
    setState(() {
      for (var i = 0; i < _alerts.length; i++) {
        if (!_alerts[i].read) {
          _alerts[i] = _alerts[i].copyWith(read: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            _filterChips(context),
            Expanded(
              child: visible.isEmpty
                  ? _emptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) =>
                          _AlertCard(alert: visible[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts',
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: context.fs(20),
                  ),
                ),
                Text(
                  _unreadCount > 0
                      ? '$_unreadCount unread'
                      : 'Offers & order updates',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.textSecondary,
                    fontSize: context.fs(13),
                  ),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.brandGreenDeep,
                  fontWeight: FontWeight.w600,
                  fontSize: context.fs(13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: _filter == null,
            onTap: () => setState(() => _filter = null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ...AppAlertCategory.values.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: c.label,
                selected: _filter == c,
                onTap: () => setState(() => _filter = c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryNavy.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: context.fs(48),
              color: AppColors.brandTeal,
            ),
          ),
          SizedBox(height: context.fs(24)),
          Text(
            'No alerts yet',
            style: AppTextStyles.title(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.fs(10)),
          Text(
            'Daily offers, flash sales, and order updates will appear here. '
            'We\'ll enable push notifications soon so you never miss a deal in Kota.',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.fs(28)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.brandGreenDeep,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Tip: Allow notifications when prompted so you get Kota-only pharmacy offers.',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: context.fs(13),
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brandGreenDeep : AppColors.white,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: selected ? AppColors.brandGreenDeep : AppColors.inputBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body(context).copyWith(
              fontSize: context.fs(13),
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AppAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final icon = switch (alert.category) {
      AppAlertCategory.offer => Icons.local_offer_outlined,
      AppAlertCategory.order => Icons.receipt_long_outlined,
      AppAlertCategory.general => Icons.info_outline_rounded,
    };
    final tint = switch (alert.category) {
      AppAlertCategory.offer => AppColors.brandGreen,
      AppAlertCategory.order => AppColors.brandTeal,
      AppAlertCategory.general => AppColors.accent,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: alert.read ? AppColors.inputBorder : AppColors.brandTeal,
          width: alert.read ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: AppTextStyles.body(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!alert.read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  alert.body,
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontSize: context.fs(13),
                  ),
                ),
                if (alert.createdAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatWhen(alert.createdAt!),
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: context.fs(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWhen(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
