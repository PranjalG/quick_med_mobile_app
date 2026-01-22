import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quick_med/services/enum.dart';

part 'landing_screen_event.dart';

part 'landing_screen_state.dart';

class LandingScreenBloc extends Bloc<LandingScreenEvent, LandingScreenState> {
  LandingScreenBloc() : super(const LandingScreenState()) {
    on<LandingScreenEvent>((event, emit) {});
    on<LoadMedicinesEvent>(_onLoadMedicinesEvent);
    on<SearchMedicinesEvent>(_onSearchMedicinesEvent);
  }

  void _onLoadMedicinesEvent(
      LoadMedicinesEvent event, Emitter<LandingScreenState> emit) async {
    emit(state.copyWith(medicineDataResponseStatus: Status.loading));
    await Future.delayed(const Duration(seconds: 4));
    final List<Medicine> items = List.generate(
      30,
      (index) => Medicine(
        medicineName: index % 3 == 0
            ? 'Levocitrizine'
            : index % 2 == 0
                ? 'Azithromicine'
                : 'Paracetamol',
        price: Random().nextInt(41),
      ),
    );
    emit(
      state.copyWith(
        medicineList: items,
        filteredList: items,
        medicineDataResponseStatus: Status.success,
      ),
    );
  }

  void _onSearchMedicinesEvent(
      SearchMedicinesEvent event, Emitter<LandingScreenState> emit) {
    final query = event.query.toLowerCase();

    final filteredList = state.medicineList
        .where((item) => item.medicineName.toLowerCase().contains(query))
        .toList();

    emit(
      state.copyWith(filteredList: filteredList),
    );
  }
}
