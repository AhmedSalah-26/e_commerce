-- Helper Functions and Triggers
-- Run this script after 02_rls_policies.sql

-- =====================================================
-- AUTO-CREATE PROFILE ON USER SIGNUP
-- =====================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- DECREASE STOCK ON ORDER CREATION
-- =====================================================
CREATE OR REPLACE FUNCTION decrease_product_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET stock = stock - NEW.quantity
  WHERE id = NEW.product_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to decrease stock when order item is created
DROP TRIGGER IF EXISTS on_order_item_created ON order_items;
CREATE TRIGGER on_order_item_created
  AFTER INSERT ON order_items
  FOR EACH ROW EXECUTE FUNCTION decrease_product_stock();

-- =====================================================
-- RESTORE STOCK ON ORDER CANCELLATION
-- =====================================================
CREATE OR REPLACE FUNCTION restore_stock_on_cancel()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    UPDATE products p
    SET stock = stock + oi.quantity
    FROM order_items oi
    WHERE oi.order_id = NEW.id AND p.id = oi.product_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to restore stock when order is cancelled
DROP TRIGGER IF EXISTS on_order_cancelled ON orders;
CREATE TRIGGER on_order_cancelled
  AFTER UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION restore_stock_on_cancel();

-- =====================================================
-- GET CART TOTAL FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION get_cart_total(p_user_id UUID)
RETURNS DECIMAL AS $$
DECLARE
  total DECIMAL;
BEGIN
  SELECT COALESCE(SUM(
    ci.quantity * COALESCE(p.discount_price, p.price)
  ), 0)
  INTO total
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  RETURN total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- GET PRODUCT COUNT BY CATEGORY
-- =====================================================
CREATE OR REPLACE FUNCTION get_product_count_by_category(p_category_id UUID)
RETURNS INTEGER AS $$
DECLARE
  count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO count
  FROM products
  WHERE category_id = p_category_id AND is_active = true;
  
  RETURN count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CLEAR USER CART FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION clear_user_cart(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM cart_items WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CREATE ORDER FROM CART FUNCTION
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
  
  -- Create order items from cart
  INSERT INTO order_items (order_id, product_id, product_name, product_image, quantity, price)
  SELECT 
    v_order_id,
    ci.product_id,
    p.name,
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

-- =====================================================
-- CHECK IF CATEGORY CAN BE DELETED
-- =====================================================
CREATE OR REPLACE FUNCTION can_delete_category(p_category_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  product_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO product_count
  FROM products
  WHERE category_id = p_category_id;
  
  RETURN product_count = 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ENABLE REALTIME FOR TABLES
-- =====================================================
-- Enable realtime for orders (merchant dashboard)
ALTER PUBLICATION supabase_realtime ADD TABLE orders;

-- Enable realtime for cart_items
ALTER PUBLICATION supabase_realtime ADD TABLE cart_items;

-- Enable realtime for products (stock updates)
ALTER PUBLICATION supabase_realtime ADD TABLE products;
