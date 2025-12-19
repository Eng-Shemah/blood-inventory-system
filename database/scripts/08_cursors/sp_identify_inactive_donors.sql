-- CURSOR EXAMPLE 2: Bulk Collection with BULK COLLECT
-- Purpose: Get all donors who haven't donated in 6+ months
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_identify_inactive_donors AS
    CURSOR c_inactive_donors IS
        SELECT d.donor_id, d.first_name, d.last_name, d.email,
               MAX(bu.collection_date) AS last_donation_date,
               TRUNC(SYSDATE - MAX(bu.collection_date)) AS days_since_donation
        FROM donors d
        LEFT JOIN blood_units bu ON d.donor_id = bu.donor_id
        GROUP BY d.donor_id, d.first_name, d.last_name, d.email
        HAVING MAX(bu.collection_date) < SYSDATE - 180
        OR MAX(bu.collection_date) IS NULL
        ORDER BY last_donation_date NULLS FIRST;
    
    TYPE t_inactive_donors IS TABLE OF c_inactive_donors%ROWTYPE;
    v_inactive_donors t_inactive_donors;
BEGIN
    OPEN c_inactive_donors;
    FETCH c_inactive_donors BULK COLLECT INTO v_inactive_donors;
    CLOSE c_inactive_donors;
    
    DBMS_OUTPUT.PUT_LINE('=== Inactive Donors (6+ months) ===');
    DBMS_OUTPUT.PUT_LINE('Total found: ' || v_inactive_donors.COUNT);
    DBMS_OUTPUT.PUT_LINE('Donor ID | Name | Last Donation | Days Inactive');
    
    FOR i IN 1..v_inactive_donors.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_inactive_donors(i).donor_id, 9) || ' | ' ||
            RPAD(v_inactive_donors(i).first_name || ' ' || v_inactive_donors(i).last_name, 25) || ' | ' ||
            RPAD(NVL(TO_CHAR(v_inactive_donors(i).last_donation_date, 'YYYY-MM-DD'), 'NEVER'), 14) || ' | ' ||
            NVL(TO_CHAR(v_inactive_donors(i).days_since_donation), 'N/A')
        );
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Error in inactive donors report: ' || SQLERRM);
END sp_identify_inactive_donors;
/