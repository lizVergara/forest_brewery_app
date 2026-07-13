import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../domain/repositories/brewery_repository.dart';
import 'brewery_list_event.dart';
import 'brewery_list_state.dart';
import 'package:stream_transform/stream_transform.dart';

@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  static const int _perPage = 20;

  final BreweryRepository _repository;

  BreweryListBloc(this._repository) : super(const BreweryListInitial()) {
    on<BreweryListStarted>(_onStarted, transformer: droppable());

    on<BreweryListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );

    on<BreweryListRefreshRequested>(
      _onRefreshRequested,
      transformer: droppable(),
    );

    on<BreweryListSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounceRestartable(const Duration(milliseconds: 500)),
    );
  }

  Future<void> _onStarted(
    BreweryListStarted event,
    Emitter<BreweryListState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshRequested(
    BreweryListRefreshRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final currentState = state;

    if (currentState is BreweryListSuccess && currentState.isSearchResult) {
      await _onSearchQueryChanged(
        BreweryListSearchQueryChanged(currentState.searchQuery),
        emit,
      );
      return;
    }

    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<BreweryListState> emit) async {
    emit(const BreweryListLoading());

    try {
      final breweries = await _repository.getBreweries(
        page: 1,
        perPage: _perPage,
      );

      if (breweries.isEmpty) {
        emit(const BreweryListEmpty());
        return;
      }

      emit(
        BreweryListSuccess(
          breweries: breweries,
          currentPage: 1,
          hasReachedEnd: breweries.length < _perPage,
        ),
      );
    } on AppException catch (error) {
      emit(BreweryListError(error.message));
    } catch (_) {
      emit(const BreweryListError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onNextPageRequested(
    BreweryListNextPageRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final currentState = state;

    if (currentState is! BreweryListSuccess) return;
    if (currentState.isSearchResult) return;
    if (currentState.isLoadingMore) return;
    if (currentState.hasReachedEnd) return;
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));

    try {
      final nextPage = currentState.currentPage + 1;

      final newBreweries = await _repository.getBreweries(
        page: nextPage,
        perPage: _perPage,
      );

      emit(
        currentState.copyWith(
          breweries: [...currentState.breweries, ...newBreweries],
          currentPage: nextPage,
          hasReachedEnd: newBreweries.length < _perPage,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreErrorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreErrorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSearchQueryChanged(
    BreweryListSearchQueryChanged event,
    Emitter<BreweryListState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      await _loadFirstPage(emit);
      return;
    }

    emit(const BreweryListLoading());

    try {
      final breweries = await _repository.searchBreweries(query);

      if (breweries.isEmpty) {
        emit(const BreweryListEmpty());
        return;
      }

      emit(
        BreweryListSuccess(
          breweries: breweries,
          currentPage: 1,
          hasReachedEnd: true,
          searchQuery: query,
        ),
      );
    } on AppException catch (error) {
      emit(BreweryListError(error.message));
    } catch (_) {
      emit(const BreweryListError('Something went wrong. Please try again.'));
    }
  }
}

EventTransformer<Event> _debounceRestartable<Event>(Duration duration) {
  return (events, mapper) {
    return restartable<Event>().call(events.debounce(duration), mapper);
  };
}
