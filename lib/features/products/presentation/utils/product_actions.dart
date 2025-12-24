import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';

/// Handles product actions - reduces complexity in product screen
class ProductActions {
  const ProductActions();

  /// Add product to cart
  void addToCart(BuildContext context, String productId, int quantity) {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      _showLoginRequired(context);
      return;
    }

    context.read<CartCubit>()
      ..setUserId(authState.user.id)
      ..addToCart(productId, quantity: quantity);

    Tost.showCustomToast(
      context,
      'added_to_cart'.tr(),
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Toggle product favorite status
  void toggleFavorite(BuildContext context, String productId) {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      _showLoginRequired(context);
      return;
    }

    final favoritesCubit = context.read<FavoritesCubit>();
    favoritesCubit.setUserId(authState.user.id);

    final wasFavorite = favoritesCubit.isFavorite(productId);
    favoritesCubit.toggleFavorite(productId);

    _showFavoriteToast(context, wasFavorite);
  }

  void _showLoginRequired(BuildContext context) {
    Tost.showCustomToast(
      context,
      'login_required'.tr(),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  void _showFavoriteToast(BuildContext context, bool wasRemoved) {
    Tost.showCustomToast(
      context,
      wasRemoved ? 'removed_from_favorites'.tr() : 'added_to_favorites'.tr(),
      backgroundColor: wasRemoved ? Colors.grey : Colors.red,
      textColor: Colors.white,
    );
  }

  /// Show out of stock message
  void showOutOfStock(BuildContext context) {
    Tost.showCustomToast(
      context,
      'out_of_stock'.tr(),
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
