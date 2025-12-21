-- =====================================================
-- FIX CREATE ORDER FROM CART FUNCTION
-- Use name_ar instead of name column
-- =====================================================

CREATE OR REPLACE FUNCTION create_order_from_cart(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_order_id UUID;
  v_total DECIMAL;
BEGIN
  -- Calculate total
  SELECT get_cart_total(p_user_id) INTO v_total;
  
  -- Check if cart is empty
  IF v_total = 0 THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Create order
  INSERT INTO orders (user_id, total, subtotal, delivery_address, customer_name, customer_phone, notes)
  VALUES (p_user_id, v_total, v_total, p_delivery_address, p_customer_name, p_customer_phone, p_notes)
  RETURNING id INTO v_order_id;
  
  -- Create order items from cart (using name_ar instead of name)
  INSERT INTO order_items (order_id, product_id, product_name, product_image, quantity, price)
  SELECT 
    v_order_id,
    ci.product_id,
    COALESCE(p.name_ar, p.name_en, 'منتج'),
    p.images[1],
    ci.quantity,
    COALESCE(p.discount_price, p.price)
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Clear cart
  PERFORM clear_user_cart(p_user_id);
  
  RETURN v_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
