-- Enable pg_cron extension (run once by Supabase admin)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Function to expire pending card payments after 30 minutes
CREATE OR REPLACE FUNCTION expire_pending_card_payments()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  -- Update orders where:
  -- 1. payment_method = 'card'
  -- 2. payment_status = 'pending'
  -- 3. created_at is older than 30 minutes
  UPDATE orders
  SET 
    payment_status = 'failed',
    status = 'payment_failed',
    updated_at = NOW()
  WHERE payment_method = 'card'
    AND payment_status = 'pending'
    AND created_at < NOW() - INTERVAL '30 minutes';
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  -- Also update parent_orders
  UPDATE parent_orders
  SET 
    payment_status = 'failed',
    updated_at = NOW()
  WHERE payment_method = 'card'
    AND payment_status = 'pending'
    AND created_at < NOW() - INTERVAL '30 minutes';
  
  RETURN expired_count;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION expire_pending_card_payments TO service_role;

-- Schedule the job to run every 5 minutes
-- Note: pg_cron must be enabled in Supabase Dashboard > Database > Extensions
SELECT cron.schedule(
  'expire-pending-payments',  -- job name
  '*/5 * * * *',              -- every 5 minutes
  'SELECT expire_pending_card_payments()'
);

-- To check scheduled jobs:
-- SELECT * FROM cron.job;

-- To remove the job:
-- SELECT cron.unschedule('expire-pending-payments');
