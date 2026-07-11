# Forest Brewery App

Flutter technical test for the Senior Mobile Engineer position at Forest.

This project is a small two-screen Flutter application using the Open Brewery DB public API.

## Tech Stack

- Flutter
- flutter_bloc
- bloc_concurrency
- dio
- get_it
- injectable
- mocktail
- bloc_test

## Architecture

The project follows a layered architecture organized by feature:

```txt
lib/
  core/
    di/
    error/
    network/

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
