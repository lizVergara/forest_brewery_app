// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:forest_brewery_app/core/network/dio_client.dart' as _i290;
import 'package:forest_brewery_app/features/breweries/data/datasources/brewery_remote_datasource.dart'
    as _i903;
import 'package:forest_brewery_app/features/breweries/data/repositories/brewery_repository_impl.dart'
    as _i132;
import 'package:forest_brewery_app/features/breweries/domain/repositories/brewery_repository.dart'
    as _i79;
import 'package:forest_brewery_app/features/breweries/presentation/detail/cubit/brewery_detail_cubit.dart'
    as _i565;
import 'package:forest_brewery_app/features/breweries/presentation/list/bloc/brewery_list_bloc.dart'
    as _i977;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioClientModule = _$DioClientModule();
    gh.lazySingleton<_i361.Dio>(() => dioClientModule.dio);
    gh.lazySingleton<_i903.BreweryRemoteDataSource>(
      () => _i903.BreweryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i79.BreweryRepository>(
      () => _i132.BreweryRepositoryImpl(gh<_i903.BreweryRemoteDataSource>()),
    );
    gh.factory<_i565.BreweryDetailCubit>(
      () => _i565.BreweryDetailCubit(gh<_i79.BreweryRepository>()),
    );
    gh.factory<_i977.BreweryListBloc>(
      () => _i977.BreweryListBloc(gh<_i79.BreweryRepository>()),
    );
    return this;
  }
}

class _$DioClientModule extends _i290.DioClientModule {}
