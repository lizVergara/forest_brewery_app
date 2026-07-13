import '../../../domain/entities/brewery.dart';

sealed class BreweryDetailState {
  const BreweryDetailState();
}

final class BreweryDetailInitial extends BreweryDetailState {
  const BreweryDetailInitial();
}

final class BreweryDetailLoading extends BreweryDetailState {
  const BreweryDetailLoading();
}

final class BreweryDetailSuccess extends BreweryDetailState {
  final Brewery brewery;

  const BreweryDetailSuccess(this.brewery);
}

final class BreweryDetailError extends BreweryDetailState {
  final String message;

  const BreweryDetailError(this.message);
}
