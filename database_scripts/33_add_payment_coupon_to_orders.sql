-- =====================================================
-- ADD PAYMENT METHOD & COUPON FIELDS TO PARENT_ORDERS
-- =====================================================

-- 1. Add payment_method column
ALTER TABLE parent_orders 
ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'cash_on_delivery';

-- 2. Add coupon fields
ALTER TABLE parent_orders 
ADD COLUMN IF NOT EXISTS coupon_id UUID REFERENCES coupons(id),
ADD COLUMN IF NOT EXISTS coupon_code TEXT,
ADD COLUMN IF NOT EXISTS coupon_discount DECIMAL(10,2) DEFAULT 0;

-- 3. Update create_multi_vendor_order function to support payment & coupon
DROP FUNCTION IF EXISTS create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, UUID);
DROP FUNCTION IF EXISTS create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, UUID, TEXT, UUID, TEXT, DECIMAL);

CREATE OR REPLACE FUNCTION create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost DECIMAL DEFAULT 0,
  p_governorate_id UUID DEFAULT NULL,
  p_payment_method TEXT DEFAULT 'cash_on_delivery',
  p_coupon_id UUID DEFAULT NULL,
  p_coupon_code TEXT DEFAULT NULL,
  p_coupon_discount DECIMAL DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
  v_parent_order_id UUID;
  v_order_id UUID;
  v_merchant_subtotal DECIMAL;
  v_merchant_shipping DECIMAL;
  v_total_subtotal DECIMAL := 0;
  v_total_shipping DECIMAL := 0;
  v_final_total DECIMAL;
  merchant_rec RECORD;
BEGIN
  -- Check if cart is empty
  IF NOT EXISTS (SELECT 1 FROM cart_items WHERE user_id = p_user_id) THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Calculate total subtotal first
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_total_subtotal
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Calculate total shipping by summing each merchant's shipping price
  SELECT COALESCE(SUM(
    COALESCE(
      (SELECT price FROM merchant_shipping_prices 
       WHERE merchant_id = sub.merchant_id 
       AND governorate_id = p_governorate_id 
       AND is_active = true),
      p_shipping_cost
    )
  ), 0) INTO v_total_shipping
  FROM (
    SELECT DISTINCT p.merchant_id
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
  ) sub;
  
  -- Calculate final total with coupon discount
  v_final_total := v_total_subtotal + v_total_shipping - COALESCE(p_coupon_discount, 0);
  
  -- Create parent order
  INSERT INTO parent_orders (
    user_id, total, subtotal, shipping_cost,
    delivery_address, customer_name, customer_phone, notes, governorate_id,
    payment_method, coupon_id, coupon_code, coupon_discount
  )
  VALUES (
    p_user_id,
    v_final_total,
    v_total_subtotal,
    v_total_shipping,
    p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id,
    COALESCE(p_payment_method, 'cash_on_delivery'),
    p_coupon_id,
    p_coupon_code,
    COALESCE(p_coupon_discount, 0)
  )
  RETURNING id INTO v_parent_order_id;
  
  -- Increment coupon usage if used
  IF p_coupon_id IS NOT NULL THEN
    UPDATE coupons SET usage_count = usage_count + 1 WHERE id = p_coupon_id;
    
    -- Record usage in coupon_usages table
    INSERT INTO coupon_usages (coupon_id, user_id, order_id, discount_amount)
    VALUES (p_coupon_id, p_user_id, v_parent_order_id, COALESCE(p_coupon_discount, 0));
  END IF;
  
  -- Create orders for each merchant
  FOR merchant_rec IN 
    SELECT DISTINCT p.merchant_id
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
  LOOP
    -- Calculate subtotal for this merchant
    SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_merchant_subtotal
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (p.merchant_id = merchant_rec.merchant_id OR (p.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
    
    -- Get shipping price for this merchant
    SELECT COALESCE(
      (SELECT price FROM merchant_shipping_prices 
       WHERE merchant_id = merchant_rec.merchant_id 
       AND governorate_id = p_governorate_id 
       AND is_active = true),
      p_shipping_cost
    ) INTO v_merchant_shipping;
    
    -- Create order for this merchant
    INSERT INTO orders (
      user_id, merchant_id, parent_order_id,
      total, subtotal, shipping_cost,
      delivery_address, customer_name, customer_phone, notes,
      governorate_id, status
    )
    VALUES (
      p_user_id,
      merchant_rec.merchant_id,
      v_parent_order_id,
      v_merchant_subtotal + v_merchant_shipping,
      v_merchant_subtotal,
      v_merchant_shipping,
      p_delivery_address, p_customer_name, p_customer_phone, p_notes,
      p_governorate_id, 'pending'
    )
    RETURNING id INTO v_order_id;
    
    -- Create order items - minimal data only (product_name/image fetched via JOIN)
    INSERT INTO order_items (order_id, product_id, quantity, price)
    SELECT 
      v_order_id,
      ci.product_id,
      ci.quantity,
      COALESCE(p.discount_price, p.price)
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (p.merchant_id = merchant_rec.merchant_id OR (p.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
  END LOOP;
  
  -- Clear cart
  DELETE FROM cart_items WHERE user_id = p_user_id;
  
  RETURN v_parent_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION create_multi_vendor_order TO authenticated;

-- 4. Update get_parent_order_details to include payment & coupon
DROP FUNCTION IF EXISTS get_parent_order_details(UUID);

CREATE OR REPLACE FUNCTION get_parent_order_details(p_parent_order_id UUID)
RETURNS TABLE (
  parent_order_id UUID,
  parent_total DECIMAL,
  parent_subtotal DECIMAL,
  parent_shipping_cost DECIMAL,
  delivery_address TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  notes TEXT,
  parent_created_at TIMESTAMPTZ,
  payment_method TEXT,
  coupon_id UUID,
  coupon_code TEXT,
  coupon_discount DECIMAL,
  order_id UUID,
  merchant_id UUID,
  merchant_name TEXT,
  merchant_phone TEXT,
  order_total DECIMAL,
  order_subtotal DECIMAL,
  order_shipping_cost DECIMAL,
  order_status TEXT,
  order_created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    po.id as parent_order_id,
    po.total as parent_total,
    po.subtotal as parent_subtotal,
    po.shipping_cost as parent_shipping_cost,
    po.delivery_address,
    po.customer_name,
    po.customer_phone,
    po.notes,
    po.created_at as parent_created_at,
    po.payment_method,
    po.coupon_id,
    po.coupon_code,
    po.coupon_discount,
    o.id as order_id,
    o.merchant_id,
    COALESCE(s.name, pr.name) as merchant_name,
    COALESCE(s.phone, pr.phone) as merchant_phone,
    o.total as order_total,
    o.subtotal as order_subtotal,
    o.shipping_cost as order_shipping_cost,
    o.status as order_status,
    o.created_at as order_created_at
  FROM parent_orders po
  LEFT JOIN orders o ON o.parent_order_id = po.id
  LEFT JOIN stores s ON s.merchant_id = o.merchant_id
  LEFT JOIN profiles pr ON pr.id = o.merchant_id
  WHERE po.id = p_parent_order_id
  ORDER BY o.created_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_parent_order_details TO authenticated;
