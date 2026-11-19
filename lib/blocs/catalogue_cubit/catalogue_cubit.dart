import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:quick_med/models/category_model.dart';
import 'package:quick_med/models/medicine_model.dart';
import 'package:quick_med/services/medicine_service.dart';

part 'catalogue_state.dart';

class CatalogueCubit extends Cubit<CatalogueState> {
  CatalogueCubit({MedicineService? service})
      : _service = service ?? MedicineService(),
        super(const CatalogueInitial());

  final MedicineService _service;

  Future<void> load({int perCategory = 5}) =>
      _fetch(perCategory: perCategory, keepContent: false);

  /// Reloads the catalogue, e.g. on pull-to-refresh.
  ///
  /// If medicines are already on screen they stay visible while the request
  /// runs (the pull-to-refresh spinner shows progress), and a failed reload
  /// keeps them instead of replacing the page with an error. From an empty,
  /// failed or initial state this behaves like [load].
  Future<void> refresh() => _fetch(keepContent: state is CatalogueLoaded);

  Future<void> _fetch({int perCategory = 5, required bool keepContent}) async {
    if (!keepContent) emit(const CatalogueLoading());
    try {
      final byCategory =
          await _service.fetchCatalogue(perCategory: perCategory);
      if (byCategory.isEmpty) {
        emit(const CatalogueEmpty());
        return;
      }
      emit(
        CatalogueLoaded(
          byCategory: byCategory,
          isFallback: _service.lastReadUsedFallback,
        ),
      );
    } catch (error) {
      if (keepContent) return;
      emit(CatalogueFailure(error.toString()));
    }
  }
}
