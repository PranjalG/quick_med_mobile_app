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

  Future<void> load({int perCategory = 5}) async {
    emit(const CatalogueLoading());
    try {
      final byCategory = await _service.fetchCatalogue(perCategory: perCategory);
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
      emit(CatalogueFailure(error.toString()));
    }
  }

  Future<void> refresh() => load();
}
