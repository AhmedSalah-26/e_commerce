-- Function to get merchant orders filtered by payment status
-- Only returns: cash_on_delivery OR card payments that are paid
CREATE OR REPLACE FUNCTION get_merchant_orders_filtered(
  p_merchant_id UUID,
  p_status TEXT DEFAULT NULL,
  p_limit INT DEFAULT 50,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  merchant_id UUID,
  parent_order_id UUID,
  status TEXT,
  total DECIMAL,
  subtotal DECIMAL,
  discount DECIMAL,
  shipping_cost DECIMAL,
  delivery_address TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  notes TEXT,
  admin_notes TEXT,
  governorate_id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  -- Parent order payment info
  payment_method TEXT,
  payment_status TEXT,
  coupon_code TEXT,
  coupon_discount DECIMAL,
  -- Governorate info
  governorate_name_ar TEXT,
  governorate_name_en TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    o.id,
    o.user_id,
    o.merchant_id,
    o.parent_order_id,
    o.status,
    o.total,
    o.subtotal,
    o.discount,
    o.shipping_cost,
    o.delivery_address,
    o.customer_name,
    o.customer_phone,
    o.notes,
    o.admin_notes,
    o.governorate_id,
    o.created_at,
    o.updated_at,
    -- Payment info from parent order
    po.payment_method,
    po.payment_status,
    po.coupon_code,
    CASE 
      WHEN po.subtotal > 0 AND po.coupon_discount > 0 
      THEN (o.subtotal / po.subtotal) * po.coupon_discount
      ELSE 0
    END AS coupon_discount,
    -- Governorate info
    g.name_ar AS governorate_name_ar,
    g.name_en AS governorate_name_en
  FROM orders o
  LEFT JOIN parent_orders po ON o.parent_order_id = po.id
  LEFT JOIN governorates g ON o.governorate_id = g.id
  WHERE o.merchant_id = p_merchant_id
    -- Filter: show only cash_on_delivery OR paid card payments
    AND (
      po.payment_method IS NULL 
      OR po.payment_method = 'cash_on_delivery'
      OR (po.payment_method = 'card' AND po.payment_status = 'paid')
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
  LEFT JOIN parent_orders po ON o.parent_order_id = po.id
  WHERE o.merchant_id = p_merchant_id
    AND (
      po.payment_method IS NULL 
      OR po.payment_method = 'cash_on_delivery'
      OR (po.payment_method = 'card' AND po.payment_status = 'paid')
    );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_merchant_orders_count_filtered TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_orders_count_filtered TO anon;

-- ============================================
-- VIEW for Real-time Streams (filtered orders)
-- ============================================
CREATE OR REPLACE VIEW merchant_orders_view AS
SELECT 
  o.id,
  o.user_id,
  o.merchant_id,
  o.parent_order_id,
  o.status,
  o.total,
  o.subtotal,
  o.discount,
  o.shipping_cost,
  o.delivery_address,
  o.customer_name,
  o.customer_phone,
  o.notes,
  o.admin_notes,
  o.governorate_id,
  o.created_at,
  o.updated_at,
  -- Payment info from parent order
  COALESCE(po.payment_method, 'cash_on_delivery') AS payment_method,
  po.payment_status,
  po.coupon_code,
  CASE 
    WHEN po.subtotal > 0 AND po.coupon_discount > 0 
    THEN (o.subtotal / po.subtotal) * po.coupon_discount
    ELSE 0
  END AS coupon_discount,
  -- Governorate info
  g.name_ar AS governorate_name_ar,
  g.name_en AS governorate_name_en
FROM orders o
LEFT JOIN parent_orders po ON o.parent_order_id = po.id
LEFT JOIN governorates g ON o.governorate_id = g.id
WHERE (
  po.payment_method IS NULL 
  OR po.payment_method = 'cash_on_delivery'
  OR (po.payment_method = 'card' AND po.payment_status = 'paid')
);

-- Enable RLS on the view (important for security)
ALTER VIEW merchant_orders_view SET (security_invoker = on);

-- Grant access
GRANT SELECT ON merchant_orders_view TO authenticated;
GRANT SELECT ON merchant_orders_view TO anon;

-- Enable realtime for the view
ALTER PUBLICATION supabase_realtime ADD TABLE merchant_orders_view;
