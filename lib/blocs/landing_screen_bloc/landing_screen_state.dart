part of 'landing_screen_bloc.dart';

class LandingScreenState extends Equatable {
  final Status medicineDataResponseStatus;
  final String? error;
  final List<Medicine> medicineList;
  final List<Medicine> filteredList;

  const LandingScreenState({
    this.medicineDataResponseStatus = Status.initial,
    this.error,
    this.medicineList = const [],
    this.filteredList = const [],
  });

  LandingScreenState copyWith({
    Status? medicineDataResponseStatus,
    String? error,
    List<Medicine>? medicineList,
    List<Medicine>? filteredList,
  }) {
    return LandingScreenState(
      medicineDataResponseStatus:
          medicineDataResponseStatus ?? this.medicineDataResponseStatus,
      error: error ?? this.error,
      medicineList: medicineList ?? this.medicineList,
      filteredList: filteredList ?? this.filteredList,
    );
  }

  @override
  List<Object?> get props => [
        medicineDataResponseStatus,
        error,
        medicineList,
        filteredList,
      ];
}

class Medicine {
  final String medicineName;
  final num price;

  const Medicine({
    required this.medicineName,
    required this.price,
  });
}
