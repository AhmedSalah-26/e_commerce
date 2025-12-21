-- =====================================================
-- SEED DATA FOR TESTING
-- Run this script in Supabase SQL Editor AFTER creating tables
-- =====================================================

-- =====================================================
-- CATEGORIES (التصنيفات)
-- =====================================================
INSERT INTO categories (id, name, name_ar, image_url, description, is_active, sort_order) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Electronics', 'إلكترونيات', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', 'Electronic devices and gadgets', true, 1),
  ('22222222-2222-2222-2222-222222222222', 'Clothing', 'ملابس', 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400', 'Fashion and apparel', true, 2),
  ('33333333-3333-3333-3333-333333333333', 'Home & Garden', 'المنزل والحديقة', 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=400', 'Home decor and garden supplies', true, 3),
  ('44444444-4444-4444-4444-444444444444', 'Sports', 'رياضة', 'https://images.unsplash.com/photo-1461896836934- voices-of-the-world?w=400', 'Sports equipment and accessories', true, 4),
  ('55555555-5555-5555-5555-555555555555', 'Books', 'كتب', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400', 'Books and educational materials', true, 5),
  ('66666666-6666-6666-6666-666666666666', 'Beauty', 'جمال', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400', 'Beauty and personal care', true, 6)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_ar = EXCLUDED.name_ar,
  image_url = EXCLUDED.image_url;

-- =====================================================
-- PRODUCTS (المنتجات)
-- =====================================================
INSERT INTO products (id, name, name_ar, description, description_ar, price, discount_price, images, category_id, stock, rating, rating_count, is_active, is_featured) VALUES
  -- Electronics
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'iPhone 15 Pro', 'آيفون 15 برو', 'Latest Apple smartphone with A17 Pro chip', 'أحدث هاتف ذكي من أبل مع شريحة A17 Pro', 1199.99, 1099.99, ARRAY['https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400'], '11111111-1111-1111-1111-111111111111', 50, 4.8, 245, true, true),
  
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Samsung Galaxy S24', 'سامسونج جالاكسي S24', 'Premium Android smartphone', 'هاتف أندرويد متميز', 999.99, NULL, ARRAY['https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400'], '11111111-1111-1111-1111-111111111111', 75, 4.6, 189, true, true),
  
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'MacBook Pro 14"', 'ماك بوك برو 14 بوصة', 'Powerful laptop for professionals', 'لابتوب قوي للمحترفين', 1999.99, 1899.99, ARRAY['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'], '11111111-1111-1111-1111-111111111111', 30, 4.9, 156, true, true),
  
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'AirPods Pro 2', 'إيربودز برو 2', 'Wireless earbuds with noise cancellation', 'سماعات لاسلكية مع إلغاء الضوضاء', 249.99, 229.99, ARRAY['https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400'], '11111111-1111-1111-1111-111111111111', 100, 4.7, 312, true, false),
  
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Sony WH-1000XM5', 'سوني WH-1000XM5', 'Premium noise-canceling headphones', 'سماعات رأس متميزة مع إلغاء الضوضاء', 399.99, 349.99, ARRAY['https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400'], '11111111-1111-1111-1111-111111111111', 45, 4.8, 278, true, false),

  -- Clothing
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Classic Denim Jacket', 'جاكيت جينز كلاسيكي', 'Timeless denim jacket for all seasons', 'جاكيت جينز خالد لجميع الفصول', 89.99, 69.99, ARRAY['https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400'], '22222222-2222-2222-2222-222222222222', 120, 4.5, 89, true, true),
  
  ('11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Cotton T-Shirt Pack', 'مجموعة تيشيرتات قطن', 'Pack of 3 premium cotton t-shirts', 'مجموعة من 3 تيشيرتات قطن فاخرة', 49.99, NULL, ARRAY['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'], '22222222-2222-2222-2222-222222222222', 200, 4.4, 156, true, false),
  
  ('22222222-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Running Sneakers', 'حذاء رياضي للجري', 'Comfortable running shoes', 'حذاء جري مريح', 129.99, 99.99, ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'], '22222222-2222-2222-2222-222222222222', 80, 4.6, 234, true, true),

  -- Home & Garden
  ('33333333-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Smart LED Lamp', 'مصباح LED ذكي', 'WiFi-enabled smart lamp with color options', 'مصباح ذكي متصل بالواي فاي مع خيارات ألوان', 59.99, 49.99, ARRAY['https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400'], '33333333-3333-3333-3333-333333333333', 150, 4.3, 67, true, false),
  
  ('44444444-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Indoor Plant Set', 'مجموعة نباتات داخلية', 'Set of 3 easy-care indoor plants', 'مجموعة من 3 نباتات داخلية سهلة العناية', 79.99, NULL, ARRAY['https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400'], '33333333-3333-3333-3333-333333333333', 40, 4.7, 45, true, true),

  -- Sports
  ('55555555-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Yoga Mat Premium', 'سجادة يوغا فاخرة', 'Non-slip premium yoga mat', 'سجادة يوغا فاخرة مانعة للانزلاق', 39.99, 29.99, ARRAY['https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400'], '44444444-4444-4444-4444-444444444444', 90, 4.5, 123, true, false),
  
  ('66666666-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dumbbell Set 20kg', 'مجموعة دمبل 20 كجم', 'Adjustable dumbbell set for home gym', 'مجموعة دمبل قابلة للتعديل للجيم المنزلي', 149.99, 129.99, ARRAY['https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400'], '44444444-4444-4444-4444-444444444444', 35, 4.8, 89, true, true),

  -- Books
  ('77777777-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Flutter Development Guide', 'دليل تطوير فلاتر', 'Complete guide to Flutter app development', 'دليل شامل لتطوير تطبيقات فلاتر', 49.99, 39.99, ARRAY['https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'], '55555555-5555-5555-5555-555555555555', 100, 4.9, 67, true, true),
  
  ('88888888-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Business Strategy Book', 'كتاب استراتيجية الأعمال', 'Learn business strategies from experts', 'تعلم استراتيجيات الأعمال من الخبراء', 29.99, NULL, ARRAY['https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400'], '55555555-5555-5555-5555-555555555555', 75, 4.4, 45, true, false),

  -- Beauty
  ('99999999-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Skincare Set', 'مجموعة العناية بالبشرة', 'Complete skincare routine set', 'مجموعة كاملة للعناية بالبشرة', 89.99, 74.99, ARRAY['https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400'], '66666666-6666-6666-6666-666666666666', 60, 4.6, 134, true, true),
  
  ('aaaaaaaa-1111-1111-1111-111111111111', 'Perfume Collection', 'مجموعة عطور', 'Luxury perfume gift set', 'مجموعة عطور فاخرة للهدايا', 199.99, 169.99, ARRAY['https://images.unsplash.com/photo-1541643600914-78b084683601?w=400'], '66666666-6666-6666-6666-666666666666', 25, 4.7, 78, true, false)

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_ar = EXCLUDED.name_ar,
  price = EXCLUDED.price,
  discount_price = EXCLUDED.discount_price,
  stock = EXCLUDED.stock;

-- =====================================================
-- VERIFY DATA
-- =====================================================
-- Run these queries to verify the data was inserted:
-- SELECT COUNT(*) FROM categories;  -- Should return 6
-- SELECT COUNT(*) FROM products;    -- Should return 16
-- SELECT * FROM categories ORDER BY sort_order;
-- SELECT * FROM products WHERE is_featured = true;
