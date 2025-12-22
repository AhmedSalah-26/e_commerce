-- =====================================================
-- Complete Flash Sale Setup - All in One Script
-- =====================================================
-- This script sets up everything needed for flash sales:
-- 1. Database columns
-- 2. Functions
-- 3. Triggers
-- 4. RLS Policies
-- 5. pg_cron automatic cleanup
-- =====================================================

-- =====================================================
-- STEP 1: Add Flash Sale Columns
-- =====================================================
ALTER TABLE products
ADD COLUMN IF NOT EXISTS is_flash_sale BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS flash_sale_start TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS flash_sale_end TIMESTAMPTZ;

-- Create index for flash sale queries
CREATE INDEX IF NOT EXISTS idx_products_flash_sale 
ON products (is_flash_sale, flash_sale_end) 
WHERE is_flash_sale = TRUE;

-- =====================================================
-- STEP 2: Create Helper Functions
-- =====================================================

-- Function to check if flash sale is active
CREATE OR REPLACE FUNCTION is_flash_sale_active(
  p_is_flash_sale BOOLEAN,
  p_flash_sale_start TIMESTAMPTZ,
  p_flash_sale_end TIMESTAMPTZ
) RETURNS BOOLEAN AS $$
BEGIN
  IF p_is_flash_sale IS NOT TRUE THEN
    RETURN FALSE;
  END IF;
  
  IF p_flash_sale_start IS NULL OR p_flash_sale_end IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN NOW() >= p_flash_sale_start AND NOW() <= p_flash_sale_end;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired flash sales
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STEP 3: Create Trigger for Auto-Cleanup on Update
-- =====================================================

-- Trigger function to auto-cleanup on product update
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

-- Create trigger
DROP TRIGGER IF EXISTS cleanup_flash_sale_on_update ON products;
CREATE TRIGGER cleanup_flash_sale_on_update
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION trigger_cleanup_flash_sales();

-- =====================================================
-- STEP 4: RLS Policy for Flash Sale Cleanup
-- =====================================================

-- Allow anyone to update flash sale fields (for cleanup)
DROP POLICY IF EXISTS "Allow flash sale cleanup" ON products;
CREATE POLICY "Allow flash sale cleanup" ON products
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- STEP 5: Enable pg_cron Extension
-- =====================================================
-- NOTE: You MUST enable pg_cron from Supabase Dashboard first!
-- Go to: Database > Extensions > Search "pg_cron" > Enable

-- Try to create extension (will fail if not enabled in dashboard)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant usage
GRANT USAGE ON SCHEMA cron TO postgres;

-- =====================================================
-- STEP 6: Schedule Automatic Cleanup Job
-- =====================================================

-- Remove existing job if exists
DO $$
BEGIN
  PERFORM cron.unschedule('cleanup-expired-flash-sales');
EXCEPTION WHEN OTHERS THEN
  -- Job doesn't exist, ignore
END;
$$;

-- Schedule cleanup every minute
SELECT cron.schedule(
  'cleanup-expired-flash-sales',
  '* * * * *',
  $$
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
  $$
);

-- =====================================================
-- STEP 7: Add Comments for Documentation
-- =====================================================
COMMENT ON COLUMN products.is_flash_sale IS 'Whether this product has a flash sale';
COMMENT ON COLUMN products.flash_sale_start IS 'Flash sale start date/time';
COMMENT ON COLUMN products.flash_sale_end IS 'Flash sale end date/time';
COMMENT ON FUNCTION cleanup_expired_flash_sales() IS 'Removes discount from products when flash sale expires';

-- =====================================================
-- VERIFICATION: Check everything is set up
-- =====================================================

-- Check columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name IN ('is_flash_sale', 'flash_sale_start', 'flash_sale_end');

-- Check cron job exists
SELECT * FROM cron.job WHERE jobname = 'cleanup-expired-flash-sales';

-- =====================================================
-- MANUAL COMMANDS (if needed)
-- =====================================================

-- Run cleanup manually:
-- SELECT cleanup_expired_flash_sales();

-- Or direct update:
-- UPDATE products
-- SET is_flash_sale = FALSE, flash_sale_start = NULL, flash_sale_end = NULL, discount_price = NULL
-- WHERE is_flash_sale = TRUE AND flash_sale_end IS NOT NULL AND flash_sale_end < NOW();

-- View cron job history:
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Unschedule job:
-- SELECT cron.unschedule('cleanup-expired-flash-sales');
