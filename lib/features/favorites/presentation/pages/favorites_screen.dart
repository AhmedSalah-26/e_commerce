import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  AuthState? _previousAuthState;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _previousAuthState = context.read<AuthCubit>().state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<FavoritesCubit>().loadMoreFavorites();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _loadFavoritesIfNeeded() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final currentState = context.read<FavoritesCubit>().state;
      if (currentState is! FavoritesLoaded) {
        _loadFavorites();
      }
    }
  }

  void _loadFavorites() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final locale = context.locale.languageCode;
      context.read<FavoritesCubit>().setLocale(locale);
      context.read<FavoritesCubit>().loadFavorites(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'favorites'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (_previousAuthState is AuthAuthenticated &&
                authState is! AuthAuthenticated) {
              context.read<FavoritesCubit>().reset();
            }
            _previousAuthState = authState;
          },
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return EmptyStates.loginRequired(context,
                  message: 'login_to_see_favorites'.tr());
            }

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoading) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: ProductsGridSkeleton(itemCount: 4),
                  );
                }

                // Full screen error - no cached data shown
                if (state is FavoritesError) {
                  return SizedBox.expand(
                    child: NetworkErrorWidget(
                      message:
                          ErrorHelper.getUserFriendlyMessage(state.message),
                      onRetry: _loadFavorites,
                    ),
                  );
                }

                if (state is FavoritesLoaded) {
                  final validFavorites =
                      state.favorites.where((f) => f.product != null).toList();

                  if (validFavorites.isEmpty) {
                    return EmptyStates.noFavorites(context);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadFavorites(),
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: validFavorites.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      cacheExtent: 500,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: ProductGridCard(
                            key: ValueKey(validFavorites[index].id),
                            product: validFavorites[index].product!,
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: ProductsGridSkeleton(itemCount: 4),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
