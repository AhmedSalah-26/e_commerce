-- =====================================================
-- FIX: Multi-Vendor Orders Function
-- Each merchant has their own shipping price per governorate
-- =====================================================

-- Drop existing functions first
DROP FUNCTION IF EXISTS create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, UUID);
DROP FUNCTION IF EXISTS get_parent_order_details(UUID);

-- Create parent_orders table if not exists
CREATE TABLE IF NOT EXISTS parent_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0,
  delivery_address TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  notes TEXT,
  governorate_id UUID REFERENCES governorates(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add parent_order_id to orders table if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'parent_order_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN parent_order_id UUID REFERENCES parent_orders(id);
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_orders_parent_order_id ON orders(parent_order_id);
CREATE INDEX IF NOT EXISTS idx_parent_orders_user_id ON parent_orders(user_id);

-- Enable RLS
ALTER TABLE parent_orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own parent orders" ON parent_orders;
CREATE POLICY "Users can view own parent orders" ON parent_orders
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own parent orders" ON parent_orders;
CREATE POLICY "Users can create own parent orders" ON parent_orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- Create the multi-vendor order function
-- Gets shipping price for each merchant from merchant_shipping_prices table
-- =====================================================
CREATE OR REPLACE FUNCTION create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost DECIMAL DEFAULT 0,  -- Fallback if merchant has no shipping price
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
  
  -- Create parent order with total shipping for all merchants
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
    
    -- Get shipping price for this merchant from merchant_shipping_prices table
    -- If not found, use the fallback p_shipping_cost
    SELECT COALESCE(
      (SELECT price FROM merchant_shipping_prices 
       WHERE merchant_id = merchant_rec.merchant_id 
       AND governorate_id = p_governorate_id 
       AND is_active = true),
      p_shipping_cost
    ) INTO v_merchant_shipping;
    
    -- Create order for this merchant with their specific shipping cost
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
    
    -- Create order items for this merchant
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
    WHERE ci.user_id = p_user_id
    AND (p.merchant_id = merchant_rec.merchant_id OR (p.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
  END LOOP;
  
  -- Clear cart
  DELETE FROM cart_items WHERE user_id = p_user_id;
  
  RETURN v_parent_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION create_multi_vendor_order TO authenticated;

-- =====================================================
-- Create function to get parent order details
-- =====================================================
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

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Multi-vendor order functions created successfully!';
  RAISE NOTICE 'Each merchant shipping price is fetched from merchant_shipping_prices table';
END $$;
