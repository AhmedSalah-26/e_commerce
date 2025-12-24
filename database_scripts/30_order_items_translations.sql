-- =====================================================
-- Optimize order_items table - use JOIN with products
-- Only store: order_id, product_id, quantity, price
-- Get name, image, description from products table
-- =====================================================

-- Note: We keep product_name and product_image for backward compatibility
-- and for cases where product might be deleted
-- But we'll use JOIN to get fresh translated data

-- Update the queries to JOIN with products table for translations
-- This is done in the Flutter app by modifying order_fetch_mixin.dart

-- =====================================================
-- Update create_multi_vendor_order function
-- Store minimal data, rely on JOIN for translations
-- =====================================================
DROP FUNCTION IF EXISTS create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, UUID);

CREATE OR REPLACE FUNCTION create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost DECIMAL DEFAULT 0,
  p_governorate_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_parent_order_id UUID;
  v_order_id UUID;
  v_merchant_subtotal DECIMAL;
  v_merchant_shipping DECIMAL;
  v_total_subtotal DECIMAL := 0;
  v_total_shipping DECIMAL := 0;
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
  
  -- Create parent order
  INSERT INTO parent_orders (
    user_id, total, subtotal, shipping_cost,
    delivery_address, customer_name, customer_phone, notes, governorate_id
  )
  VALUES (
    p_user_id,
    v_total_subtotal + v_total_shipping,
    v_total_subtotal,
    v_total_shipping,
    p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id
  )
  RETURNING id INTO v_parent_order_id;
  
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
    
    -- Create order items - store only essential data
    -- Name/image stored as fallback if product deleted
    INSERT INTO order_items (
      order_id, product_id, 
      product_name, product_image,
      quantity, price
    )
    SELECT 
      v_order_id,
      ci.product_id,
      COALESCE(p.name_ar, p.name_en, 'منتج'),  -- Fallback name
      p.images[1],  -- Fallback image
      ci.quantity,
      COALESCE(p.discount_price, p.price)  -- Price at time of purchase
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

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Order function updated - uses JOIN for product translations';
END $$;
