-- ============================================================
-- E-COMMERCE COMPLETE DATABASE SCHEMA
-- Version: Final (December 2024)
-- 
-- This is a unified script containing all database tables,
-- functions, triggers, RLS policies, and storage buckets.
-- 
-- Run this script in Supabase SQL Editor for a fresh setup.
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron"; -- Optional: for scheduled tasks

-- ============================================================
-- PART 1: CORE TABLES
-- ============================================================

-- 1.1 PROFILES TABLE (extends Supabase Auth)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('merchant', 'customer')),
  avatar_url TEXT,
  governorate_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- 1.2 CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ar TEXT,
  name_en TEXT,
  image_url TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);

-- 1.3 PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  discount_price DECIMAL(10,2) CHECK (discount_price >= 0),
  images TEXT[] DEFAULT '{}',
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  merchant_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  stock INTEGER DEFAULT 0 CHECK (stock >= 0),
  rating DECIMAL(3,2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  rating_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  -- Flash Sale fields
  is_flash_sale BOOLEAN DEFAULT FALSE,
  flash_sale_start TIMESTAMPTZ,
  flash_sale_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_merchant ON products(merchant_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_stock ON products(stock);
CREATE INDEX IF NOT EXISTS idx_products_flash_sale ON products(is_flash_sale, flash_sale_end) WHERE is_flash_sale = TRUE;
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_products_discount ON products(discount_price) WHERE discount_price IS NOT NULL;

-- 1.4 STORES TABLE (Merchant Store Info)
CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  phone TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(merchant_id)
);

CREATE INDEX IF NOT EXISTS idx_stores_merchant_id ON stores(merchant_id);

-- 1.5 GOVERNORATES TABLE (Egyptian Governorates)
CREATE TABLE IF NOT EXISTS governorates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_governorates_active ON governorates(is_active);
CREATE INDEX IF NOT EXISTS idx_governorates_sort ON governorates(sort_order);

-- Add foreign key to profiles
ALTER TABLE profiles 
ADD CONSTRAINT fk_profiles_governorate 
FOREIGN KEY (governorate_id) REFERENCES governorates(id);

-- 1.6 MERCHANT SHIPPING PRICES TABLE
CREATE TABLE IF NOT EXISTS merchant_shipping_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  governorate_id UUID REFERENCES governorates(id) ON DELETE CASCADE NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(merchant_id, governorate_id)
);

CREATE INDEX IF NOT EXISTS idx_shipping_merchant ON merchant_shipping_prices(merchant_id);
CREATE INDEX IF NOT EXISTS idx_shipping_governorate ON merchant_shipping_prices(governorate_id);


-- 1.7 CART ITEMS TABLE
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_user ON cart_items(user_id);

-- 1.8 FAVORITES TABLE
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product ON favorites(product_id);

-- 1.9 REVIEWS TABLE
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at DESC);

-- 1.10 PARENT ORDERS TABLE (Groups orders from same checkout)
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
  -- Coupon fields
  coupon_id UUID,
  coupon_code VARCHAR(50),
  coupon_discount DECIMAL(10,2) DEFAULT 0,
  payment_method TEXT DEFAULT 'cash_on_delivery',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parent_orders_user_id ON parent_orders(user_id);

-- 1.11 ORDERS TABLE (Per-merchant orders)
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  merchant_id UUID REFERENCES profiles(id),
  parent_order_id UUID REFERENCES parent_orders(id),
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  discount DECIMAL(10,2) DEFAULT 0,
  shipping_cost DECIMAL(10,2) DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  delivery_address TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  notes TEXT,
  governorate_id UUID REFERENCES governorates(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_merchant ON orders(merchant_id);
CREATE INDEX IF NOT EXISTS idx_orders_parent_order_id ON orders(parent_order_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at DESC);

-- 1.12 ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  product_name_ar TEXT,
  product_name_en TEXT,
  product_image TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- ============================================================
-- PART 2: COUPONS SYSTEM
-- ============================================================

-- 2.1 COUPONS TABLE
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name_ar VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  description_ar TEXT,
  description_en TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
  max_discount_amount DECIMAL(10, 2),
  min_order_amount DECIMAL(10, 2) DEFAULT 0,
  usage_limit INTEGER,
  usage_count INTEGER DEFAULT 0,
  usage_limit_per_user INTEGER DEFAULT 1,
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  scope VARCHAR(20) DEFAULT 'all' CHECK (scope IN ('all', 'categories', 'products', 'merchants')),
  is_active BOOLEAN DEFAULT true,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_store ON coupons(store_id);
CREATE INDEX IF NOT EXISTS idx_coupons_active ON coupons(is_active, start_date, end_date);

-- Add foreign key to parent_orders
ALTER TABLE parent_orders 
ADD CONSTRAINT fk_parent_orders_coupon 
FOREIGN KEY (coupon_id) REFERENCES coupons(id);

-- 2.2 COUPON CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS coupon_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(coupon_id, category_id)
);

