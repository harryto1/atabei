import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadSearchResults extends SearchEvent {
  final String query;
  final int limit;

  const LoadSearchResults({required this.query, this.limit = 20});

  @override
  List<Object?> get props => [query, limit];
}

class RefreshSearchResults extends SearchEvent {
  final String query;
  final int limit;

  const RefreshSearchResults({required this.query, this.limit = 20});

  @override
  List<Object?> get props => [query, limit];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}