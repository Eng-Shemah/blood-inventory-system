-- PROCEDURE 3: Update Blood Unit Status
-- Purpose: Change status of blood unit (AVAILABLE, IN_USE, EXPIRED, DISCARDED)
-- Parameters: Unit ID, new status, optional test results
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_update_blood_status (
    p_unit_id IN blood_units.unit_id%TYPE,
    p_new_status IN blood_units.status%TYPE,
    p_test_results IN blood_units.test_results%TYPE DEFAULT NULL
) AS
    v_current_status blood_units.status%TYPE;
    v_unit_exists NUMBER;
    e_unit_not_found EXCEPTION;
    e_invalid_status EXCEPTION;
    e_invalid_transition EXCEPTION;
BEGIN
    -- Check if unit exists
    SELECT COUNT(*) INTO v_unit_exists
    FROM blood_units
    WHERE unit_id = p_unit_id;
    
    IF v_unit_exists = 0 THEN
        RAISE e_unit_not_found;
    END IF;
    
    -- Validate status
    IF p_new_status NOT IN ('AVAILABLE', 'IN_USE', 'EXPIRED', 'DISCARDED') THEN
        RAISE e_invalid_status;
    END IF;
    
    -- Get current status
    SELECT status INTO v_current_status
    FROM blood_units
    WHERE unit_id = p_unit_id;
    
    -- Validate status transition (cannot change EXPIRED or DISCARDED to AVAILABLE)
    IF v_current_status IN ('EXPIRED', 'DISCARDED') AND p_new_status = 'AVAILABLE' THEN
        RAISE e_invalid_transition;
    END IF;
    
    -- Update blood unit
    UPDATE blood_units
    SET status = p_new_status,
        test_results = NVL(p_test_results, test_results)
    WHERE unit_id = p_unit_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Blood unit ' || p_unit_id || ' status updated to ' || p_new_status);
    
EXCEPTION
    WHEN e_unit_not_found THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Blood unit ID not found.');
    WHEN e_invalid_status THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Invalid status. Must be AVAILABLE, IN_USE, EXPIRED, or DISCARDED.');
    WHEN e_invalid_transition THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Cannot change EXPIRED or DISCARDED units back to AVAILABLE.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error updating blood status: ' || SQLERRM);
END sp_update_blood_status;
/