-- 2.3 COUPON PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS coupon_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(coupon_id, product_id)
);

-- 2.4 COUPON USAGES TABLE
CREATE TABLE IF NOT EXISTS coupon_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id UUID REFERENCES parent_orders(id) ON DELETE SET NULL,
  discount_amount DECIMAL(10, 2) NOT NULL,
  used_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coupon_usages_user ON coupon_usages(user_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon ON coupon_usages(coupon_id);


-- ============================================================
-- PART 3: HELPER FUNCTIONS
-- ============================================================

-- 3.1 Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables with updated_at
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY['profiles', 'categories', 'products', 'stores', 'merchant_shipping_prices', 'cart_items', 'reviews', 'parent_orders', 'orders', 'coupons'])
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS update_%s_updated_at ON %s', t, t);
    EXECUTE format('CREATE TRIGGER update_%s_updated_at BEFORE UPDATE ON %s FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', t, t);
  END LOOP;
END;
$$;

-- 3.2 Check if user is merchant
CREATE OR REPLACE FUNCTION is_merchant()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND role = 'merchant'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3.3 Auto-create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, name, phone)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer'),
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'phone'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 3.4 Decrease stock on order item creation
CREATE OR REPLACE FUNCTION decrease_product_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET stock = GREATEST(stock - NEW.quantity, 0)
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_order_item_created ON order_items;
CREATE TRIGGER on_order_item_created
  AFTER INSERT ON order_items
  FOR EACH ROW EXECUTE FUNCTION decrease_product_stock();

-- 3.5 Restore stock on order cancellation
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

DROP TRIGGER IF EXISTS on_order_cancelled ON orders;
CREATE TRIGGER on_order_cancelled
  AFTER UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION restore_stock_on_cancel();

-- 3.6 Update product rating on review changes
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
  avg_rating DECIMAL(3,2);
  review_count INTEGER;
  target_product_id UUID;
BEGIN
  target_product_id := COALESCE(NEW.product_id, OLD.product_id);
  
  SELECT COALESCE(AVG(rating), 0), COUNT(*) 
  INTO avg_rating, review_count
  FROM reviews
  WHERE product_id = target_product_id;
  
  UPDATE products 
  SET rating = avg_rating, rating_count = review_count 
  WHERE id = target_product_id;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_product_rating ON reviews;
CREATE TRIGGER trigger_update_product_rating
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- 3.7 Flash sale cleanup trigger
CREATE OR REPLACE FUNCTION trigger_cleanup_flash_sales()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_flash_sale = TRUE AND NEW.flash_sale_end IS NOT NULL AND NEW.flash_sale_end < NOW() THEN
    NEW.is_flash_sale := FALSE;
    NEW.flash_sale_start := NULL;
    NEW.flash_sale_end := NULL;
    NEW.discount_price := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cleanup_flash_sale_on_update ON products;
CREATE TRIGGER cleanup_flash_sale_on_update
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION trigger_cleanup_flash_sales();

-- 3.8 Cleanup expired flash sales function
CREATE OR REPLACE FUNCTION cleanup_expired_flash_sales()
RETURNS void AS $$
BEGIN
  UPDATE products
  SET 
    is_flash_sale = FALSE,
    flash_sale_start = NULL,
    flash_sale_end = NULL,
    discount_price = NULL
  WHERE 
    is_flash_sale = TRUE 
    AND flash_sale_end IS NOT NULL 
    AND flash_sale_end < NOW();
END;
$$ LANGUAGE plpgsql;

-- 3.9 Get shipping price function
CREATE OR REPLACE FUNCTION get_shipping_price(
  p_merchant_id UUID,
  p_governorate_id UUID
)
RETURNS DECIMAL AS $$
DECLARE
  v_price DECIMAL;
BEGIN
  SELECT price INTO v_price
  FROM merchant_shipping_prices
  WHERE merchant_id = p_merchant_id
    AND governorate_id = p_governorate_id
    AND is_active = true;
  
  RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql;

