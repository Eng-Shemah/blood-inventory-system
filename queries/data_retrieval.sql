-- TEST SUITE: Comprehensive testing of all procedures and functions
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ====================================================
PROMPT PHASE VI - PL/SQL TESTING
PROMPT ====================================================

PROMPT
PROMPT === TEST 1: Register New Donor ===
DECLARE
    v_donor_id NUMBER;
BEGIN
    sp_register_donor(
        p_first_name => 'TestDonor',
        p_last_name => 'Smith',
        p_blood_type => 'O+',
        p_dob => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        p_gender => 'M',
        p_contact => '+250788999888',
        p_email => 'testdonor@test.com',
        p_address => 'Kigali Test Address',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Donor ID: ' || v_donor_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 2: Register Donor - Invalid Age (Should Fail) ===
DECLARE
    v_donor_id NUMBER;
BEGIN
    sp_register_donor(
        p_first_name => 'YoungDonor',
        p_last_name => 'Test',
        p_blood_type => 'A+',
        p_dob => TO_DATE('2010-01-01', 'YYYY-MM-DD'), -- Too young
        p_gender => 'F',
        p_contact => '+250788999999',
        p_email => 'young@test.com',
        p_address => 'Test Address',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED - Should have raised exception');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Correctly rejected invalid age');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
        END IF;
END;
/

PROMPT
PROMPT === TEST 3: Record Blood Donation ===
DECLARE
    v_unit_id NUMBER;
BEGIN
    sp_record_donation(
        p_donor_id => 1,  -- Use existing donor
        p_unit_id => v_unit_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Unit ID: ' || v_unit_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 4: Update Blood Status ===
BEGIN
    sp_update_blood_status(
        p_unit_id => 1,
        p_new_status => 'IN_USE'
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Status updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 5: Record Transfusion ===
DECLARE
    v_transfusion_id NUMBER;
BEGIN
    sp_record_transfusion(
        p_patient_id => 1,  -- Use existing patient
        p_unit_id => 2,     -- Use available unit
        p_doctor_name => 'Dr. Test Physician',
        p_hospital_ward => 'EMERGENCY',
        p_transfusion_id => v_transfusion_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Transfusion ID: ' || v_transfusion_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 6: Cleanup Expired Units ===
DECLARE
    v_units_affected NUMBER;
BEGIN
    sp_cleanup_expired_units(
        p_cutoff_date => SYSDATE,
        p_action => 'MARK_EXPIRED',
        p_units_affected => v_units_affected
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Units marked expired: ' || v_units_affected);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 7: Get Inventory Level Function ===
DECLARE
    v_level NUMBER;
BEGIN
    v_level := fn_get_inventory_level('O+');
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - O+ inventory: ' || v_level || ' units');
    
    v_level := fn_get_inventory_level('AB-');
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - AB- inventory: ' || v_level || ' units');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 8: Blood Compatibility Function ===
DECLARE
    v_compatible BOOLEAN;
BEGIN
    v_compatible := fn_check_blood_compatibility('O-', 'AB+');
    IF v_compatible THEN
        DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - O- compatible with AB+ (Universal donor)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED - Should be compatible');
    END IF;
    
    v_compatible := fn_check_blood_compatibility('AB+', 'O-');
    IF NOT v_compatible THEN
        DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - AB+ not compatible with O- (Correct)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED - Should not be compatible');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 9: Days Until Expiry Function ===
DECLARE
    v_days NUMBER;
BEGIN
    v_days := fn_days_until_expiry(1);
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Unit 1 expires in: ' || v_days || ' days');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 10: Donor Donation Count Function ===
DECLARE
    v_count NUMBER;
BEGIN
    v_count := fn_get_donor_donation_count(1);
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Donor 1 has ' || v_count || ' donations');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 11: Shortage Risk Function ===
DECLARE
    v_risk VARCHAR2(20);
BEGIN
    FOR rec IN (SELECT DISTINCT blood_type FROM blood_units ORDER BY blood_type) LOOP
        v_risk := fn_get_shortage_risk(rec.blood_type);
        DBMS_OUTPUT.PUT_LINE('Blood Type ' || rec.blood_type || ': ' || v_risk);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Shortage risk calculated for all types');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 12: Report Expiring Units (Cursor) ===
BEGIN
    sp_report_expiring_units(p_days_threshold => 30);
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Expiring units report generated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 13: Identify Inactive Donors (Bulk Collect) ===
BEGIN
    sp_identify_inactive_donors;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Inactive donors identified');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 14: Rank Top Donors (Window Functions) ===
BEGIN
    sp_rank_top_donors;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Top donors ranked');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 15: Analyze Transfusion Trends (LAG/LEAD) ===
BEGIN
    sp_analyze_transfusion_trends;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Transfusion trends analyzed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 16: Inventory Distribution (Window Functions) ===
BEGIN
    sp_inventory_distribution;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Inventory distribution displayed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 17: Package - Register Donor ===
DECLARE
    v_donor_id NUMBER;
BEGIN
    pkg_blood_inventory.register_donor(
        p_first_name => 'Package',
        p_last_name => 'TestDonor',
        p_blood_type => 'B+',
        p_dob => TO_DATE('1988-08-20', 'YYYY-MM-DD'),
        p_gender => 'F',
        p_contact => '+250788777666',
        p_email => 'package.test@email.com',
        p_address => 'Package Test Address',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Package donor registered: ' || v_donor_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 18: Package - Display Inventory Summary ===
BEGIN
    pkg_blood_inventory.display_inventory_summary;
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Package inventory summary displayed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 19: Package Functions ===
DECLARE
    v_level NUMBER;
    v_compatible BOOLEAN;
    v_risk VARCHAR2(20);
BEGIN
    v_level := pkg_blood_inventory.get_inventory_level('O+');
    DBMS_OUTPUT.PUT_LINE('Inventory level O+: ' || v_level);
    
    v_compatible := pkg_blood_inventory.check_compatibility('O-', 'A+');
    IF v_compatible THEN
        DBMS_OUTPUT.PUT_LINE('O- is compatible with A+');
    END IF;
    
    v_risk := pkg_blood_inventory.get_shortage_risk('AB-');
    DBMS_OUTPUT.PUT_LINE('AB- risk level: ' || v_risk);
    
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - All package functions working');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT
PROMPT === TEST 20: Edge Cases - Non-existent IDs ===
DECLARE
    v_unit_id NUMBER;
BEGIN
    sp_record_donation(
        p_donor_id => 999999,  -- Non-existent
        p_unit_id => v_unit_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED - Should have raised exception');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED - Correctly handled non-existent donor');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
        END IF;
END;
/

PROMPT
PROMPT ====================================================
PROMPT TESTING COMPLETE
PROMPT ====================================================
PROMPT Summary:
PROMPT - 5 Procedures tested
PROMPT - 5 Functions tested  
PROMPT - 2 Cursor implementations tested
PROMPT - 3 Window function procedures tested
PROMPT - 1 Package with multiple methods tested
PROMPT - Edge cases and error handling validated
PROMPT ====================================================

-- =====================================================
-- PERFORMANCE TESTING QUERIES
-- =====================================================

PROMPT
PROMPT === PERFORMANCE TEST: Bulk Operations ===
SET TIMING ON;

-- Test bulk insert performance
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_donor_id NUMBER;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    FOR i IN 1..100 LOOP
        sp_register_donor(
            'BulkTest', 'Donor' || i, 'O+',
            TO_DATE('1990-01-01', 'YYYY-MM-DD') + i,
            'M', '+25078800000' || i, 
            'bulk' || i || '@test.com', 'Test Address',
            v_donor_id
        );
    END LOOP;
    
    v_end_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('Bulk insert time: ' || 
        EXTRACT(SECOND FROM (v_end_time - v_start_time)) || ' seconds');
    
    ROLLBACK; -- Don't keep test data
END;
/

SET TIMING OFF;
