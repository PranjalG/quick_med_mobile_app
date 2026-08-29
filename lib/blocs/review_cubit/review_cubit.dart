import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:quick_med/services/prescription_service.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({PrescriptionService? service})
      : _service = service ?? PrescriptionService(),
        super(const ReviewInitial());

  final PrescriptionService _service;

  Future<void> load() async {
    emit(const ReviewLoading());
    try {
      final queue = await _service.fetchQueue();
      emit(queue.isEmpty ? const ReviewEmpty() : ReviewLoaded(queue));
    } catch (error) {
      emit(ReviewFailure(error.toString()));
    }
  }

  /// Approve or reject, then drop the row from the queue optimistically.
  Future<void> decide({
    required String prescriptionId,
    required bool approve,
    String? notes,
  }) async {
    final current = state;
    if (current is! ReviewLoaded) return;

    try {
      await _service.review(
        prescriptionId: prescriptionId,
        approve: approve,
        notes: notes,
      );
      final remaining =
          current.queue.where((p) => p.id != prescriptionId).toList();
      emit(remaining.isEmpty ? const ReviewEmpty() : ReviewLoaded(remaining));
    } on PrescriptionException catch (error) {
      // Surface the reason, but keep the queue on screen.
      emit(ReviewActionFailed(queue: current.queue, message: error.message));
    }
  }

  Future<String> imageUrl(String storagePath) => _service.signedUrl(storagePath);
}