-- 3.10 Get cart total function
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

-- 3.11 Clear user cart function
CREATE OR REPLACE FUNCTION clear_user_cart(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM cart_items WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- PART 4: ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE governorates ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_shipping_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_usages ENABLE ROW LEVEL SECURITY;

-- 4.1 PROFILES POLICIES
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
CREATE POLICY "Enable insert for authenticated users only" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Merchants can view all profiles" ON profiles;
CREATE POLICY "Merchants can view all profiles" ON profiles FOR SELECT USING (is_merchant());

-- 4.2 CATEGORIES POLICIES
DROP POLICY IF EXISTS "Anyone can view active categories" ON categories;
CREATE POLICY "Anyone can view active categories" ON categories FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Merchants can view all categories" ON categories;
CREATE POLICY "Merchants can view all categories" ON categories FOR SELECT USING (is_merchant());

DROP POLICY IF EXISTS "Merchants can insert categories" ON categories;
CREATE POLICY "Merchants can insert categories" ON categories FOR INSERT WITH CHECK (is_merchant());

DROP POLICY IF EXISTS "Merchants can update categories" ON categories;
CREATE POLICY "Merchants can update categories" ON categories FOR UPDATE USING (is_merchant());

DROP POLICY IF EXISTS "Merchants can delete categories" ON categories;
CREATE POLICY "Merchants can delete categories" ON categories FOR DELETE USING (is_merchant());

-- 4.3 PRODUCTS POLICIES
DROP POLICY IF EXISTS "Anyone can view active products" ON products;
CREATE POLICY "Anyone can view active products" ON products FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Merchants can view all products" ON products;
CREATE POLICY "Merchants can view all products" ON products FOR SELECT USING (is_merchant());

DROP POLICY IF EXISTS "Merchants can insert products" ON products;
CREATE POLICY "Merchants can insert products" ON products FOR INSERT WITH CHECK (is_merchant());

DROP POLICY IF EXISTS "Merchants can update products" ON products;
CREATE POLICY "Merchants can update products" ON products FOR UPDATE USING (is_merchant());

DROP POLICY IF EXISTS "Merchants can delete products" ON products;
CREATE POLICY "Merchants can delete products" ON products FOR DELETE USING (is_merchant());

-- 4.4 STORES POLICIES
DROP POLICY IF EXISTS "Anyone can view stores" ON stores;
CREATE POLICY "Anyone can view stores" ON stores FOR SELECT USING (true);

DROP POLICY IF EXISTS "Merchants can manage own store" ON stores;
CREATE POLICY "Merchants can manage own store" ON stores FOR ALL USING (merchant_id = auth.uid());

-- 4.5 GOVERNORATES POLICIES
DROP POLICY IF EXISTS "Anyone can view active governorates" ON governorates;
CREATE POLICY "Anyone can view active governorates" ON governorates FOR SELECT USING (is_active = true);

-- 4.6 MERCHANT SHIPPING PRICES POLICIES
DROP POLICY IF EXISTS "Anyone can view shipping prices" ON merchant_shipping_prices;
CREATE POLICY "Anyone can view shipping prices" ON merchant_shipping_prices FOR SELECT USING (true);

DROP POLICY IF EXISTS "Merchants can manage own shipping prices" ON merchant_shipping_prices;
CREATE POLICY "Merchants can manage own shipping prices" ON merchant_shipping_prices FOR ALL USING (merchant_id = auth.uid());

-- 4.7 CART ITEMS POLICIES
DROP POLICY IF EXISTS "Users can view own cart items" ON cart_items;
CREATE POLICY "Users can view own cart items" ON cart_items FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own cart items" ON cart_items;
CREATE POLICY "Users can insert own cart items" ON cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own cart items" ON cart_items;
CREATE POLICY "Users can update own cart items" ON cart_items FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own cart items" ON cart_items;
CREATE POLICY "Users can delete own cart items" ON cart_items FOR DELETE USING (auth.uid() = user_id);

-- 4.8 FAVORITES POLICIES
DROP POLICY IF EXISTS "Users can view own favorites" ON favorites;
CREATE POLICY "Users can view own favorites" ON favorites FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own favorites" ON favorites;
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

-- 4.9 REVIEWS POLICIES
DROP POLICY IF EXISTS "Anyone can view reviews" ON reviews;
CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create reviews" ON reviews;
CREATE POLICY "Users can create reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own reviews" ON reviews;
CREATE POLICY "Users can update own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own reviews" ON reviews;
CREATE POLICY "Users can delete own reviews" ON reviews FOR DELETE USING (auth.uid() = user_id);

-- 4.10 PARENT ORDERS POLICIES
DROP POLICY IF EXISTS "Users can view own parent orders" ON parent_orders;
CREATE POLICY "Users can view own parent orders" ON parent_orders FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own parent orders" ON parent_orders;
CREATE POLICY "Users can create own parent orders" ON parent_orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4.11 ORDERS POLICIES
DROP POLICY IF EXISTS "Customers can view own orders" ON orders;
CREATE POLICY "Customers can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Merchants can view their orders" ON orders;
CREATE POLICY "Merchants can view their orders" ON orders FOR SELECT USING (merchant_id = auth.uid());

DROP POLICY IF EXISTS "Customers can create own orders" ON orders;
CREATE POLICY "Customers can create own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Merchants can update their orders" ON orders;
CREATE POLICY "Merchants can update their orders" ON orders FOR UPDATE USING (merchant_id = auth.uid());

DROP POLICY IF EXISTS "Customers can update own pending orders" ON orders;
CREATE POLICY "Customers can update own pending orders" ON orders FOR UPDATE USING (auth.uid() = user_id AND status = 'pending');

-- 4.12 ORDER ITEMS POLICIES
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;
CREATE POLICY "Users can view own order items" ON order_items FOR SELECT
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));

