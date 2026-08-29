part of 'catalogue_cubit.dart';

sealed class CatalogueState extends Equatable {
  const CatalogueState();

  @override
  List<Object?> get props => [];
}

class CatalogueInitial extends CatalogueState {
  const CatalogueInitial();
}

class CatalogueLoading extends CatalogueState {
  const CatalogueLoading();
}

class CatalogueLoaded extends CatalogueState {
  final Map<MedicineCategory, List<Medicine>> byCategory;

  /// True when this came from bundled constants rather than Supabase.
  final bool isFallback;

  const CatalogueLoaded({
    required this.byCategory,
    this.isFallback = false,
  });

  List<MedicineCategory> get categories => byCategory.keys.toList();

  @override
  List<Object?> get props => [byCategory, isFallback];
}

class CatalogueEmpty extends CatalogueState {
  const CatalogueEmpty();
}

class CatalogueFailure extends CatalogueState {
  final String message;

  const CatalogueFailure(this.message);

  @override
  List<Object?> get props => [message];
}
