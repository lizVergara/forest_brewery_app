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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breweries'),
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

          return current.loadMoreErrorMessage != null;
        },
        listener: (context, state) {
          if (state is! BreweryListSuccess) return;

          final message = state.loadMoreErrorMessage;

          if (message == null) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
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
            BreweryListSuccess() => BreweryListContent(
              state: state,
              scrollController: _scrollController,
              onBreweryTap: _openBreweryDetail,
              onRefresh: () async {
                _loadNormalListAndClearSearch();
              },
            ),
          };
        },
      ),
    );
  }
}
