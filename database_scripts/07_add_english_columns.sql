-- =====================================================
-- ADD ENGLISH NAME COLUMNS
-- Run this script in Supabase SQL Editor
-- =====================================================

-- Add name_en column to categories
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS name_en TEXT;

-- Update existing categories to have name_en from name
UPDATE categories SET name_en = name WHERE name_en IS NULL;

-- Add name_en and description_en columns to products
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS name_en TEXT;

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS description_en TEXT;

-- Update existing products to have name_en from name
UPDATE products SET name_en = name WHERE name_en IS NULL;
UPDATE products SET description_en = description WHERE description_en IS NULL;

-- =====================================================
-- UPDATE SEED DATA WITH BOTH LANGUAGES
-- =====================================================

-- Update Categories with both Arabic and English names
UPDATE categories SET 
  name_ar = 'إلكترونيات',
  name_en = 'Electronics'
WHERE id = '11111111-1111-1111-1111-111111111111';

UPDATE categories SET 
  name_ar = 'ملابس',
  name_en = 'Clothing'
WHERE id = '22222222-2222-2222-2222-222222222222';

UPDATE categories SET 
  name_ar = 'المنزل والحديقة',
  name_en = 'Home & Garden'
WHERE id = '33333333-3333-3333-3333-333333333333';

UPDATE categories SET 
  name_ar = 'رياضة',
  name_en = 'Sports'
WHERE id = '44444444-4444-4444-4444-444444444444';

UPDATE categories SET 
  name_ar = 'كتب',
  name_en = 'Books'
WHERE id = '55555555-5555-5555-5555-555555555555';

UPDATE categories SET 
  name_ar = 'جمال',
  name_en = 'Beauty'
WHERE id = '66666666-6666-6666-6666-666666666666';

-- Update Products with both Arabic and English
UPDATE products SET 
  name_ar = 'آيفون 15 برو',
  name_en = 'iPhone 15 Pro',
  description_ar = 'أحدث هاتف ذكي من أبل مع شريحة A17 Pro',
  description_en = 'Latest Apple smartphone with A17 Pro chip'
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'سامسونج جالاكسي S24',
  name_en = 'Samsung Galaxy S24',
  description_ar = 'هاتف أندرويد متميز',
  description_en = 'Premium Android smartphone'
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

UPDATE products SET 
  name_ar = 'ماك بوك برو 14 بوصة',
  name_en = 'MacBook Pro 14"',
  description_ar = 'لابتوب قوي للمحترفين',
  description_en = 'Powerful laptop for professionals'
WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';

UPDATE products SET 
  name_ar = 'إيربودز برو 2',
  name_en = 'AirPods Pro 2',
  description_ar = 'سماعات لاسلكية مع إلغاء الضوضاء',
  description_en = 'Wireless earbuds with noise cancellation'
WHERE id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

UPDATE products SET 
  name_ar = 'سوني WH-1000XM5',
  name_en = 'Sony WH-1000XM5',
  description_ar = 'سماعات رأس متميزة مع إلغاء الضوضاء',
  description_en = 'Premium noise-canceling headphones'
WHERE id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

UPDATE products SET 
  name_ar = 'جاكيت جينز كلاسيكي',
  name_en = 'Classic Denim Jacket',
  description_ar = 'جاكيت جينز خالد لجميع الفصول',
  description_en = 'Timeless denim jacket for all seasons'
WHERE id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

UPDATE products SET 
  name_ar = 'مجموعة تيشيرتات قطن',
  name_en = 'Cotton T-Shirt Pack',
  description_ar = 'مجموعة من 3 تيشيرتات قطن فاخرة',
  description_en = 'Pack of 3 premium cotton t-shirts'
WHERE id = '11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'حذاء رياضي للجري',
  name_en = 'Running Sneakers',
  description_ar = 'حذاء جري مريح',
  description_en = 'Comfortable running shoes'
WHERE id = '22222222-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'مصباح LED ذكي',
  name_en = 'Smart LED Lamp',
  description_ar = 'مصباح ذكي متصل بالواي فاي مع خيارات ألوان',
  description_en = 'WiFi-enabled smart lamp with color options'
WHERE id = '33333333-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'مجموعة نباتات داخلية',
  name_en = 'Indoor Plant Set',
  description_ar = 'مجموعة من 3 نباتات داخلية سهلة العناية',
  description_en = 'Set of 3 easy-care indoor plants'
WHERE id = '44444444-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'سجادة يوغا فاخرة',
  name_en = 'Yoga Mat Premium',
  description_ar = 'سجادة يوغا فاخرة مانعة للانزلاق',
  description_en = 'Non-slip premium yoga mat'
WHERE id = '55555555-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'مجموعة دمبل 20 كجم',
  name_en = 'Dumbbell Set 20kg',
  description_ar = 'مجموعة دمبل قابلة للتعديل للجيم المنزلي',
  description_en = 'Adjustable dumbbell set for home gym'
WHERE id = '66666666-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'دليل تطوير فلاتر',
  name_en = 'Flutter Development Guide',
  description_ar = 'دليل شامل لتطوير تطبيقات فلاتر',
  description_en = 'Complete guide to Flutter app development'
WHERE id = '77777777-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'كتاب استراتيجية الأعمال',
  name_en = 'Business Strategy Book',
  description_ar = 'تعلم استراتيجيات الأعمال من الخبراء',
  description_en = 'Learn business strategies from experts'
WHERE id = '88888888-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'مجموعة العناية بالبشرة',
  name_en = 'Skincare Set',
  description_ar = 'مجموعة كاملة للعناية بالبشرة',
  description_en = 'Complete skincare routine set'
WHERE id = '99999999-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

UPDATE products SET 
  name_ar = 'مجموعة عطور',
  name_en = 'Perfume Collection',
  description_ar = 'مجموعة عطور فاخرة للهدايا',
  description_en = 'Luxury perfume gift set'
WHERE id = 'aaaaaaaa-1111-1111-1111-111111111111';
