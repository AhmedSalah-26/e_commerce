-- =====================================================
-- Sync Payment Status with Order Status
-- This ensures order status reflects payment status changes
-- =====================================================

-- 1. Update the webhook function to also update order status
DROP FUNCTION IF EXISTS handle_paymob_payment(JSONB);

CREATE OR REPLACE FUNCTION handle_paymob_payment(obj JSONB DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order_id TEXT;
  v_success BOOLEAN;
  v_transaction_id TEXT;
  v_amount_cents INTEGER;
  v_payment_status TEXT;
  v_order_status TEXT;
  v_payload JSONB;
BEGIN
  -- Get payload from parameter or current_setting
  v_payload := COALESCE(obj, '{}'::JSONB);
  
  -- Extract data from Paymob payload
  v_order_id := v_payload->'obj'->'order'->>'merchant_order_id';
  v_success := COALESCE((v_payload->'obj'->>'success')::BOOLEAN, false);
  v_transaction_id := v_payload->'obj'->>'id';
  v_amount_cents := COALESCE((v_payload->'obj'->>'amount_cents')::INTEGER, 0);
  
  -- If obj is passed directly (not nested)
  IF v_order_id IS NULL THEN
    v_order_id := v_payload->'order'->>'merchant_order_id';
    v_success := COALESCE((v_payload->>'success')::BOOLEAN, false);
    v_transaction_id := v_payload->>'id';
    v_amount_cents := COALESCE((v_payload->>'amount_cents')::INTEGER, 0);
  END IF;
  
  -- Determine payment status AND order status
  IF v_success THEN
    v_payment_status := 'paid';
    v_order_status := 'pending';
  ELSE
    v_payment_status := 'failed';
    v_order_status := 'payment_failed';
  END IF;
  
  -- Update order if order_id exists
  IF v_order_id IS NOT NULL AND v_order_id != '' THEN
    -- Update sub-orders
    UPDATE orders
    SET 
      payment_status = v_payment_status,
      status = v_order_status,
      payment_transaction_id = v_transaction_id,
      payment_amount = v_amount_cents / 100.0,
      updated_at = NOW()
    WHERE parent_order_id = v_order_id::UUID;
    
    -- Update parent_orders
    UPDATE parent_orders
    SET 
      payment_status = v_payment_status,
      payment_transaction_id = v_transaction_id,
      payment_amount = v_amount_cents / 100.0,
      updated_at = NOW()
    WHERE id = v_order_id::UUID;
    
    RETURN jsonb_build_object(
      'success', true,
      'order_id', v_order_id,
      'payment_status', v_payment_status,
      'order_status', v_order_status
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'error', 'No order_id found'
    );
  END IF;
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO anon;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO service_role;

-- 2. Trigger to sync payment_status to order status
CREATE OR REPLACE FUNCTION sync_payment_to_order_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.payment_status IS DISTINCT FROM NEW.payment_status THEN
    IF NEW.payment_status = 'failed' AND NEW.status = 'pending' THEN
      NEW.status := 'payment_failed';
    END IF;
    IF NEW.payment_status = 'paid' AND NEW.status = 'payment_failed' THEN
      NEW.status := 'pending';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_sync_payment_order_status ON orders;
CREATE TRIGGER trigger_sync_payment_order_status
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION sync_payment_to_order_status();

-- 3. Fix existing orders
UPDATE orders SET status = 'payment_failed', updated_at = NOW()
WHERE payment_status = 'failed' AND status = 'pending';

-- 4. Expire function for card and wallet
CREATE OR REPLACE FUNCTION expire_pending_card_payments()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  UPDATE orders
  SET payment_status = 'failed', status = 'payment_failed', updated_at = NOW()
  WHERE payment_method IN ('card', 'wallet')
    AND payment_status = 'pending'
    AND created_at < NOW() - INTERVAL '30 minutes';
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  UPDATE parent_orders
  SET payment_status = 'failed', updated_at = NOW()
  WHERE payment_method IN ('card', 'wallet')
    AND payment_status = 'pending'
    AND created_at < NOW() - INTERVAL '30 minutes';
  
  RETURN expired_count;
END;
$$;

GRANT EXECUTE ON FUNCTION expire_pending_card_payments TO service_role;
