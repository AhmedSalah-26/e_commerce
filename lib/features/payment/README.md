# Paymob Payment Integration

## Setup

### 1. Get Paymob Credentials

1. Create account at [Paymob Accept](https://accept.paymob.com)
2. Go to Settings → Account Info to get your **API Key**
3. Go to Settings → Payment Integrations:
   - Create **Card** integration → get `integrationId`
   - Create **Mobile Wallet** integration → get `walletIntegrationId`
4. Go to Settings → iFrames → get `iFrameId`

### 2. Configure Credentials

Edit `lib/core/config/paymob_config.dart`:

```dart
class PaymobConfig {
  static const String apiKey = 'YOUR_ACTUAL_API_KEY';
  static const int integrationId = 123456;        // Card integration
  static const int walletIntegrationId = 654321;  // Wallet integration
  static const int iFrameId = 789012;             // iFrame ID
}
```

### 3. Usage

The payment is automatically initialized in `main.dart` if configured.

#### In Checkout:
Payment method selector is already integrated in checkout page.

#### Manual Usage:

```dart
// Card Payment
final result = await PaymobService.instance.payWithCard(
  context: context,
  amount: 150.0,
  currency: 'EGP',
);

if (result.success) {
  print('Transaction ID: ${result.transactionId}');
}

// Wallet Payment
final result = await PaymobService.instance.payWithWallet(
  context: context,
  amount: 150.0,
  phoneNumber: '01010101010',
);
```

## Test Cards

| Type | Number | Expiry | CVV |
|------|--------|--------|-----|
| Card | 5123 4567 8901 2346 | 12/25 | 123 |

## Test Wallet

| Phone | OTP |
|-------|-----|
| 01010101010 | 123456 |

## Payment Flow

1. User selects payment method in checkout
2. For Cash on Delivery → Order created directly
3. For Card/Wallet → Paymob payment screen opens
4. On success → Order created with transaction ID
5. On failure → Error message shown

## Files Structure

```
lib/features/payment/
├── domain/
│   └── entities/
│       ├── payment_method.dart
│       └── payment_result.dart
├── data/
│   └── services/
│       └── paymob_service.dart
├── presentation/
│   ├── cubit/
│   │   ├── payment_cubit.dart
│   │   └── payment_state.dart
│   └── widgets/
│       └── payment_method_selector.dart
├── payment.dart (exports)
└── README.md
```
