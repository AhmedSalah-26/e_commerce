-- =============================================
-- Remove unused single 'name' and 'description' columns
-- Keep only name_ar, name_en, description_ar, description_en
-- =============================================

-- First, copy data from 'name' to 'name_ar' if name_ar is empty
UPDATE products 
SET name_ar = name 
WHERE name_ar IS NULL OR name_ar = '';

UPDATE categories 
SET name_ar = name 
WHERE name_ar IS NULL OR name_ar = '';

-- Copy description to description_ar if empty
UPDATE products 
SET description_ar = description 
WHERE description_ar IS NULL OR description_ar = '';

-- Now remove the single 'name' column from products
ALTER TABLE products DROP COLUMN IF EXISTS name;

-- Remove the single 'description' column from products
ALTER TABLE products DROP COLUMN IF EXISTS description;

-- Remove the single 'name' column from categories
ALTER TABLE categories DROP COLUMN IF EXISTS name;

-- =============================================
-- Verify the changes
-- =============================================
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'products';

-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'categories';
