import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:forest_brewery_app/core/error/app_exception.dart';
import 'package:forest_brewery_app/features/breweries/domain/entities/brewery.dart';
import 'package:forest_brewery_app/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_brewery_app/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:forest_brewery_app/features/breweries/presentation/list/bloc/brewery_list_event.dart';
import 'package:forest_brewery_app/features/breweries/presentation/list/bloc/brewery_list_state.dart';

class MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  late MockBreweryRepository repository;

  final breweries = [
    const Brewery(
      id: '1',
      name: 'Forest Brewery',
      breweryType: 'micro',
      city: 'London',
      address: '123 Forest Street',
      phone: '123456789',
      websiteUrl: 'https://forest.example.com',
    ),
  ];

  setUp(() {
    repository = MockBreweryRepository();
  });

  group('BreweryListBloc', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'emits Loading and Success when breweries are loaded successfully',
      build: () {
        when(
          () => repository.getBreweries(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => breweries);

        return BreweryListBloc(repository);
      },
      act: (bloc) {
        bloc.add(const BreweryListStarted());
      },
      expect: () => [
        isA<BreweryListLoading>(),
        isA<BreweryListSuccess>()
            .having((state) => state.breweries, 'breweries', breweries)
            .having((state) => state.currentPage, 'currentPage', 1)
            .having((state) => state.hasReachedEnd, 'hasReachedEnd', true),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
      },
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits Loading and Error when repository throws an AppException',
      build: () {
        when(
          () => repository.getBreweries(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenThrow(const NetworkException('No internet connection.'));

        return BreweryListBloc(repository);
      },
      act: (bloc) {
        bloc.add(const BreweryListStarted());
      },
      expect: () => [
        isA<BreweryListLoading>(),
        isA<BreweryListError>().having(
          (state) => state.message,
          'message',
          'No internet connection.',
        ),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
      },
    );
  });
}
