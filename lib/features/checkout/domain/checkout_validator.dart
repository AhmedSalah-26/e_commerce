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

  CheckoutValidationResult _validateMerchantShipping(
    Map<String, double>? merchantShippingPrices,
    CartLoaded cartState,
  ) {
    if (merchantShippingPrices == null || merchantShippingPrices.isEmpty) {
      return const CheckoutValidationResult.valid();
    }

    final merchantIds = _extractMerchantIds(cartState);

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
