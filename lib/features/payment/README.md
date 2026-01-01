# Paymob Payment Integration

## Setup

### 1. Get Paymob Credentials

1. Create account at [Paymob Accept](https://accept.paymob.com)
2. Go to Settings → Account Info to get your **API Key**
3. Go to Settings → Payment Integrations:
   - Create **Card** integration → get `integrationId`
4. Go to Settings → iFrames → get `iFrameId`

### 2. Configure Credentials

Edit `lib/core/config/paymob_config.dart` with your credentials.

### 3. Database Setup

Run the SQL migration to add payment fields:
```sql
-- Run database_scripts/add_payment_fields.sql in Supabase
```

### 4. Deploy Webhook (Edge Function)

```bash
supabase functions deploy paymob-webhook
```

### 5. Configure Paymob Webhook

1. Go to Paymob Dashboard → Developers → Webhooks
2. Add webhook URL: `https://YOUR_PROJECT.supabase.co/functions/v1/paymob-webhook`
3. Select events: Transaction processed

## Payment Flow

1. User selects "Card Payment" and clicks "Place Order"
2. Order is created with `payment_status: pending`
3. Payment page opens with Paymob iFrame
4. User completes payment
5. Paymob sends webhook to Edge Function
6. Edge Function updates order `payment_status` to `paid` or `failed`

## Test Cards

| Card Number | Expiry | CVV | Result |
|-------------|--------|-----|--------|
| 5123456789012346 | 12/30 | 123 | Success |
| 5123456789012346 | 12/20 | 111 | Declined |
