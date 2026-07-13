import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_brewery_app/core/location/distance_calculator.dart';
import 'package:forest_brewery_app/core/location/location_service.dart';
import 'package:forest_brewery_app/features/breweries/domain/entities/brewery.dart';
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
  final LocationService _locationService;

  BreweryListBloc(this._repository, this._locationService)
    : super(const BreweryListInitial()) {
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

    on<BreweryListSortByDistanceRequested>(
      _onSortByDistanceRequested,
      transformer: droppable(),
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

      if (newBreweries.isEmpty) {
        emit(
          currentState.copyWith(
            hasReachedEnd: true,
            isLoadingMore: false,
            clearLoadMoreError: true,
          ),
        );
        return;
      }

      var updatedBreweries = [...currentState.breweries, ...newBreweries];

      final shouldKeepDistanceSorting =
          currentState.isSortedByDistance &&
          currentState.userLatitude != null &&
          currentState.userLongitude != null;

      if (shouldKeepDistanceSorting) {
        updatedBreweries = _sortBreweriesByDistance(
          breweries: updatedBreweries,
          userLatitude: currentState.userLatitude!,
          userLongitude: currentState.userLongitude!,
        );
      }

      emit(
        currentState.copyWith(
          breweries: updatedBreweries,
          currentPage: nextPage,
          hasReachedEnd: newBreweries.length < _perPage,
          isLoadingMore: false,
          isSortedByDistance: shouldKeepDistanceSorting,
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

  Future<void> _onSortByDistanceRequested(
    BreweryListSortByDistanceRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final currentState = state;

    if (currentState is! BreweryListSuccess) return;

    emit(
      currentState.copyWith(
        isSortingByDistance: true,
        clearDistanceError: true,
      ),
    );

    try {
      final position = await _locationService.getCurrentPosition();

      final sortedBreweries = _sortBreweriesByDistance(
        breweries: currentState.breweries,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
      );

      emit(
        currentState.copyWith(
          breweries: sortedBreweries,
          isSortingByDistance: false,
          isSortedByDistance: true,
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          clearDistanceError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        currentState.copyWith(
          isSortingByDistance: false,
          distanceErrorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSortingByDistance: false,
          distanceErrorMessage: 'Unable to sort breweries by distance.',
        ),
      );
    }
  }

  List<Brewery> _sortBreweriesByDistance({
    required List<Brewery> breweries,
    required double userLatitude,
    required double userLongitude,
  }) {
    final breweriesWithDistance = breweries.map((brewery) {
      if (!brewery.hasCoordinates) return brewery;

      final distanceInKm = DistanceCalculator.calculateDistanceInKm(
        startLatitude: userLatitude,
        startLongitude: userLongitude,
        endLatitude: brewery.latitude!,
        endLongitude: brewery.longitude!,
      );

      return brewery.copyWith(distanceInKm: distanceInKm);
    }).toList();

    breweriesWithDistance.sort((a, b) {
      final distanceA = a.distanceInKm;
      final distanceB = b.distanceInKm;

      if (distanceA == null && distanceB == null) return 0;
      if (distanceA == null) return 1;
      if (distanceB == null) return -1;

      return distanceA.compareTo(distanceB);
    });

    return breweriesWithDistance;
  }
}

EventTransformer<Event> _debounceRestartable<Event>(Duration duration) {
  return (events, mapper) {
    return restartable<Event>().call(events.debounce(duration), mapper);
  };
}