DROP POLICY IF EXISTS "Merchants can view their order items" ON order_items;
CREATE POLICY "Merchants can view their order items" ON order_items FOR SELECT
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.merchant_id = auth.uid()));

DROP POLICY IF EXISTS "Users can insert own order items" ON order_items;
CREATE POLICY "Users can insert own order items" ON order_items FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));

-- 4.13 COUPONS POLICIES
DROP POLICY IF EXISTS "Anyone can view active coupons" ON coupons;
CREATE POLICY "Anyone can view active coupons" ON coupons FOR SELECT
  USING (is_active = true AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()));

DROP POLICY IF EXISTS "Merchants can manage their coupons" ON coupons;
CREATE POLICY "Merchants can manage their coupons" ON coupons FOR ALL
  USING (store_id IN (SELECT id FROM stores WHERE merchant_id = auth.uid()));

-- 4.14 COUPON CATEGORIES POLICIES
DROP POLICY IF EXISTS "Anyone can view coupon categories" ON coupon_categories;
CREATE POLICY "Anyone can view coupon categories" ON coupon_categories FOR SELECT USING (true);

-- 4.15 COUPON PRODUCTS POLICIES
DROP POLICY IF EXISTS "Anyone can view coupon products" ON coupon_products;
CREATE POLICY "Anyone can view coupon products" ON coupon_products FOR SELECT USING (true);

-- 4.16 COUPON USAGES POLICIES
DROP POLICY IF EXISTS "Users can view their coupon usages" ON coupon_usages;
CREATE POLICY "Users can view their coupon usages" ON coupon_usages FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert coupon usages" ON coupon_usages;
CREATE POLICY "Users can insert coupon usages" ON coupon_usages FOR INSERT WITH CHECK (user_id = auth.uid());


-- ============================================================
-- PART 5: MULTI-VENDOR ORDER FUNCTION
-- ============================================================

DROP FUNCTION IF EXISTS create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, UUID, UUID, VARCHAR, DECIMAL, TEXT);

CREATE OR REPLACE FUNCTION create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost DECIMAL DEFAULT 0,
  p_governorate_id UUID DEFAULT NULL,
  p_coupon_id UUID DEFAULT NULL,
  p_coupon_code VARCHAR DEFAULT NULL,
  p_coupon_discount DECIMAL DEFAULT 0,
  p_payment_method TEXT DEFAULT 'cash_on_delivery'
)
RETURNS UUID AS $$
DECLARE
  v_parent_order_id UUID;
  v_order_id UUID;
  v_merchant_subtotal DECIMAL;
  v_total_subtotal DECIMAL := 0;
  v_merchant_count INT := 0;
  v_total_shipping DECIMAL;
  merchant_rec RECORD;
