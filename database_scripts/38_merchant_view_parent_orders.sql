-- =====================================================
-- ALLOW MERCHANTS TO VIEW PARENT ORDERS FOR THEIR ORDERS
-- =====================================================

-- Allow merchants to view parent_orders that contain their orders
DROP POLICY IF EXISTS "Merchants can view parent orders of their orders" ON parent_orders;
CREATE POLICY "Merchants can view parent orders of their orders" ON parent_orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders o
      WHERE o.parent_order_id = parent_orders.id
      AND o.merchant_id = auth.uid()
    )
  );
