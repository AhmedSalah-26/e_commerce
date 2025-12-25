-- =====================================================
-- RLS POLICIES FOR GLOBAL COUPONS
-- Allow admins to manage global coupons (store_id IS NULL)
-- =====================================================

-- Allow anyone to read global coupons (for validation)
DROP POLICY IF EXISTS "Anyone can view global coupons" ON coupons;
CREATE POLICY "Anyone can view global coupons" ON coupons
  FOR SELECT USING (store_id IS NULL);

-- Allow authenticated users to create global coupons (temporary - should be admin only)
-- In production, add admin role check
DROP POLICY IF EXISTS "Authenticated users can create global coupons" ON coupons;
CREATE POLICY "Authenticated users can create global coupons" ON coupons
  FOR INSERT WITH CHECK (store_id IS NULL AND auth.uid() IS NOT NULL);

-- Allow authenticated users to update global coupons (temporary - should be admin only)
DROP POLICY IF EXISTS "Authenticated users can update global coupons" ON coupons;
CREATE POLICY "Authenticated users can updaشte global coupons" ON coupons
  FOR UPDATE USING (store_id IS NULL AND auth.uid() IS NOT NULL);

-- Allow authenticated users to delete global coupons (temporary - should be admin only)
DROP POLICY IF EXISTS "Authenticated users can delete global coupons" ON coupons;
CREATE POLICY "Authenticated users can delete global coupons" ON coupons
  FOR DELETE USING (store_id IS NULL AND auth.uid() IS NOT NULL);
