-- PROCEDURE 5: Delete Expired Blood Units (Bulk Operation)
-- Purpose: Remove or mark expired blood units
-- Parameters: Cutoff date, action type (DELETE or MARK_EXPIRED)
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_cleanup_expired_units (
    p_cutoff_date IN DATE DEFAULT SYSDATE,
    p_action IN VARCHAR2 DEFAULT 'MARK_EXPIRED',
    p_units_affected OUT NUMBER
) AS
    e_invalid_action EXCEPTION;
BEGIN
    -- Validate action
    IF p_action NOT IN ('MARK_EXPIRED', 'DELETE') THEN
        RAISE e_invalid_action;
    END IF;
    
    IF p_action = 'MARK_EXPIRED' THEN
        -- Update expired units
        UPDATE blood_units
        SET status = 'EXPIRED'
        WHERE expiry_date < p_cutoff_date
        AND status = 'AVAILABLE';
        
        p_units_affected := SQL%ROWCOUNT;
        
    ELSIF p_action = 'DELETE' THEN
        -- Delete expired units (only if not referenced in transfusions)
        DELETE FROM blood_units
        WHERE expiry_date < p_cutoff_date - 90
        AND status = 'EXPIRED'
        AND unit_id NOT IN (SELECT unit_id FROM transfusions);
        
        p_units_affected := SQL%ROWCOUNT;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Cleanup complete. Units affected: ' || p_units_affected);
    
EXCEPTION
    WHEN e_invalid_action THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'Invalid action. Use MARK_EXPIRED or DELETE.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error in cleanup: ' || SQLERRM);
END sp_cleanup_expired_units;
/