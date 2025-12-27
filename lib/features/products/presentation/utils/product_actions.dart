import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';

/// Handles product actions - reduces complexity in product screen
class ProductActions {
  const ProductActions();

  /// Add product to cart
  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      _showLoginRequired(context);
      return;
    }

    final cartCubit = context.read<CartCubit>();
    cartCubit.setUserId(authState.user.id);

    // Store current state to detect changes
    final stateBefore = cartCubit.state;

    await cartCubit.addToCart(productId, quantity: quantity);

    // Check the result
    if (!context.mounted) return;

    final stateAfter = cartCubit.state;

    if (stateAfter is CartError) {
      Tost.showCustomToast(
        context,
        stateAfter.message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (stateAfter is CartLoaded) {
      // Check if item was actually added (cart has more items or same item quantity increased)
      final itemsBefore =
          stateBefore is CartLoaded ? stateBefore.items.length : 0;
      final itemsAfter = stateAfter.items.length;

      if (itemsAfter >= itemsBefore) {
        Tost.showCustomToast(
          context,
          'added_to_cart'.tr(),
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    }
  }

  /// Toggle product favorite status
  Future<void> toggleFavorite(BuildContext context, String productId) async {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      _showLoginRequired(context);
      return;
    }

    final favoritesCubit = context.read<FavoritesCubit>();
    favoritesCubit.setUserId(authState.user.id);

    final wasFavorite = favoritesCubit.isFavorite(productId);

    // Await the result first
    final success = await favoritesCubit.toggleFavorite(productId);

    if (!context.mounted) return;

    // Show appropriate toast based on result
    if (success) {
      _showFavoriteToast(context, wasFavorite);
    } else {
      Tost.showCustomToast(
        context,
        'error_favorite_failed'.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showLoginRequired(BuildContext context) {
    Tost.showCustomToast(
      context,
      'login_required'.tr(),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  void _showFavoriteToast(BuildContext context, bool willBeRemoved) {
    Tost.showCustomToast(
      context,
      willBeRemoved ? 'removed_from_favorites'.tr() : 'added_to_favorites'.tr(),
      backgroundColor: willBeRemoved ? Colors.grey : Colors.red,
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
