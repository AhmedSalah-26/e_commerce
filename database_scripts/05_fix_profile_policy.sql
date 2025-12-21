-- =====================================================
-- FIX PROFILE CREATION ISSUE
-- Run this script in Supabase SQL Editor
-- =====================================================

-- Step 1: Drop all existing policies on profiles
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Merchants can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Service role can insert profiles" ON profiles;

-- Step 2: Create a trigger function that runs with SECURITY DEFINER
-- This bypasses RLS and creates the profile automatically
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, name, phone)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer'),
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'phone'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = COALESCE(EXCLUDED.role, profiles.role),
    name = COALESCE(EXCLUDED.name, profiles.name),
    phone = COALESCE(EXCLUDED.phone, profiles.phone);
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail the signup
    RAISE WARNING 'Error creating profile: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Drop existing trigger if exists and create new one
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Step 4: Recreate RLS policies (simpler version)
-- Allow users to read their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Allow authenticated users to insert their own profile (backup for trigger)
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Step 5: Verify RLS is enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- OPTIONAL: If you want merchants to see all profiles
-- =====================================================
-- CREATE OR REPLACE FUNCTION is_merchant()
-- RETURNS BOOLEAN AS $$
-- BEGIN
--   RETURN EXISTS (
--     SELECT 1 FROM profiles 
--     WHERE id = auth.uid() AND role = 'merchant'
--   );
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- CREATE POLICY "Merchants can view all profiles"
--   ON profiles FOR SELECT
--   USING (is_merchant());

-- =====================================================
-- VERIFY: Test the setup
-- =====================================================
-- Check policies:
-- SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- Check trigger:
-- SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- Check function:
-- SELECT proname, prosrc FROM pg_proc WHERE proname = 'handle_new_user';
