part of 'orders_cubit.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<CustomerOrder> orders;
  final bool hasMore;

  const OrdersLoaded({required this.orders, this.hasMore = false});

  @override
  List<Object?> get props => [orders, hasMore];
}

/// Signed in, but this user has never ordered.
class OrdersEmpty extends OrdersState {
  const OrdersEmpty();
}

class OrdersFailure extends OrdersState {
  final String message;

  const OrdersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
