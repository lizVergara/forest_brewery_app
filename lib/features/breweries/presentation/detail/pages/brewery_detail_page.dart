import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_brewery_app/features/breweries/presentation/widgets/app_error_view.dart';
import 'package:forest_brewery_app/features/breweries/presentation/widgets/app_loading_view.dart';

import '../cubit/brewery_detail_cubit.dart';
import '../cubit/brewery_detail_state.dart';
import '../widgets/brewery_detail_content.dart';

class BreweryDetailPage extends StatelessWidget {
  final String breweryId;

  const BreweryDetailPage({required this.breweryId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brewery detail')),
      body: BlocBuilder<BreweryDetailCubit, BreweryDetailState>(
        builder: (context, state) {
          return switch (state) {
            BreweryDetailInitial() => const SizedBox.shrink(),
            BreweryDetailLoading() => const AppLoadingView(),
            BreweryDetailError(:final message) => AppErrorView(
              message: message,
              onRetry: () {
                context.read<BreweryDetailCubit>().loadBrewery(breweryId);
              },
            ),
            BreweryDetailSuccess(:final brewery) => BreweryDetailContent(
              brewery: brewery,
            ),
          };
        },
      ),
    );
  }
}
