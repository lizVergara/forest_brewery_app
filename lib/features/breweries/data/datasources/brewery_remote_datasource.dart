import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../dtos/brewery_dto.dart';

abstract class BreweryRemoteDataSource {
  Future<List<BreweryDto>> getBreweries({
    required int page,
    required int perPage,
  });

  Future<BreweryDto> getBreweryById(String id);

  Future<List<BreweryDto>> searchBreweries(String query);
}

@LazySingleton(as: BreweryRemoteDataSource)
class BreweryRemoteDataSourceImpl implements BreweryRemoteDataSource {
  final Dio _dio;

  BreweryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BreweryDto>> getBreweries({
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/breweries',
      queryParameters: {'per_page': perPage, 'page': page},
    );

    final data = response.data ?? [];

    return data
        .map(
          (item) => BreweryDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<BreweryDto> getBreweryById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/breweries/$id');

    final data = response.data;

    if (data == null) {
      throw const FormatException('Empty brewery detail response.');
    }

    return BreweryDto.fromJson(data);
  }

  @override
  Future<List<BreweryDto>> searchBreweries(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/breweries/search',
      queryParameters: {'query': query},
    );

    final data = response.data ?? [];

    return data
        .map(
          (item) => BreweryDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
