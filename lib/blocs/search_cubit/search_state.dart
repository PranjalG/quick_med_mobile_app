part of 'search_cubit.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// No query typed yet.
class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchResults extends SearchState {
  final String query;
  final List<Medicine> results;

  const SearchResults({required this.query, required this.results});

  @override
  List<Object?> get props => [query, results];
}

class SearchNoResults extends SearchState {
  final String query;

  const SearchNoResults(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchFailure extends SearchState {
  final String query;
  final String message;

  const SearchFailure({required this.query, required this.message});

  @override
  List<Object?> get props => [query, message];
}
