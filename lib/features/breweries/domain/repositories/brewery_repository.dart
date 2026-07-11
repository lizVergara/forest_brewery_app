import '../entities/brewery.dart';

abstract class BreweryRepository {
  Future<List<Brewery>> getBreweries({required int page, required int perPage});

  Future<Brewery> getBreweryById(String id);

  Future<List<Brewery>> searchBreweries(String query);
}
