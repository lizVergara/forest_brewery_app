import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/brewery.dart';
import '../../domain/repositories/brewery_repository.dart';
import '../datasources/brewery_remote_datasource.dart';

@LazySingleton(as: BreweryRepository)
class BreweryRepositoryImpl implements BreweryRepository {
  final BreweryRemoteDataSource _remoteDataSource;

  BreweryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Brewery>> getBreweries({
    required int page,
    required int perPage,
  }) async {
    try {
      final dtos = await _remoteDataSource.getBreweries(
        page: page,
        perPage: perPage,
      );

      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const UnknownException(
        'The server response could not be processed.',
      );
    } catch (_) {
      throw const UnknownException();
    }
  }

  @override
  Future<Brewery> getBreweryById(String id) async {
    try {
      final dto = await _remoteDataSource.getBreweryById(id);

      return dto.toEntity();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const UnknownException(
        'The server response could not be processed.',
      );
    } catch (_) {
      throw const UnknownException();
    }
  }

  @override
  Future<List<Brewery>> searchBreweries(String query) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        return [];
      }

      final dtos = await _remoteDataSource.searchBreweries(trimmedQuery);

      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const UnknownException(
        'The server response could not be processed.',
      );
    } catch (_) {
      throw const UnknownException();
    }
  }

  AppException _mapDioException(DioException error) {
    final apiMessage = _extractApiMessage(error.response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 404) {
          return NotFoundException(
            apiMessage ?? 'The requested brewery was not found.',
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            apiMessage ??
                'Something went wrong on the server. Please try again later.',
          );
        }

        return UnknownException(
          apiMessage ?? 'Something went wrong. Please try again.',
        );

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownException();
    }
  }

  String? _extractApiMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return null;
  }
}
