import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeEvent>((event, emit) {});
    on<TabIndexChangeEvent>(_onTabIndexChangeEvent);
  }

  void _onTabIndexChangeEvent(TabIndexChangeEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(tabIndex: event.index));
  }
}
