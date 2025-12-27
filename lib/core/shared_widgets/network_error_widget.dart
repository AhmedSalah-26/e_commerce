import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/presentation/cubit/products_state.dart';

/// Widget to display when there's a network error
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'error_network'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'check_connection'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show full screen network error dialog for cart update/remove
  static void showForCartUpdate(
    BuildContext context, {
    required CartCubit cartCubit,
    required String cartItemId,
    required int quantity,
    required bool isRemove,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog.fullscreen(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          child: _CartUpdateRetryContent(
            cartCubit: cartCubit,
            cartItemId: cartItemId,
            quantity: quantity,
            isRemove: isRemove,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }

  /// Show full screen network error dialog - closes and reloads home on retry
  static void showForAddToCart(
    BuildContext context, {
    required ProductsCubit productsCubit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog.fullscreen(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          child: _ReloadHomeRetryContent(
            productsCubit: productsCubit,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }
}

class _CartUpdateRetryContent extends StatefulWidget {
  final CartCubit cartCubit;
  final String cartItemId;
  final int quantity;
  final bool isRemove;
  final VoidCallback onClose;

  const _CartUpdateRetryContent({
    required this.cartCubit,
    required this.cartItemId,
    required this.quantity,
    required this.isRemove,
    required this.onClose,
  });

  @override
  State<_CartUpdateRetryContent> createState() =>
      _CartUpdateRetryContentState();
}

class _CartUpdateRetryContentState extends State<_CartUpdateRetryContent> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);

    bool success = false;
    try {
      if (widget.isRemove) {
        success =
            await widget.cartCubit.removeFromCartDirect(widget.cartItemId);
      } else {
        success = await widget.cartCubit
            .updateQuantityDirect(widget.cartItemId, widget.quantity);
      }
    } catch (e) {
      success = false;
    }

    if (!mounted) return;

    setState(() => _isRetrying = false);

    if (success) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ErrorContent(isRetrying: _isRetrying, onRetry: _handleRetry);
  }
}

class _ReloadHomeRetryContent extends StatefulWidget {
  final ProductsCubit productsCubit;
  final VoidCallback onClose;

  const _ReloadHomeRetryContent({
    required this.productsCubit,
    required this.onClose,
  });

  @override
  State<_ReloadHomeRetryContent> createState() =>
      _ReloadHomeRetryContentState();
}

class _ReloadHomeRetryContentState extends State<_ReloadHomeRetryContent> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);

    try {
      await widget.productsCubit.loadProducts(forceReload: true);

      if (!mounted) return;

      // Check if products loaded successfully
      final state = widget.productsCubit.state;
      if (state is ProductsLoaded) {
        widget.onClose();
      } else {
        setState(() => _isRetrying = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ErrorContent(isRetrying: _isRetrying, onRetry: _handleRetry);
  }
}

class _ErrorContent extends StatelessWidget {
  final bool isRetrying;
  final VoidCallback onRetry;

  const _ErrorContent({required this.isRetrying, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'error_network'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'check_connection'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isRetrying
                  ? null
                  : () {
                      debugPrint(
                          '🔘 Retry button pressed! isRetrying=$isRetrying');
                      onRetry();
                    },
              icon: isRetrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
