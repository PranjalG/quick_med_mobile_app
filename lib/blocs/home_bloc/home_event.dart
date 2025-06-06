part of 'home_bloc.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class TabIndexChangeEvent extends HomeEvent {
  final int index;

  const TabIndexChangeEvent({
    required this.index,
  });
}
