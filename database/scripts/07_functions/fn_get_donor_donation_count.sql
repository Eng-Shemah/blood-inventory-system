-- FUNCTION 4: Get Total Donations by Donor
-- Purpose: Count total donations made by a specific donor
-- Returns: Number of donations
-- =====================================================
CREATE OR REPLACE FUNCTION fn_get_donor_donation_count (
    p_donor_id IN NUMBER
) RETURN NUMBER
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM blood_units
    WHERE donor_id = p_donor_id;
    
    RETURN v_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_donor_donation_count;
/