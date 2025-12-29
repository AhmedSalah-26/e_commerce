-- =====================================================
-- Product Suspension Feature
-- Two types of deactivation:
-- 1. is_active: Merchant can toggle (out of stock, etc.)
-- 2. is_suspended: Admin only (policy violation, etc.)
-- =====================================================

-- Add is_suspended column to products
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE;

-- Add suspension_reason column
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS suspension_reason TEXT;

-- Add suspended_at timestamp
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ;

-- Add suspended_by (admin user id)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS suspended_by UUID REFERENCES profiles(id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_products_is_suspended ON products(is_suspended);

-- =====================================================
-- RLS Policy: Only admin can update suspension fields
-- =====================================================
DROP POLICY IF EXISTS "Admin can suspend products" ON products;
CREATE POLICY "Admin can suspend products" ON products
  FOR UPDATE USING (is_admin())
  WITH CHECK (is_admin());

-- =====================================================
-- Comment for documentation
-- =====================================================
COMMENT ON COLUMN products.is_suspended IS 'Admin-only suspension flag for policy violations';
COMMENT ON COLUMN products.suspension_reason IS 'Reason for admin suspension';
COMMENT ON COLUMN products.suspended_at IS 'When the product was suspended';
COMMENT ON COLUMN products.suspended_by IS 'Admin who suspended the product';
