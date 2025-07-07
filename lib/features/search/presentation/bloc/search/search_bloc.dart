import 'dart:async';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/dependencies.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/search/domain/usecases/search_user_profiles.dart';
import 'package:atabei/features/search/presentation/bloc/search/search_event.dart';
import 'package:atabei/features/search/presentation/bloc/search/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUserProfilesUseCase _searchUserProfilesUseCase;
  StreamSubscription? _searchStreamSubscription;
  List<UserProfileEntity> _currentResults = [];
  String _currentQuery = '';
  Timer? _debounceTimer;

  SearchBloc()
      : _searchUserProfilesUseCase = sl<SearchUserProfilesUseCase>(),
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<LoadSearchResults>(_onLoadSearchResults);
    on<RefreshSearchResults>(_onRefreshSearchResults);
    on<ClearSearch>(_onClearSearch);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _searchStreamSubscription?.cancel();
    return super.close();
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    _currentQuery = query;

    print('🔍 Search query changed: "$query"');

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // If query is empty, clear results
    if (query.isEmpty) {
      _currentResults.clear();
      emit(SearchInitial());
      return;
    }

    // Debounce the search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_currentQuery == query) { // Make sure query hasn't changed
        add(LoadSearchResults(query: query));
      }
    });
  }

  void _onLoadSearchResults(
    LoadSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    try {
      print('🔍 Loading search results for query: "${event.query}"');
      
      if (_currentResults.isEmpty) {
        emit(SearchLoading());
      }

      final result = await _searchUserProfilesUseCase(
        params: SearchUserProfilesParams(
          query: event.query,
          limit: event.limit,
        ),
      );

      if (result is DataSuccess) {
        _currentResults = result.data ?? [];
        print('🔍 Search completed: ${_currentResults.length} results found');
        
        emit(SearchLoaded(
          results: _currentResults,
          query: event.query,
        ));
      } else if (result is DataError) {
        print('🔍 Search error: ${result.error?.message}');
        emit(SearchError(message: result.error?.message ?? 'Search failed'));
      }
    } catch (e) {
      print('🔍 Exception during search: $e');
      emit(SearchError(message: 'Failed to search users: $e'));
    }
  }

  void _onRefreshSearchResults(
    RefreshSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    add(LoadSearchResults(query: event.query, limit: event.limit));
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    _currentResults.clear();
    _currentQuery = '';
    emit(SearchInitial());
  }
}