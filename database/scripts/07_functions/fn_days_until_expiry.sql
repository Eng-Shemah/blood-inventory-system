-- FUNCTION 3: Calculate Days Until Expiry
-- Purpose: Get remaining days for a blood unit
-- Returns: Number of days (negative if expired)
-- =====================================================
CREATE OR REPLACE FUNCTION fn_days_until_expiry (
    p_unit_id IN NUMBER
) RETURN NUMBER
AS
    v_expiry_date DATE;
    v_days_remaining NUMBER;
BEGIN
    SELECT expiry_date
    INTO v_expiry_date
    FROM blood_units
    WHERE unit_id = p_unit_id;
    
    v_days_remaining := TRUNC(v_expiry_date - SYSDATE);
    
    RETURN v_days_remaining;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END fn_days_until_expiry;
/