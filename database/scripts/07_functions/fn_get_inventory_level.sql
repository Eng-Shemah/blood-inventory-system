-- FUNCTION 1: Calculate Blood Inventory Level
-- Purpose: Get current count of available units for a blood type
-- Returns: Number of available units
-- =====================================================
CREATE OR REPLACE FUNCTION fn_get_inventory_level (
    p_blood_type IN VARCHAR2
) RETURN NUMBER
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM blood_units
    WHERE blood_type = p_blood_type
    AND status = 'AVAILABLE'
    AND expiry_date > SYSDATE;
    
    RETURN v_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Error indicator
END fn_get_inventory_level;
/