-- Function to validate that merchant supports shipping to the selected governorate
-- This trigger runs BEFORE INSERT on orders table
-- It checks if the merchant has an active shipping price for the selected governorate
CREATE OR REPLACE FUNCTION validate_order_shipping()
RETURNS TRIGGER AS $$
DECLARE
    v_merchant_id UUID;
    v_governorate_id UUID;
    v_shipping_exists BOOLEAN;
    v_merchant_name TEXT;
    v_governorate_name_ar TEXT;
    v_governorate_name_en TEXT;
BEGIN
    -- Get merchant_id from the order
    v_merchant_id := NEW.merchant_id;
    v_governorate_id := NEW.governorate_id;
    
    -- If no governorate specified, allow (for backward compatibility)
    IF v_governorate_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- If no merchant specified, allow
    IF v_merchant_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check if merchant has shipping price for this governorate
    SELECT EXISTS(
        SELECT 1 
        FROM merchant_shipping_prices 
        WHERE merchant_id = v_merchant_id 
        AND governorate_id = v_governorate_id 
        AND is_active = true
    ) INTO v_shipping_exists;
    
    -- If shipping not supported, reject the order
    IF NOT v_shipping_exists THEN
        -- Get merchant name for error message
        SELECT COALESCE(store_name, 'Unknown') INTO v_merchant_name
        FROM users 
        WHERE id = v_merchant_id;
        
        -- Get governorate names
        SELECT name_ar, name_en INTO v_governorate_name_ar, v_governorate_name_en
        FROM governorates 
        WHERE id = v_governorate_id;
        
        -- Raise exception with detailed message
        -- Format: SHIPPING_NOT_SUPPORTED|merchant_name|governorate_ar|governorate_en
        RAISE EXCEPTION 'SHIPPING_NOT_SUPPORTED|%|%|%', 
            v_merchant_name, 
            COALESCE(v_governorate_name_ar, ''), 
            COALESCE(v_governorate_name_en, '');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on orders table
DROP TRIGGER IF EXISTS validate_order_shipping_trigger ON orders;

CREATE TRIGGER validate_order_shipping_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION validate_order_shipping();

COMMENT ON FUNCTION validate_order_shipping() IS 'Validates that merchant supports shipping to the selected governorate before creating an order';
