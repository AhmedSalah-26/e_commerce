-- =====================================================
-- Allow merchants to view products in orders they received
-- =====================================================
-- Problem: Merchants can't see product details in orders
-- because RLS blocks access when the product belongs to them
-- but they're querying via order_items JOIN.
--
-- Solution: Add a policy that allows merchants to view products
-- that are in orders assigned to them.
-- =====================================================

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Merchants can view products in their orders" ON products;

-- Create new policy: Merchants can view products in orders assigned to them
CREATE POLICY "Merchants can view products in their orders"
  ON products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = products.id
      AND o.merchant_id = auth.uid()
    )
  );

-- =====================================================
-- Verification
-- =====================================================
DO $
BEGIN
  RAISE NOTICE 'Policy created:';
  RAISE NOTICE '  - Merchants can view products in orders assigned to them';
END $;
