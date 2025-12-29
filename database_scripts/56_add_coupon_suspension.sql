-- =====================================================
-- ADD COUPON SUSPENSION COLUMNS
-- =====================================================

-- Add suspension columns to coupons table
ALTER TABLE coupons 
ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS suspension_reason TEXT,
ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS suspended_by UUID REFERENCES auth.users(id);

-- Create index for suspended coupons
CREATE INDEX IF NOT EXISTS idx_coupons_suspended ON coupons(is_suspended) WHERE is_suspended = true;

-- Update the coupons select policy to exclude suspended coupons for non-admins
DROP POLICY IF EXISTS "Coupons select policy" ON coupons;

CREATE POLICY "Coupons select policy" ON coupons
  AS PERMISSIVE
  FOR SELECT USING (
    -- Active and not suspended coupons visible to everyone
    (is_active = true AND (is_suspended IS NULL OR is_suspended = false) AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()))
    -- Merchants can see their own coupons
    OR store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    -- Admins can see all
    OR is_admin()
  );

COMMENT ON COLUMN coupons.is_suspended IS 'Whether the coupon is suspended by admin';
COMMENT ON COLUMN coupons.suspension_reason IS 'Reason for suspension';
COMMENT ON COLUMN coupons.suspended_at IS 'When the coupon was suspended';
COMMENT ON COLUMN coupons.suspended_by IS 'Admin who suspended the coupon';