BEGIN
  -- Check if cart is empty
  IF NOT EXISTS (SELECT 1 FROM cart_items WHERE user_id = p_user_id) THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Count unique merchants in cart
  SELECT COUNT(DISTINCT p.merchant_id) INTO v_merchant_count
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Each merchant gets full shipping cost
  v_total_shipping := COALESCE(p_shipping_cost, 0) * GREATEST(v_merchant_count, 1);
  
  -- Calculate total subtotal
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_total_subtotal
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Create parent order
  INSERT INTO parent_orders (
    user_id, total, subtotal, shipping_cost, delivery_address,
    customer_name, customer_phone, notes, governorate_id,
    coupon_id, coupon_code, coupon_discount, payment_method
  )
  VALUES (
    p_user_id,
    v_total_subtotal + v_total_shipping - COALESCE(p_coupon_discount, 0),
    v_total_subtotal,
    v_total_shipping,
    p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id,
    p_coupon_id, p_coupon_code, COALESCE(p_coupon_discount, 0), p_payment_method
  )
  RETURNING id INTO v_parent_order_id;

  -- Loop through each merchant and create separate order
  FOR merchant_rec IN 
    SELECT DISTINCT p.merchant_id
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id IS NOT NULL
  LOOP
    -- Calculate subtotal for this merchant
    SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_merchant_subtotal
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id = merchant_rec.merchant_id;
    
    -- Create order for this merchant with FULL shipping cost
    INSERT INTO orders (
      user_id, merchant_id, parent_order_id, total, subtotal, shipping_cost,
      delivery_address, customer_name, customer_phone, notes, governorate_id, status
    )
    VALUES (
      p_user_id, merchant_rec.merchant_id, v_parent_order_id,
      v_merchant_subtotal + COALESCE(p_shipping_cost, 0),
      v_merchant_subtotal, COALESCE(p_shipping_cost, 0),
      p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id, 'pending'
    )
    RETURNING id INTO v_order_id;
    
    -- Create order items for this merchant
    INSERT INTO order_items (order_id, product_id, product_name, product_name_ar, product_name_en, product_image, quantity, price)
    SELECT v_order_id, ci.product_id, COALESCE(p.name_ar, p.name_en, 'منتج'),
           p.name_ar, p.name_en, p.images[1], ci.quantity, COALESCE(p.discount_price, p.price)
    FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id = merchant_rec.merchant_id;
  END LOOP;
  
  -- Handle products without merchant (if any)
  IF EXISTS (
    SELECT 1 FROM cart_items ci
    JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id IS NULL
  ) THEN
    SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_merchant_subtotal
    FROM cart_items ci JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id IS NULL;
    
    INSERT INTO orders (user_id, merchant_id, parent_order_id, total, subtotal, shipping_cost,
      delivery_address, customer_name, customer_phone, notes, governorate_id, status)
    VALUES (p_user_id, NULL, v_parent_order_id, v_merchant_subtotal + COALESCE(p_shipping_cost, 0),
      v_merchant_subtotal, COALESCE(p_shipping_cost, 0), p_delivery_address, p_customer_name,
      p_customer_phone, p_notes, p_governorate_id, 'pending')
    RETURNING id INTO v_order_id;
    
    INSERT INTO order_items (order_id, product_id, product_name, product_name_ar, product_name_en, product_image, quantity, price)
    SELECT v_order_id, ci.product_id, COALESCE(p.name_ar, p.name_en, 'منتج'),
           p.name_ar, p.name_en, p.images[1], ci.quantity, COALESCE(p.discount_price, p.price)
    FROM cart_items ci JOIN products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id AND p.merchant_id IS NULL;
  END IF;

  -- Apply coupon if provided
  IF p_coupon_id IS NOT NULL THEN
    PERFORM apply_coupon_to_order(p_coupon_id, p_user_id, v_parent_order_id, COALESCE(p_coupon_discount, 0));
  END IF;
  
  -- Clear cart
  DELETE FROM cart_items WHERE user_id = p_user_id;
  
  RETURN v_parent_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- PART 6: COUPON VALIDATION FUNCTIONS
-- ============================================================

