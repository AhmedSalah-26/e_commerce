import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesIfNeeded();
    });
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
          elevation: 0,
          title: Text(
            'favorites'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              fontSize: 24,
              color: AppColours.brownMedium,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            // Check if user is authenticated first
            final authState = context.read<AuthCubit>().state;
            if (authState is! AuthAuthenticated) {
              return _buildLoginRequired();
            }

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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: validFavorites.length,
                  itemBuilder: (context, index) {
                    return ProductGridCard(
                        product: validFavorites[index].product!);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 100,
            color: AppColours.greyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'login_required'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown,
          ),
          const SizedBox(height: 10),
          Text(
            'login_to_see_favorites'.tr(),
            style: AppTextStyle.normal_16_greyDark,
          ),
        ],
      ),
    );
  }
}
