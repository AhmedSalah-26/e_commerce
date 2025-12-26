import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
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
      // Only load if not already loaded
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

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'favorites'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              fontSize: 24,
              color: AppColours.brownMedium,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, authState) {
            // Reset favorites when user logs out
            if (_previousAuthState is AuthAuthenticated &&
                authState is! AuthAuthenticated) {
              context.read<FavoritesCubit>().reset();
            }
            _previousAuthState = authState;
          },
          builder: (context, authState) {
            // Check if user is authenticated first
            if (authState is! AuthAuthenticated) {
              return _buildLoginRequired();
            }

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoading) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: ProductsGridSkeleton(itemCount: 4),
                  );
                }

                if (state is FavoritesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadFavorites,
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  );
                }

                if (state is FavoritesLoaded) {
                  // Filter favorites that have valid products
                  final validFavorites =
                      state.favorites.where((f) => f.product != null).toList();

                  if (validFavorites.isEmpty) {
                    return _buildEmptyFavorites();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadFavorites(),
                    child: GridView.builder(
                      controller: _scrollController,
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

                // FavoritesInitial state - show shimmer loading
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

  Widget _buildEmptyFavorites() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColours.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'no_favorites'.tr(),
              style: AppTextStyle.semiBold_16_dark_brown,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'no_favorites_desc'.tr(),
              style: AppTextStyle.normal_14_greyDark,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColours.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 64,
                color: AppColours.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'login_required'.tr(),
              style: AppTextStyle.semiBold_20_dark_brown,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'login_to_see_favorites'.tr(),
              style: AppTextStyle.normal_14_greyDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  AppRouter.setAuthenticated(false);
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.brownLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'login'.tr(),
                  style: AppTextStyle.semiBold_18_white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
