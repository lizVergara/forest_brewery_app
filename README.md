# Forest Brewery App

Flutter technical test for the Senior Mobile Engineer position at Forest.

This project is a small Flutter application using the Open Brewery DB public API. It includes a paginated brewery list, a brewery detail screen, typed error handling, dependency injection, basic tests, search with debounce, and location-based distance sorting.

## Tech Stack

- Flutter
- flutter_bloc
- bloc_concurrency
- dio
- get_it
- injectable
- geolocator
- mocktail
- bloc_test

## Architecture

The project follows a layered architecture organized by feature:

```txt
lib/
  core/
    di/
    error/
    location/
    network/
    presentation/
    router/

  features/
    breweries/
      data/
        datasources/
        dtos/
        repositories/

      domain/
        entities/
        repositories/

      presentation/
        list/
        detail/
```

### Layer responsibilities

- `domain`: app entities and repository contracts.
- `data`: remote datasource, DTOs, API calls, repository implementation, DTO to Entity mapping.
- `presentation`: screens, widgets, Bloc/Cubit, events and states.
- `core`: shared concerns such as dependency injection, network setup, error handling, routing, reusable widgets and location utilities.

The UI does not call the API directly. Data flows through:

```txt
Remote API
  -> DTO
  -> Repository implementation
  -> Domain Entity
  -> Bloc / Cubit
  -> UI State
```

## How to run the project

Install dependencies:

```bash
flutter pub get
```

Generate dependency injection files:

```bash
dart run build_runner build
```

Run the app:

```bash
flutter run
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Location testing

The distance sorting feature uses the device location.

On iOS Simulator, a simulated location can be selected from:

```txt
Simulator -> Features -> Location -> Custom Location
```

Example coordinates for London:

```txt
Latitude: 51.5074
Longitude: -0.1278
```

After enabling a simulated location, tap the location icon in the brewery list to sort loaded breweries by nearest distance.

## What was completed

- Paginated brewery list using `/breweries`.
- Brewery detail screen using `/breweries/{id}`.
- Search using `/breweries/search`.
- Loading, empty and error states.
- Typed application exceptions.
- Repository pattern with DTO to Entity mapping.
- Dependency injection using `get_it` and `injectable`.
- `flutter_bloc` for list state management.
- Cubit for brewery detail state management.
- Pagination with `bloc_concurrency`.
- Search debounce using `stream_transform` and `restartable`.
- Distance sorting using `geolocator` and a Haversine distance calculation.
- Distance sorting is preserved when more pages are loaded.
- User-facing feedback when sorting by distance or when location access fails.
- Meaningful Bloc tests using `bloc_test` and `mocktail`.

## what can be improve:

- Add a Mapbox map screen with brewery markers and marker selection.
- Add offline caching for the brewery list and detail.
- Add more tests for search, pagination, detail Cubit and distance sorting.
- Improve list animations when reordered by distance.
- Add Sentry or Crashlytics for runtime error reporting.
- Add CI to run analyze and tests automatically.
- Add better UI polish and accessibility labels.
