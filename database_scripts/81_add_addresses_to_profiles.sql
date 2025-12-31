-- Add addresses column to profiles table and remove governorate_id
-- Addresses stored as JSONB array with format:
-- [{"id": "governorate_id:full_address", "title": "Home", "is_default": true}]

-- Add addresses column
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS addresses JSONB DEFAULT '[]'::jsonb;

-- Remove governorate_id column (no longer needed)
ALTER TABLE profiles 
DROP COLUMN IF EXISTS governorate_id;

-- Add comment for documentation
COMMENT ON COLUMN profiles.addresses IS 'User saved addresses as JSON array. Each address has id (governorate_id:address), title, and is_default flag';
