-- Drop existing functions first
DROP FUNCTION IF EXISTS get_merchant_orders_filtered(UUID, TEXT, INT, INT);
DROP FUNCTION IF EXISTS get_merchant_orders_count_filtered(UUID);

-- Function to get merchant orders filtered by payment status
-- Only returns: cash_on_delivery OR (card/wallet payments that are paid)
CREATE OR REPLACE FUNCTION get_merchant_orders_filtered(
  p_merchant_id UUID,
  p_status TEXT DEFAULT NULL,
  p_limit INT DEFAULT 50,
  p_offset INT DEFAULT 0
)
RETURNS SETOF orders
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT o.*
  FROM orders o
  WHERE o.merchant_id = p_merchant_id
    -- Filter: show only cash_on_delivery OR paid card/wallet payments
    AND (
      o.payment_method IS NULL 
      OR o.payment_method = 'cash_on_delivery'
      OR o.payment_method = 'pending'
      OR (o.payment_method = 'card' AND o.payment_status = 'paid')
      OR (o.payment_method = 'wallet' AND o.payment_status = 'paid')
    )
    -- Optional status filter
    AND (p_status IS NULL OR o.status = p_status)
  ORDER BY o.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_merchant_orders_filtered TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_orders_filtered TO anon;

-- Function to count merchant orders (filtered)
CREATE OR REPLACE FUNCTION get_merchant_orders_count_filtered(
  p_merchant_id UUID
)
RETURNS TABLE (
  total_pending BIGINT,
  today_delivered BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_start_of_day TIMESTAMPTZ;
BEGIN
  v_start_of_day := DATE_TRUNC('day', NOW());
  
  RETURN QUERY
  SELECT 
    COUNT(*) FILTER (WHERE o.status = 'pending') AS total_pending,
    COUNT(*) FILTER (WHERE o.status = 'delivered' AND o.updated_at >= v_start_of_day) AS today_delivered
  FROM orders o
  WHERE o.merchant_id = p_merchant_id
    AND (
      o.payment_method IS NULL 
      OR o.payment_method = 'cash_on_delivery'
      OR o.payment_method = 'pending'
      OR (o.payment_method = 'card' AND o.payment_status = 'paid')
      OR (o.payment_method = 'wallet' AND o.payment_status = 'paid')
    );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_merchant_orders_count_filtered TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_orders_count_filtered TO anon;
