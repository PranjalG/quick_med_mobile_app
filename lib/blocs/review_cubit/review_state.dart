part of 'review_cubit.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<PendingReview> queue;

  const ReviewLoaded(this.queue);

  @override
  List<Object?> get props => [queue];
}

class ReviewEmpty extends ReviewState {
  const ReviewEmpty();
}

class ReviewFailure extends ReviewState {
  final String message;

  const ReviewFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// A decision failed, but the queue is still valid and stays on screen.
class ReviewActionFailed extends ReviewState {
  final List<PendingReview> queue;
  final String message;

  const ReviewActionFailed({required this.queue, required this.message});

  @override
  List<Object?> get props => [queue, message];
}
