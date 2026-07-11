import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioClientModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openbrewerydb.org/v1',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    return dio;
  }
}
