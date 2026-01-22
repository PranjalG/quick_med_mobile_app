part of 'landing_screen_bloc.dart';

class LandingScreenEvent extends Equatable {
  const LandingScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicinesEvent extends LandingScreenEvent {
  const LoadMedicinesEvent();
}

class SearchMedicinesEvent extends LandingScreenEvent {
  final String query;

  const SearchMedicinesEvent(this.query);
}
