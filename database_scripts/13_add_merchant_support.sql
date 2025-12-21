-- Add merchant support to products and orders
-- This allows merchants to manage their own products and see their orders

-- Add merchant_id to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS merchant_id UUID REFERENCES profiles(id) ON DELETE CASCADE;

-- Create index for merchant products queries
CREATE INDEX IF NOT EXISTS idx_products_merchant ON products(merchant_id);

-- Add merchant_id to orders table (to track which merchant the order is for)
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS merchant_id UUID REFERENCES profiles(id);

-- Create index for merchant orders queries
CREATE INDEX IF NOT EXISTS idx_orders_merchant ON orders(merchant_id);

-- Update existing products to have a default merchant (optional - for testing)
-- You can set this to a specific merchant user ID if needed
-- UPDATE products SET merchant_id = (SELECT id FROM profiles WHERE role = 'merchant' LIMIT 1) WHERE merchant_id IS NULL;
