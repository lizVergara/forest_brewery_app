import '../../../domain/entities/brewery.dart';

sealed class BreweryListState {
  const BreweryListState();
}

final class BreweryListInitial extends BreweryListState {
  const BreweryListInitial();
}

final class BreweryListLoading extends BreweryListState {
  const BreweryListLoading();
}

final class BreweryListEmpty extends BreweryListState {
  const BreweryListEmpty();
}

final class BreweryListError extends BreweryListState {
  final String message;
  final String searchQuery;

  const BreweryListError(this.message, {this.searchQuery = ''});

  bool get isSearchError => searchQuery.trim().isNotEmpty;
}

final class BreweryListSuccess extends BreweryListState {
  final List<Brewery> breweries;
  final int currentPage;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final String? loadMoreErrorMessage;
  final String searchQuery;

  const BreweryListSuccess({
    required this.breweries,
    required this.currentPage,
    required this.hasReachedEnd,
    this.isLoadingMore = false,
    this.loadMoreErrorMessage,
    this.searchQuery = '',
  });

  bool get isSearchResult => searchQuery.trim().isNotEmpty;

  BreweryListSuccess copyWith({
    List<Brewery>? breweries,
    int? currentPage,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    String? loadMoreErrorMessage,
    String? searchQuery,
    bool clearLoadMoreError = false,
  }) {
    return BreweryListSuccess(
      breweries: breweries ?? this.breweries,
      currentPage: currentPage ?? this.currentPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreErrorMessage: clearLoadMoreError
          ? null
          : loadMoreErrorMessage ?? this.loadMoreErrorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
