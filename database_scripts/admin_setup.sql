-- =====================================================
-- Admin Dashboard Setup Script
-- Using role column: 'admin', 'merchant', 'customer'
-- =====================================================

-- Step 1: Update role column to allow 'admin' value
ALTER TABLE profiles 
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE profiles 
ADD CONSTRAINT profiles_role_check 
CHECK (role IN ('admin', 'merchant', 'customer'));

-- Step 2: Remove is_admin column if exists (we use role instead)
ALTER TABLE profiles DROP COLUMN IF EXISTS is_admin;

-- Step 3: Add is_active column if not exists (for user management)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Step 4: View all users to find your admin user
SELECT id, email, name, role, created_at 
FROM profiles 
ORDER BY created_at DESC;

-- Step 5: Set admin user (CHOOSE ONE METHOD)

-- Method A: By Email (Recommended - replace with your email)
UPDATE profiles 
SET role = 'admin' 
WHERE email = 'admin@example.com';

-- Method B: By User ID (replace with actual UUID from Step 3)
-- UPDATE profiles 
-- SET role = 'admin' 
-- WHERE id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';

-- Step 6: Verify admin was set correctly
SELECT id, email, name, role 
FROM profiles 
WHERE role = 'admin';

-- =====================================================
-- NOTE: RLS Policies for Admin
-- =====================================================
-- Admin policies are NOT added here to avoid infinite recursion.
-- The admin check is done in the application code instead.
-- If you need admin RLS policies, use a separate admin_users table
-- or use auth.jwt() claims instead of querying profiles table.
