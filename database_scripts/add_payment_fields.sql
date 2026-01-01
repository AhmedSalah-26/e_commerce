-- Add payment fields to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'cash_on_delivery',
ADD COLUMN IF NOT EXISTS payment_transaction_id TEXT,
ADD COLUMN IF NOT EXISTS payment_amount DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS payment_currency TEXT DEFAULT 'EGP';

-- Add payment fields to parent_orders table
ALTER TABLE parent_orders 
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'cash_on_delivery',
ADD COLUMN IF NOT EXISTS payment_transaction_id TEXT,
ADD COLUMN IF NOT EXISTS payment_amount DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS payment_currency TEXT DEFAULT 'EGP';

-- Create index for payment status queries
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_parent_orders_payment_status ON parent_orders(payment_status);

-- Comment: Payment status values
-- 'pending' - Waiting for online payment
-- 'paid' - Payment successful
-- 'failed' - Payment failed
-- 'refunded' - Payment refunded
-- 'cash_on_delivery' - No online payment, pay on delivery
