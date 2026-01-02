-- Drop old function if exists
DROP FUNCTION IF EXISTS handle_paymob_payment(JSONB);
DROP FUNCTION IF EXISTS handle_paymob_payment();

-- Create function to handle Paymob webhook
-- Paymob sends the payload directly as the request body
CREATE OR REPLACE FUNCTION handle_paymob_payment(obj JSONB DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id TEXT;
  v_success BOOLEAN;
  v_transaction_id TEXT;
  v_amount_cents INTEGER;
  v_payment_status TEXT;
  v_payload JSONB;
BEGIN
  -- Get payload from parameter or current_setting
  v_payload := COALESCE(obj, '{}'::JSONB);
  
  -- Extract data from Paymob payload
  -- Paymob sends: { "obj": { "order": { "merchant_order_id": "..." }, "success": true, ... } }
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
  
  -- Determine payment status
  IF v_success THEN
    v_payment_status := 'paid';
  ELSE
    v_payment_status := 'failed';
  END IF;
  
  -- Update order if order_id exists
  IF v_order_id IS NOT NULL AND v_order_id != '' THEN
    -- Update orders table
    UPDATE orders
    SET 
      payment_status = v_payment_status,
      payment_transaction_id = v_transaction_id,
      payment_amount = v_amount_cents / 100.0,
      updated_at = NOW()
    WHERE id = v_order_id::UUID;
    
    -- Update parent_orders table
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
      'payment_status', v_payment_status
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'error', 'No order_id found',
      'payload_received', v_payload
    );
  END IF;
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO anon;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO service_role;
