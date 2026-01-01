-- Create function to handle Paymob webhook directly
-- This function will be called via Supabase REST API

CREATE OR REPLACE FUNCTION handle_paymob_payment(payload JSONB)
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
BEGIN
  -- Extract data from Paymob payload
  v_order_id := payload->'obj'->'order'->>'merchant_order_id';
  v_success := (payload->'obj'->>'success')::BOOLEAN;
  v_transaction_id := payload->'obj'->>'id';
  v_amount_cents := (payload->'obj'->>'amount_cents')::INTEGER;
  
  -- Determine payment status
  IF v_success THEN
    v_payment_status := 'paid';
  ELSE
    v_payment_status := 'failed';
  END IF;
  
  -- Log the webhook (optional - for debugging)
  RAISE NOTICE 'Paymob webhook: order_id=%, success=%, transaction_id=%', 
    v_order_id, v_success, v_transaction_id;
  
  -- Update order if order_id exists
  IF v_order_id IS NOT NULL THEN
    -- Update orders table
    UPDATE orders
    SET 
      payment_status = v_payment_status,
      payment_transaction_id = v_transaction_id,
      payment_amount = v_amount_cents / 100.0,
      updated_at = NOW()
    WHERE id = v_order_id::UUID;
    
    -- Update parent_orders table (if exists)
    UPDATE parent_orders
    SET 
      payment_status = v_payment_status,
      payment_transaction_id = v_transaction_id,
      payment_amount = v_amount_cents / 100.0,
      updated_at = NOW()
    WHERE id = v_order_id::UUID;
  END IF;
  
  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'payment_status', v_payment_status
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$;

-- Grant execute permission to anon and authenticated users
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO anon;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION handle_paymob_payment(JSONB) TO service_role;

-- Add comment
COMMENT ON FUNCTION handle_paymob_payment IS 'Handles Paymob payment webhook callbacks';
