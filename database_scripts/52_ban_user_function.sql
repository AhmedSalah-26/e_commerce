-- =====================================================
-- Ban User Function (Supabase Auth)
-- This function bans/unbans users from Supabase Auth
-- Only admins can execute this function
-- =====================================================

-- Create the ban_user function
CREATE OR REPLACE FUNCTION ban_user(
  target_user_id UUID,
  ban_duration TEXT DEFAULT 'none' -- 'none' to unban, '24h', '7d', '30d', 'forever'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSON;
  ban_until TIMESTAMPTZ;
BEGIN
  -- Check if caller is admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Only admins can ban users';
  END IF;

  -- Calculate ban_until based on duration
  IF ban_duration = 'none' THEN
    ban_until := NULL; -- Unban
  ELSIF ban_duration = '24h' THEN
    ban_until := NOW() + INTERVAL '24 hours';
  ELSIF ban_duration = '7d' THEN
    ban_until := NOW() + INTERVAL '7 days';
  ELSIF ban_duration = '30d' THEN
    ban_until := NOW() + INTERVAL '30 days';
  ELSIF ban_duration = 'forever' THEN
    ban_until := NOW() + INTERVAL '100 years';
  ELSE
    RAISE EXCEPTION 'Invalid ban duration. Use: none, 24h, 7d, 30d, forever';
  END IF;

  -- Update auth.users table (requires service_role)
  UPDATE auth.users
  SET 
    banned_until = ban_until,
    updated_at = NOW()
  WHERE id = target_user_id;

  -- Also update profiles table for UI consistency
  UPDATE profiles
  SET 
    is_active = (ban_duration = 'none'),
    banned_until = ban_until,
    updated_at = NOW()
  WHERE id = target_user_id;

  -- Return result
  SELECT json_build_object(
    'success', true,
    'user_id', target_user_id,
    'banned', ban_duration != 'none',
    'banned_until', ban_until
  ) INTO result;

  RETURN result;
END;
$$;

-- Grant execute to authenticated users (function checks admin internally)
GRANT EXECUTE ON FUNCTION ban_user(UUID, TEXT) TO authenticated;

-- =====================================================
-- Add banned_until column to profiles if not exists
-- =====================================================
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS banned_until TIMESTAMPTZ;

-- =====================================================
-- Helper function to check if user is banned
-- =====================================================
CREATE OR REPLACE FUNCTION is_user_banned(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  ban_time TIMESTAMPTZ;
BEGIN
  SELECT banned_until INTO ban_time
  FROM auth.users
  WHERE id = user_id;

  IF ban_time IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN ban_time > NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION is_user_banned(UUID) TO authenticated;

-- =====================================================
-- Comments
-- =====================================================
COMMENT ON FUNCTION ban_user IS 'Admin function to ban/unban users from Supabase Auth';
COMMENT ON FUNCTION is_user_banned IS 'Check if a user is currently banned';
COMMENT ON COLUMN profiles.banned_until IS 'When the user ban expires (NULL = not banned)';
