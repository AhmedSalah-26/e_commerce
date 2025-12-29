import '../../cart/presentation/cubit/cart_state.dart';

/// Validation result for checkout
class CheckoutValidationResult {
  final bool isValid;
  final String? errorKey;

  const CheckoutValidationResult.valid()
      : isValid = true,
        errorKey = null;

  const CheckoutValidationResult.invalid(this.errorKey) : isValid = false;
}

/// Validator for checkout operations - reduces complexity in checkout page
class CheckoutValidator {
  const CheckoutValidator();

  /// Validate all checkout requirements
  CheckoutValidationResult validate({
    required String? governorateId,
    required Map<String, double>? merchantShippingPrices,
    required CartLoaded cartState,
  }) {
    // Check for inactive products
    final inactiveCheck = _validateActiveProducts(cartState);
    if (!inactiveCheck.isValid) {
      return inactiveCheck;
    }

    // Check governorate selection
    if (governorateId == null) {
      return const CheckoutValidationResult.invalid('select_governorate');
    }

    // Check merchant shipping availability
    final shippingCheck = _validateMerchantShipping(
      merchantShippingPrices,
      cartState,
    );
    if (!shippingCheck.isValid) {
      return shippingCheck;
    }

    return const CheckoutValidationResult.valid();
  }

  /// Check if all products in cart are active
  CheckoutValidationResult _validateActiveProducts(CartLoaded cartState) {
    for (final item in cartState.items) {
      if (item.product != null && !item.product!.isActive) {
        return const CheckoutValidationResult.invalid(
            'cart_has_inactive_products');
      }
    }
    return const CheckoutValidationResult.valid();
  }

  CheckoutValidationResult _validateMerchantShipping(
    Map<String, double>? merchantShippingPrices,
    CartLoaded cartState,
  ) {
    final merchantIds = _extractMerchantIds(cartState);

    // If no merchant shipping prices loaded, can't validate
    if (merchantShippingPrices == null || merchantShippingPrices.isEmpty) {
      // If we have merchants but no prices, shipping is not supported
      if (merchantIds.isNotEmpty) {
        return const CheckoutValidationResult.invalid('shipping_not_supported');
      }
      return const CheckoutValidationResult.valid();
    }

    // Check each merchant has shipping price for selected governorate
    for (final merchantId in merchantIds) {
      if (!merchantShippingPrices.containsKey(merchantId)) {
        return const CheckoutValidationResult.invalid('shipping_not_supported');
      }
    }

    return const CheckoutValidationResult.valid();
  }

  Set<String> _extractMerchantIds(CartLoaded cartState) {
    final merchantIds = <String>{};
    for (final item in cartState.items) {
      final merchantId = item.product?.merchantId;
      if (merchantId != null) {
        merchantIds.add(merchantId);
      }
    }
    return merchantIds;
  }
}
