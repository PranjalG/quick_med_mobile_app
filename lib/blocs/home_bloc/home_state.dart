part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int tabIndex;

  const HomeState({
    this.tabIndex = 0,
  });

  HomeState copyWith({
    int? tabIndex,
  }) {
    return HomeState(
      tabIndex: tabIndex ?? this.tabIndex,
    );
  }

  @override
  List<Object> get props => [
    tabIndex,
  ];
}
