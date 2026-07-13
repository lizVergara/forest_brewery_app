import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_brewery_app/features/breweries/presentation/widgets/app_empty_view.dart';
import 'package:forest_brewery_app/features/breweries/presentation/widgets/app_error_view.dart';
import 'package:forest_brewery_app/features/breweries/presentation/widgets/app_loading_view.dart';

import '../../../../../core/router/app_routes.dart';
import '../bloc/brewery_list_bloc.dart';
import '../bloc/brewery_list_event.dart';
import '../bloc/brewery_list_state.dart';
import '../widgets/brewery_list_content.dart';

class BreweryListPage extends StatefulWidget {
  const BreweryListPage({super.key});

  @override
  State<BreweryListPage> createState() => _BreweryListPageState();
}

class _BreweryListPageState extends State<BreweryListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    _searchController.dispose();

    super.dispose();
  }

  void _loadNormalListAndClearSearch() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      setState(() {});
    }

    context.read<BreweryListBloc>().add(const BreweryListRefreshRequested());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 300;

    if (isNearBottom) {
      context.read<BreweryListBloc>().add(const BreweryListNextPageRequested());
    }
  }

  void _openBreweryDetail(String breweryId) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.breweryDetail, arguments: breweryId);
  }

  Widget _buildSuccessContent(BreweryListSuccess state) {
    final showDistanceBanner =
        state.isSortingByDistance ||
        (state.isSortedByDistance && state.isLoadingMore);

    return Stack(
      children: [
        BreweryListContent(
          state: state,
          scrollController: _scrollController,
          onBreweryTap: _openBreweryDetail,
          onRefresh: () async {
            _loadNormalListAndClearSearch();
          },
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          top: showDistanceBanner ? 0 : -56,
          left: 0,
          right: 0,
          child: Material(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.isLoadingMore
                          ? 'Updating nearest breweries...'
                          : 'Sorting breweries by your location...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breweries'),
        actions: [
          BlocBuilder<BreweryListBloc, BreweryListState>(
            builder: (context, state) {
              final canSortByDistance = state is BreweryListSuccess;
              final isSortingByDistance =
                  canSortByDistance && state.isSortingByDistance;

              if (isSortingByDistance) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return IconButton(
                tooltip: 'Sort by nearest',
                icon: const Icon(Icons.my_location),
                onPressed: canSortByDistance
                    ? () {
                        context.read<BreweryListBloc>().add(
                          const BreweryListSortByDistanceRequested(),
                        );
                      }
                    : null,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search breweries',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _loadNormalListAndClearSearch,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {});

                context.read<BreweryListBloc>().add(
                  BreweryListSearchQueryChanged(value),
                );
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<BreweryListBloc, BreweryListState>(
        listenWhen: (previous, current) {
          if (current is! BreweryListSuccess) return false;

          final justSortedByDistance =
              previous is BreweryListSuccess &&
              previous.isSortingByDistance &&
              !current.isSortingByDistance &&
              current.isSortedByDistance;

          return current.loadMoreErrorMessage != null ||
              current.distanceErrorMessage != null ||
              justSortedByDistance;
        },
        listener: (context, state) {
          if (state is! BreweryListSuccess) return;

          final errorMessage =
              state.loadMoreErrorMessage ?? state.distanceErrorMessage;

          final message =
              errorMessage ??
              (state.isSortedByDistance
                  ? 'Breweries sorted by nearest location.'
                  : null);

          if (message == null) return;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            BreweryListInitial() => const SizedBox.shrink(),
            BreweryListLoading() => const AppLoadingView(),
            BreweryListEmpty() => const AppEmptyView(
              icon: Icons.local_drink_outlined,
              message: 'No breweries found.',
            ),
            BreweryListError(:final message) => AppErrorView(
              message: message,
              onRetry: _loadNormalListAndClearSearch,
            ),
            BreweryListSuccess() => _buildSuccessContent(state),
          };
        },
      ),
    );
  }
}
