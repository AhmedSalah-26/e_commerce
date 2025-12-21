-- =====================================================
-- FIX CREATE ORDER FROM CART FUNCTION
-- Add merchant_id to orders based on product owner
-- =====================================================

-- First, let's check if merchant_id column exists in orders table
-- If not, add it
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'merchant_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN merchant_id UUID REFERENCES profiles(id);
  END IF;
END $$;

-- Update the create_order_from_cart function to include merchant_id
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
  v_merchant_id UUID;
BEGIN
  -- Calculate total
  SELECT get_cart_total(p_user_id) INTO v_total;
  
  -- Check if cart is empty
  IF v_total = 0 THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Get merchant_id from the first product in cart
  -- (Assuming all products in cart belong to same merchant)
  SELECT p.merchant_id INTO v_merchant_id
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id
  LIMIT 1;
  
  -- Create order with merchant_id
  INSERT INTO orders (user_id, merchant_id, total, subtotal, delivery_address, customer_name, customer_phone, notes)
  VALUES (p_user_id, v_merchant_id, v_total, v_total, p_delivery_address, p_customer_name, p_customer_phone, p_notes)
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

-- Update existing orders that don't have merchant_id
-- Set merchant_id based on the first product in order_items
UPDATE orders o
SET merchant_id = (
  SELECT p.merchant_id
  FROM order_items oi
  JOIN products p ON p.id = oi.product_id
  WHERE oi.order_id = o.id
  LIMIT 1
)
WHERE o.merchant_id IS NULL;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION create_order_from_cart TO authenticated;
