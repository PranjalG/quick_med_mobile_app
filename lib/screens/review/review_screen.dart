import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quick_med/blocs/review_cubit/review_cubit.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/services/prescription_service.dart';

/// Doctor-facing prescription review queue.
///
/// Reachable only by a profile with role doctor or admin — enforced in the
/// database too, so hiding the route is convenience, not the security boundary.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final ReviewCubit _cubit = ReviewCubit()..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _decide(PendingReview item, bool approve) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => _NotesDialog(approve: approve),
    );
    if (notes == null) return; // cancelled
    await _cubit.decide(
      prescriptionId: item.id,
      approve: approve,
      notes: notes.isEmpty ? null : notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prescription Review'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ReviewCubit, ReviewState>(
          listener: (context, state) {
            if (state is ReviewActionFailed) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              ReviewInitial() || ReviewLoading() =>
                const Center(child: CircularProgressIndicator()),
              ReviewEmpty() => _message(
                  Icons.verified_outlined,
                  'Queue is clear',
                  'No prescriptions are waiting for review.',
                ),
              ReviewFailure(:final message) =>
                _message(Icons.cloud_off_rounded, 'Could not load queue', message),
              ReviewLoaded(:final queue) => _list(queue),
              ReviewActionFailed(:final queue) => _list(queue),
            };
          },
        ),
      ),
    );
  }

  Widget _list(List<PendingReview> queue) {
    return RefreshIndicator(
      onRefresh: _cubit.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: queue.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, i) => _card(queue[i]),
      ),
    );
  }

  Widget _card(PendingReview item) {
    final text = Theme.of(context).textTheme;

    return Container(
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
              Text(item.reference, style: text.titleSmall),
              Text('Rs ${item.orderTotal.toStringAsFixed(2)}',
                  style: text.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.itemNames.join(', '),
              style: text.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.md),

          // Private bucket: rendered through a short-lived signed URL.
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: FutureBuilder<String>(
              future: _cubit.imageUrl(item.storagePath),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Container(
                    height: 220,
                    alignment: Alignment.center,
                    color: AppColors.disabled,
                    child: const CircularProgressIndicator(),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return Container(
                    height: 220,
                    alignment: Alignment.center,
                    color: AppColors.disabled,
                    child: Text('Could not load image', style: text.bodySmall),
                  );
                }
                return Image.network(
                  snap.data!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    alignment: Alignment.center,
                    color: AppColors.disabled,
                    child: Text('Image unavailable', style: text.bodySmall),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _decide(item, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _decide(item, true),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _message(IconData icon, String title, String body) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.secondaryBlue),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(body,
                style: text.bodySmall, textAlign: TextAlign.center, maxLines: 4),
          ],
        ),
      ),
    );
  }
}

class _NotesDialog extends StatefulWidget {
  final bool approve;

  const _NotesDialog({required this.approve});

  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.approve ? 'Approve prescription' : 'Reject prescription'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: widget.approve
              ? 'Optional note for the record'
              : 'Reason the customer will see',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.approve ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}