-- 6.1 Validate Coupon Function
CREATE OR REPLACE FUNCTION validate_coupon(
    p_coupon_code VARCHAR,
    p_user_id UUID,
    p_order_amount DECIMAL,
    p_product_ids UUID[] DEFAULT NULL,
    p_store_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_coupon RECORD;
    v_user_usage_count INTEGER;
    v_discount_amount DECIMAL;
    v_applicable_amount DECIMAL;
BEGIN
    -- Find coupon
    SELECT * INTO v_coupon FROM coupons WHERE code = UPPER(p_coupon_code) AND is_active = true;
    
    IF v_coupon IS NULL THEN
        RETURN json_build_object('valid', false, 'error_code', 'INVALID_CODE',
            'error_ar', 'كود الخصم غير صحيح', 'error_en', 'Invalid coupon code');
    END IF;
    
    IF v_coupon.start_date > NOW() THEN
        RETURN json_build_object('valid', false, 'error_code', 'NOT_STARTED',
            'error_ar', 'كود الخصم لم يبدأ بعد', 'error_en', 'Coupon has not started yet');
    END IF;
    
    IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
        RETURN json_build_object('valid', false, 'error_code', 'EXPIRED',
            'error_ar', 'كود الخصم منتهي الصلاحية', 'error_en', 'Coupon has expired');
    END IF;
    
    IF v_coupon.usage_limit IS NOT NULL AND v_coupon.usage_count >= v_coupon.usage_limit THEN
        RETURN json_build_object('valid', false, 'error_code', 'USAGE_LIMIT_REACHED',
            'error_ar', 'تم استنفاد عدد مرات استخدام الكوبون', 'error_en', 'Coupon usage limit reached');
    END IF;
    
    SELECT COUNT(*) INTO v_user_usage_count FROM coupon_usages WHERE coupon_id = v_coupon.id AND user_id = p_user_id;
    
    IF v_user_usage_count >= v_coupon.usage_limit_per_user THEN
        RETURN json_build_object('valid', false, 'error_code', 'USER_LIMIT_REACHED',
            'error_ar', 'لقد استخدمت هذا الكوبون من قبل', 'error_en', 'You have already used this coupon');
    END IF;
    
    IF p_order_amount < v_coupon.min_order_amount THEN
        RETURN json_build_object('valid', false, 'error_code', 'MIN_ORDER_NOT_MET',
            'error_ar', 'الحد الأدنى للطلب ' || v_coupon.min_order_amount || ' ج.م',
            'error_en', 'Minimum order amount is ' || v_coupon.min_order_amount || ' EGP');
    END IF;

    IF v_coupon.store_id IS NOT NULL AND v_coupon.store_id != p_store_id THEN
        RETURN json_build_object('valid', false, 'error_code', 'MERCHANT_MISMATCH',
            'error_ar', 'هذا الكوبون خاص بمتجر آخر', 'error_en', 'This coupon is for another store');
    END IF;
    
    -- Calculate discount
    v_applicable_amount := p_order_amount;
    
    IF v_coupon.discount_type = 'percentage' THEN
        v_discount_amount := v_applicable_amount * (v_coupon.discount_value / 100);
        IF v_coupon.max_discount_amount IS NOT NULL AND v_discount_amount > v_coupon.max_discount_amount THEN
            v_discount_amount := v_coupon.max_discount_amount;
        END IF;
    ELSE
        v_discount_amount := LEAST(v_coupon.discount_value, v_applicable_amount);
    END IF;
    
    v_discount_amount := ROUND(v_discount_amount, 2);
    
    RETURN json_build_object(
        'valid', true, 'coupon_id', v_coupon.id, 'code', v_coupon.code,
        'name_ar', v_coupon.name_ar, 'name_en', v_coupon.name_en,
        'discount_type', v_coupon.discount_type, 'discount_value', v_coupon.discount_value,
        'discount_amount', v_discount_amount, 'final_amount', p_order_amount - v_discount_amount
    );
END;
$$;

-- 6.2 Apply Coupon to Order Function
CREATE OR REPLACE FUNCTION apply_coupon_to_order(
    p_coupon_id UUID,
    p_user_id UUID,
    p_order_id UUID,
    p_discount_amount DECIMAL
)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    INSERT INTO coupon_usages (coupon_id, user_id, order_id, discount_amount)
    VALUES (p_coupon_id, p_user_id, p_order_id, p_discount_amount);
    
    UPDATE coupons SET usage_count = usage_count + 1, updated_at = NOW() WHERE id = p_coupon_id;
    
    RETURN true;
EXCEPTION WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- 6.3 Get Available Coupons Function
CREATE OR REPLACE FUNCTION get_available_coupons(
    p_user_id UUID,
    p_order_amount DECIMAL DEFAULT 0,
    p_store_id UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID, code VARCHAR, name_ar VARCHAR, name_en VARCHAR,
    description_ar TEXT, description_en TEXT, discount_type VARCHAR,
    discount_value DECIMAL, max_discount_amount DECIMAL, min_order_amount DECIMAL,
    end_date TIMESTAMPTZ, is_applicable BOOLEAN, reason_ar TEXT, reason_en TEXT
)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id, c.code, c.name_ar, c.name_en, c.description_ar, c.description_en,
        c.discount_type, c.discount_value, c.max_discount_amount, c.min_order_amount, c.end_date,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN false
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN false
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN false
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN false
            ELSE true
        END AS is_applicable,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'الحد الأدنى للطلب ' || c.min_order_amount || ' ج.م'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'خاص بمتجر آخر'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'تم استنفاد الكوبون'
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'تم استخدامه مسبقاً'
            ELSE NULL
        END AS reason_ar,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'Minimum order ' || c.min_order_amount || ' EGP'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'For another store'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'Coupon exhausted'
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'Already used'
            ELSE NULL
        END AS reason_en
    FROM coupons c
    WHERE c.is_active = true AND c.start_date <= NOW() AND (c.end_date IS NULL OR c.end_date > NOW())
    AND (c.store_id IS NULL OR c.store_id = p_store_id)
    ORDER BY is_applicable DESC, c.discount_value DESC;
END;
$$;

-- 6.4 Get Parent Order Details Function
CREATE OR REPLACE FUNCTION get_parent_order_details(p_parent_order_id UUID)
RETURNS TABLE (
  parent_order_id UUID, parent_total DECIMAL, parent_subtotal DECIMAL, parent_shipping_cost DECIMAL,
  delivery_address TEXT, customer_name TEXT, customer_phone TEXT, notes TEXT, parent_created_at TIMESTAMPTZ,
  order_id UUID, merchant_id UUID, merchant_name TEXT, merchant_phone TEXT,
  order_total DECIMAL, order_subtotal DECIMAL, order_shipping_cost DECIMAL, order_status TEXT, order_created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    po.id, po.total, po.subtotal, po.shipping_cost, po.delivery_address, po.customer_name,
    po.customer_phone, po.notes, po.created_at,
    o.id, o.merchant_id, COALESCE(s.name, pr.name), COALESCE(s.phone, pr.phone),
    o.total, o.subtotal, o.shipping_cost, o.status, o.created_at
  FROM parent_orders po
  LEFT JOIN orders o ON o.parent_order_id = po.id
  LEFT JOIN stores s ON s.merchant_id = o.merchant_id
  LEFT JOIN profiles pr ON pr.id = o.merchant_id
  WHERE po.id = p_parent_order_id
  ORDER BY o.created_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- PART 7: STORAGE BUCKETS
-- ============================================================

-- Create products bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('products', 'products', true) ON CONFLICT (id) DO NOTHING;

-- Create categories bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('categories', 'categories', true) ON CONFLICT (id) DO NOTHING;

-- Create stores bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('stores', 'stores', true) ON CONFLICT (id) DO NOTHING;

-- Storage policies for products
DROP POLICY IF EXISTS "Public Access to Products Images" ON storage.objects;
CREATE POLICY "Public Access to Products Images" ON storage.objects FOR SELECT USING (bucket_id = 'products');

DROP POLICY IF EXISTS "Authenticated users can upload product images" ON storage.objects;
CREATE POLICY "Authenticated users can upload product images" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'products' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update product images" ON storage.objects;
CREATE POLICY "Users can update product images" ON storage.objects FOR UPDATE
  USING (bucket_id = 'products' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete product images" ON storage.objects;
CREATE POLICY "Users can delete product images" ON storage.objects FOR DELETE
  USING (bucket_id = 'products' AND auth.role() = 'authenticated');

-- Storage policies for categories
DROP POLICY IF EXISTS "Public Access to Categories Images" ON storage.objects;
CREATE POLICY "Public Access to Categories Images" ON storage.objects FOR SELECT USING (bucket_id = 'categories');

DROP POLICY IF EXISTS "Authenticated users can upload category images" ON storage.objects;
CREATE POLICY "Authenticated users can upload category images" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'categories' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update category images" ON storage.objects;
CREATE POLICY "Users can update category images" ON storage.objects FOR UPDATE
  USING (bucket_id = 'categories' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete category images" ON storage.objects;
CREATE POLICY "Users can delete category images" ON storage.objects FOR DELETE
  USING (bucket_id = 'categories' AND auth.role() = 'authenticated');

-- Storage policies for stores
DROP POLICY IF EXISTS "Public Access to Stores Images" ON storage.objects;
CREATE POLICY "Public Access to Stores Images" ON storage.objects FOR SELECT USING (bucket_id = 'stores');

DROP POLICY IF EXISTS "Authenticated users can upload store images" ON storage.objects;
CREATE POLICY "Authenticated users can upload store images" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'stores' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update store images" ON storage.objects;
CREATE POLICY "Users can update store images" ON storage.objects FOR UPDATE
  USING (bucket_id = 'stores' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete store images" ON storage.objects;
CREATE POLICY "Users can delete store images" ON storage.objects FOR DELETE
  USING (bucket_id = 'stores' AND auth.role() = 'authenticated');


-- ============================================================
-- PART 8: SEED DATA - Egyptian Governorates (27 محافظة)
-- ============================================================

INSERT INTO governorates (name_ar, name_en, sort_order) VALUES
  ('القاهرة', 'Cairo', 1),
  ('الجيزة', 'Giza', 2),
  ('الإسكندرية', 'Alexandria', 3),
  ('الدقهلية', 'Dakahlia', 4),
  ('البحر الأحمر', 'Red Sea', 5),
  ('البحيرة', 'Beheira', 6),
  ('الفيوم', 'Fayoum', 7),
  ('الغربية', 'Gharbia', 8),
  ('الإسماعيلية', 'Ismailia', 9),
  ('المنوفية', 'Menofia', 10),
  ('المنيا', 'Minya', 11),
  ('القليوبية', 'Qalyubia', 12),
  ('الوادي الجديد', 'New Valley', 13),
  ('السويس', 'Suez', 14),
  ('أسوان', 'Aswan', 15),
  ('أسيوط', 'Asyut', 16),
  ('بني سويف', 'Beni Suef', 17),
  ('بورسعيد', 'Port Said', 18),
  ('دمياط', 'Damietta', 19),
  ('الشرقية', 'Sharqia', 20),
  ('جنوب سيناء', 'South Sinai', 21),
  ('كفر الشيخ', 'Kafr El Sheikh', 22),
  ('مطروح', 'Matrouh', 23),
  ('الأقصر', 'Luxor', 24),
  ('قنا', 'Qena', 25),
  ('شمال سيناء', 'North Sinai', 26),
  ('سوهاج', 'Sohag', 27)
ON CONFLICT DO NOTHING;


-- ============================================================
-- PART 9: REALTIME SUBSCRIPTIONS
-- ============================================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE cart_items;
ALTER PUBLICATION supabase_realtime ADD TABLE products;


-- ============================================================
-- PART 10: GRANTS AND PERMISSIONS
-- ============================================================

-- Grant table permissions
GRANT SELECT ON profiles TO authenticated;
GRANT UPDATE ON profiles TO authenticated;
GRANT INSERT ON profiles TO authenticated;

GRANT SELECT ON categories TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON categories TO authenticated;

GRANT SELECT ON products TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON products TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON stores TO authenticated;

GRANT SELECT ON governorates TO authenticated, anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON merchant_shipping_prices TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;

GRANT SELECT, INSERT, DELETE ON favorites TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON reviews TO authenticated;

GRANT SELECT, INSERT ON parent_orders TO authenticated;

GRANT SELECT, INSERT, UPDATE ON orders TO authenticated;

GRANT SELECT, INSERT ON order_items TO authenticated;

GRANT SELECT ON coupons TO authenticated;
GRANT SELECT ON coupon_categories TO authenticated;
GRANT SELECT ON coupon_products TO authenticated;
GRANT SELECT, INSERT ON coupon_usages TO authenticated;

-- Grant function permissions
GRANT EXECUTE ON FUNCTION is_merchant TO authenticated;
GRANT EXECUTE ON FUNCTION get_shipping_price TO authenticated;
GRANT EXECUTE ON FUNCTION get_cart_total TO authenticated;
GRANT EXECUTE ON FUNCTION clear_user_cart TO authenticated;
GRANT EXECUTE ON FUNCTION create_multi_vendor_order TO authenticated;
GRANT EXECUTE ON FUNCTION get_parent_order_details TO authenticated;
GRANT EXECUTE ON FUNCTION validate_coupon TO authenticated;
GRANT EXECUTE ON FUNCTION apply_coupon_to_order TO authenticated;
GRANT EXECUTE ON FUNCTION get_available_coupons TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_expired_flash_sales TO authenticated;


-- ============================================================
-- END OF COMPLETE DATABASE SCHEMA
-- ============================================================
