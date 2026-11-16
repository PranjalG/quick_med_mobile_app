import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:quick_med/models/order_model.dart';
import 'package:quick_med/services/order_service.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({OrderService? service})
      : _service = service ?? OrderService(),
        super(const OrdersInitial());

  final OrderService _service;

  static const int _pageSize = 20;

  Future<void> load() async {
    emit(const OrdersLoading());
    try {
      final orders = await _service.fetchOrders(limit: _pageSize);
      emit(orders.isEmpty
          ? const OrdersEmpty()
          : OrdersLoaded(orders: orders, hasMore: orders.length == _pageSize));
    } on PostgrestException catch (error) {
      emit(OrdersFailure(_friendly(error)));
    } catch (error) {
      emit(OrdersFailure(error.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! OrdersLoaded || !current.hasMore) return;

    try {
      final next = await _service.fetchOrders(
        limit: _pageSize,
        offset: current.orders.length,
      );
      emit(OrdersLoaded(
        orders: [...current.orders, ...next],
        hasMore: next.length == _pageSize,
      ));
    } catch (_) {
      // Keep what is already on screen; a failed page-2 must not blank page 1.
    }
  }

  Future<void> refresh() => load();

  String _friendly(PostgrestException error) => switch (error.code) {
        'PGRST301' =>
          'Could not verify your session. Register Firebase as a Supabase '
              'third-party auth provider.',
        'PGRST205' => 'Order storage is not set up yet.',
        _ => error.message,
      };
}
