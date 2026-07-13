sealed class BreweryListEvent {
  const BreweryListEvent();
}

final class BreweryListStarted extends BreweryListEvent {
  const BreweryListStarted();
}

final class BreweryListNextPageRequested extends BreweryListEvent {
  const BreweryListNextPageRequested();
}

final class BreweryListRefreshRequested extends BreweryListEvent {
  const BreweryListRefreshRequested();
}

final class BreweryListSearchQueryChanged extends BreweryListEvent {
  final String query;

  const BreweryListSearchQueryChanged(this.query);
}
