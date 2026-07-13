import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/brewery_list_bloc.dart';
import '../bloc/brewery_list_event.dart';
import '../bloc/brewery_list_state.dart';
import 'brewery_list_item.dart';

class BreweryListContent extends StatelessWidget {
  final BreweryListSuccess state;
  final ScrollController scrollController;
  final ValueChanged<String> onBreweryTap;

  const BreweryListContent({
    required this.state,
    required this.scrollController,
    required this.onBreweryTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final breweries = state.breweries;
    final itemCount = state.isLoadingMore
        ? breweries.length + 1
        : breweries.length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BreweryListBloc>().add(
          const BreweryListRefreshRequested(),
        );
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= breweries.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final brewery = breweries[index];

          return BreweryListItem(
            brewery: brewery,
            onTap: () => onBreweryTap(brewery.id),
          );
        },
      ),
    );
  }
}
