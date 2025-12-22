-- =====================================================
-- Flash Sale Auto-Cleanup with pg_cron
-- =====================================================
-- This script sets up automatic cleanup of expired flash sales
-- Run this in Supabase SQL Editor after enabling pg_cron extension

-- Step 1: Enable pg_cron extension (if not already enabled)
-- Note: You may need to enable this from Supabase Dashboard > Database > Extensions first
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Step 2: Grant usage to postgres user
GRANT USAGE ON SCHEMA cron TO postgres;

-- Step 3: Remove existing job if exists (to avoid duplicates)
SELECT cron.unschedule('cleanup-expired-flash-sales') 
WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'cleanup-expired-flash-sales');

-- Step 4: Schedule cleanup job to run every 1 minute
SELECT cron.schedule(
  'cleanup-expired-flash-sales',
  '* * * * *',  -- Every minute
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

-- Step 5: Verify the job was created
SELECT * FROM cron.job WHERE jobname = 'cleanup-expired-flash-sales';

-- =====================================================
-- Useful Commands
-- =====================================================

-- View all scheduled jobs:
-- SELECT * FROM cron.job;

-- View job run history:
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Unschedule the job:
-- SELECT cron.unschedule('cleanup-expired-flash-sales');

-- Run cleanup manually:
-- UPDATE products
-- SET is_flash_sale = FALSE, flash_sale_start = NULL, flash_sale_end = NULL, discount_price = NULL
-- WHERE is_flash_sale = TRUE AND flash_sale_end IS NOT NULL AND flash_sale_end < NOW();
