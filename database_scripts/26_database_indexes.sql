-- =====================================================
-- Database Indexes for Performance Optimization
-- =====================================================

-- =====================================================
-- PRODUCTS TABLE INDEXES
-- =====================================================

-- Index for active products (most common filter)
CREATE INDEX IF NOT EXISTS idx_products_is_active 
ON products(is_active) WHERE is_active = true;

-- Index for category filtering
CREATE INDEX IF NOT EXISTS idx_products_category_id 
ON products(category_id);

-- Index for merchant products
CREATE INDEX IF NOT EXISTS idx_products_merchant_id 
ON products(merchant_id);

-- Index for discounted products queries
CREATE INDEX IF NOT EXISTS idx_products_discount_price 
ON products(discount_price) WHERE discount_price IS NOT NULL;

-- Composite index for discounted products sorting
CREATE INDEX IF NOT EXISTS idx_products_discounted_active 
ON products(is_active, discount_price, price) 
WHERE is_active = true AND discount_price IS NOT NULL;

-- Index for newest products (created_at sorting)
CREATE INDEX IF NOT EXISTS idx_products_created_at 
ON products(created_at DESC);

-- Index for featured products
CREATE INDEX IF NOT EXISTS idx_products_is_featured 
ON products(is_featured) WHERE is_featured = true;

-- Composite index for active products by category
CREATE INDEX IF NOT EXISTS idx_products_category_active 
ON products(category_id, is_active, created_at DESC) 
WHERE is_active = true;

-- =====================================================
-- CATEGORIES TABLE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_categories_is_active 
ON categories(is_active) WHERE is_active = true;

-- =====================================================
-- PARENT ORDERS TABLE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_parent_orders_user_id 
ON parent_orders(user_id);

CREATE INDEX IF NOT EXISTS idx_parent_orders_created_at 
ON parent_orders(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_parent_orders_user_created 
ON parent_orders(user_id, created_at DESC);

-- =====================================================
-- FAVORITES TABLE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_favorites_user_id 
ON favorites(user_id);

CREATE INDEX IF NOT EXISTS idx_favorites_product_id 
ON favorites(product_id);

-- =====================================================
-- CART ITEMS TABLE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_cart_items_user_id 
ON cart_items(user_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_product_id 
ON cart_items(product_id);

-- =====================================================
-- ANALYZE TABLES (Update Statistics)
-- =====================================================

ANALYZE products;
ANALYZE categories;
ANALYZE parent_orders;
ANALYZE favorites;
ANALYZE cart_items;
