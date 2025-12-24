-- =====================================================
-- Allow users to view inactive products in their orders
-- =====================================================
-- Problem: When a merchant deactivates a product, users can't see
-- product details in their order history because RLS blocks access
-- to inactive products.
--
-- Solution: Add a policy that allows users to view products
-- that are in their order_items, regardless of is_active status.
-- =====================================================

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can view products in their orders" ON products;

-- Create new policy: Users can view products that are in their orders
CREATE POLICY "Users can view products in their orders"
  ON products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = products.id
      AND o.user_id = auth.uid()
    )
  );

-- =====================================================
-- Also allow viewing inactive products in cart and favorites
-- =====================================================

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can view products in their cart" ON products;

-- Users can view products in their cart (even if inactive)
CREATE POLICY "Users can view products in their cart"
  ON products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM cart_items ci
      WHERE ci.product_id = products.id
      AND ci.user_id = auth.uid()
    )
  );

-- Drop existing policy if it exists  
DROP POLICY IF EXISTS "Users can view products in their favorites" ON products;

-- Users can view products in their favorites (even if inactive)
CREATE POLICY "Users can view products in their favorites"
  ON products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM favorites f
      WHERE f.product_id = products.id
      AND f.user_id = auth.uid()
    )
  );

-- =====================================================
-- Verification
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE 'Policies created:';
  RAISE NOTICE '  - Users can view inactive products in their order history';
  RAISE NOTICE '  - Users can view inactive products in their cart';
  RAISE NOTICE '  - Users can view inactive products in their favorites';
END $$;
