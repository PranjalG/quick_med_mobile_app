import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:quick_med/models/medicine_model.dart';
import 'package:quick_med/services/medicine_service.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({MedicineService? service, Duration? debounce})
      : _service = service ?? MedicineService(),
        _debounceDuration = debounce ?? const Duration(milliseconds: 300),
        super(const SearchIdle());

  final MedicineService _service;
  final Duration _debounceDuration;

  Timer? _debounce;

  /// Monotonic id of the most recent request. A slower earlier response whose
  /// id no longer matches is discarded, so results cannot arrive out of order.
  int _requestId = 0;

  void queryChanged(String raw) {
    _debounce?.cancel();

    final query = raw.trim();
    if (query.isEmpty) {
      _requestId++; // abandon anything in flight
      emit(const SearchIdle());
      return;
    }

    _debounce = Timer(_debounceDuration, () => _run(query));
  }

  /// Bypasses the debounce — for submit and retry.
  Future<void> searchNow(String raw) {
    _debounce?.cancel();
    final query = raw.trim();
    if (query.isEmpty) {
      emit(const SearchIdle());
      return Future.value();
    }
    return _run(query);
  }

  Future<void> _run(String query) async {
    final id = ++_requestId;
    emit(SearchLoading(query));

    try {
      final results = await _service.searchMedicines(query);
      if (id != _requestId || isClosed) return; // superseded
      emit(
        results.isEmpty
            ? SearchNoResults(query)
            : SearchResults(query: query, results: results),
      );
    } catch (error) {
      if (id != _requestId || isClosed) return;
      emit(SearchFailure(query: query, message: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
