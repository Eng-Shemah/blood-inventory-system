-- PROCEDURE 2: Record Blood Donation
-- Purpose: Create blood unit from donor donation
-- Parameters: Donor ID, collection date, expiry date (auto-calculated if null)
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_record_donation (
    p_donor_id IN blood_units.donor_id%TYPE,
    p_collection_date IN blood_units.collection_date%TYPE DEFAULT SYSDATE,
    p_unit_id OUT blood_units.unit_id%TYPE
) AS
    v_blood_type donors.blood_type%TYPE;
    v_expiry_date DATE;
    v_donor_exists NUMBER;
    e_donor_not_found EXCEPTION;
BEGIN
    -- Check if donor exists
    SELECT COUNT(*) INTO v_donor_exists
    FROM donors
    WHERE donor_id = p_donor_id;
    
    IF v_donor_exists = 0 THEN
        RAISE e_donor_not_found;
    END IF;
    
    -- Get donor's blood type
    SELECT blood_type INTO v_blood_type
    FROM donors
    WHERE donor_id = p_donor_id;
    
    -- Calculate expiry date (42 days from collection)
    v_expiry_date := p_collection_date + 42;
    
    -- Insert blood unit
    INSERT INTO blood_units (
        unit_id, donor_id, blood_type, collection_date, 
        expiry_date, status, test_results
    ) VALUES (
        seq_blood_units.NEXTVAL, p_donor_id, v_blood_type, 
        p_collection_date, v_expiry_date, 'AVAILABLE', 'PASSED'
    ) RETURNING unit_id INTO p_unit_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Blood unit recorded. Unit ID: ' || p_unit_id);
    
EXCEPTION
    WHEN e_donor_not_found THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Donor ID not found in system.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error recording donation: ' || SQLERRM);
END sp_record_donation;
/