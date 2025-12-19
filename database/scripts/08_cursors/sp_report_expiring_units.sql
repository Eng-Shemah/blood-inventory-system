-- CURSOR EXAMPLE 1: Process Expiring Units (with FETCH)
-- Purpose: List units expiring in next 7 days
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_report_expiring_units (
    p_days_threshold IN NUMBER DEFAULT 7
) AS
    CURSOR c_expiring_units IS
        SELECT unit_id, blood_type, donor_id, expiry_date,
               TRUNC(expiry_date - SYSDATE) AS days_remaining
        FROM blood_units
        WHERE status = 'AVAILABLE'
        AND expiry_date BETWEEN SYSDATE AND SYSDATE + p_days_threshold
        ORDER BY expiry_date;
    
    v_unit c_expiring_units%ROWTYPE;
    v_total_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Units Expiring in Next ' || p_days_threshold || ' Days ===');
    DBMS_OUTPUT.PUT_LINE('Unit ID | Blood Type | Days Remaining | Expiry Date');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
    
    OPEN c_expiring_units;
    LOOP
        FETCH c_expiring_units INTO v_unit;
        EXIT WHEN c_expiring_units%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_unit.unit_id, 8) || ' | ' ||
            RPAD(v_unit.blood_type, 11) || ' | ' ||
            RPAD(v_unit.days_remaining, 15) || ' | ' ||
            TO_CHAR(v_unit.expiry_date, 'YYYY-MM-DD')
        );
        
        v_total_count := v_total_count + 1;
    END LOOP;
    CLOSE c_expiring_units;
    
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total units expiring: ' || v_total_count);
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_expiring_units%ISOPEN THEN
            CLOSE c_expiring_units;
        END IF;
        RAISE_APPLICATION_ERROR(-20999, 'Error in expiring units report: ' || SQLERRM);
END sp_report_expiring_units;
/