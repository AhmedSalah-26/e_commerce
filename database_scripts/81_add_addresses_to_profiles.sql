-- Add addresses column to profiles table
-- Addresses stored as JSONB array with format:
-- [{"id": "governorate_id:full_address", "title": "Home", "is_default": true}]

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS addresses JSONB DEFAULT '[]'::jsonb;

-- Add comment for documentation
COMMENT ON COLUMN profiles.addresses IS 'User saved addresses as JSON array. Each address has id (governorate_id:address), title, and is_default flag';
