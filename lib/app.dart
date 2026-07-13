import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_routes.dart';
import 'features/breweries/presentation/detail/cubit/brewery_detail_cubit.dart';
import 'features/breweries/presentation/detail/pages/brewery_detail_page.dart';
import 'features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'features/breweries/presentation/list/bloc/brewery_list_event.dart';
import 'features/breweries/presentation/list/pages/brewery_list_page.dart';

class ForestBreweryApp extends StatelessWidget {
  const ForestBreweryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Brewery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.breweries,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.breweries:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<BreweryListBloc>()..add(const BreweryListStarted()),
            child: const BreweryListPage(),
          ),
        );

      case AppRoutes.breweryDetail:
        final breweryId = settings.arguments;

        if (breweryId is! String || breweryId.isEmpty) {
          return _errorRoute('Invalid brewery id.');
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<BreweryDetailCubit>()..loadBrewery(breweryId),
            child: BreweryDetailPage(breweryId: breweryId),
          ),
        );

      default:
        return _errorRoute('Route not found.');
    }
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
