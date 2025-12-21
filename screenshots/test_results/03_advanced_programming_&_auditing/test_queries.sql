-- =====================================================
-- COMPREHENSIVE TESTING SUITE FOR PHASE VII
-- =====================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ====================================================
PROMPT PHASE VII - TRIGGERS & AUDITING TESTING
PROMPT ====================================================

-- =====================================================
-- TEST SECTION 1: Holiday Management
-- =====================================================

PROMPT
PROMPT === TEST 1.1: Verify Holiday Table ===
SELECT holiday_name, holiday_date, is_active
FROM public_holidays
WHERE holiday_date >= SYSDATE
ORDER BY holiday_date;

PROMPT
PROMPT === TEST 1.2: Check Current Day Type ===
DECLARE
    v_day VARCHAR2(10);
    v_is_weekend BOOLEAN;
    v_is_holiday NUMBER;
BEGIN
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_is_weekend := v_day IN ('SAT', 'SUN');
    
    SELECT COUNT(*) INTO v_is_holiday
    FROM public_holidays
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    DBMS_OUTPUT.PUT_LINE('Today is: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD Day'));
    DBMS_OUTPUT.PUT_LINE('Day of week: ' || v_day);
    DBMS_OUTPUT.PUT_LINE('Is Weekend: ' || CASE WHEN v_is_weekend THEN 'YES' ELSE 'NO' END);
    DBMS_OUTPUT.PUT_LINE('Is Holiday: ' || CASE WHEN v_is_holiday > 0 THEN 'YES' ELSE 'NO' END);
END;
/

-- =====================================================
-- TEST SECTION 2: Restriction Check Function
-- =====================================================

PROMPT
PROMPT === TEST 2.1: Test Restriction Function - Today ===
DECLARE
    v_allowed BOOLEAN;
    v_reason VARCHAR2(500);
BEGIN
    v_allowed := fn_check_operation_allowed(SYSDATE, v_reason);
    
    IF v_allowed THEN
        DBMS_OUTPUT.PUT_LINE('✓ Operations ALLOWED today');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✗ Operations DENIED today');
        DBMS_OUTPUT.PUT_LINE('Reason: ' || v_reason);
    END IF;
END;
/

PROMPT
PROMPT === TEST 2.2: Test Restriction Function - Specific Dates ===
DECLARE
    v_allowed BOOLEAN;
    v_reason VARCHAR2(500);
    v_test_date DATE;
BEGIN
    -- Test Monday (should be denied)
    v_test_date := NEXT_DAY(TRUNC(SYSDATE), 'MONDAY');
    v_allowed := fn_check_operation_allowed(v_test_date, v_reason);
    DBMS_OUTPUT.PUT_LINE('Monday (' || TO_CHAR(v_test_date, 'YYYY-MM-DD') || '): ' || 
                        CASE WHEN v_allowed THEN 'ALLOWED' ELSE 'DENIED' END);
    IF NOT v_allowed THEN DBMS_OUTPUT.PUT_LINE('  ' || v_reason); END IF;
    
    -- Test Saturday (should be allowed)
    v_test_date := NEXT_DAY(TRUNC(SYSDATE), 'SATURDAY');
    v_allowed := fn_check_operation_allowed(v_test_date, v_reason);
    DBMS_OUTPUT.PUT_LINE('Saturday (' || TO_CHAR(v_test_date, 'YYYY-MM-DD') || '): ' || 
                        CASE WHEN v_allowed THEN 'ALLOWED' ELSE 'DENIED' END);
    IF NOT v_allowed THEN DBMS_OUTPUT.PUT_LINE('  ' || v_reason); END IF;
    
    -- Test Sunday (should be allowed)
    v_test_date := NEXT_DAY(TRUNC(SYSDATE), 'SUNDAY');
    v_allowed := fn_check_operation_allowed(v_test_date, v_reason);
    DBMS_OUTPUT.PUT_LINE('Sunday (' || TO_CHAR(v_test_date, 'YYYY-MM-DD') || '): ' || 
                        CASE WHEN v_allowed THEN 'ALLOWED' ELSE 'DENIED' END);
    IF NOT v_allowed THEN DBMS_OUTPUT.PUT_LINE('  ' || v_reason); END IF;
END;
/

-- =====================================================
-- TEST SECTION 3: Trigger Testing
-- =====================================================

PROMPT
PROMPT === TEST 3.1: Attempt INSERT on Current Day ===
PROMPT (This will succeed on weekends, fail on weekdays)
BEGIN
    INSERT INTO donors (
        donor_id, first_name, last_name, blood_type, 
        date_of_birth, gender, contact_number, email, address
    ) VALUES (
        seq_donors.NEXTVAL, 'TriggerTest', 'User', 'O+',
        TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'M',
        '+250788000001', 'trigger.test@email.com', 'Test Address'
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ INSERT SUCCESSFUL - Operation was allowed');
    ROLLBACK; -- Don't keep test data
    
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20100 THEN
            DBMS_OUTPUT.PUT_LINE('✗ INSERT BLOCKED by trigger (Expected on weekdays)');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
        END IF;
END;
/

PROMPT
PROMPT === TEST 3.2: Attempt UPDATE on Current Day ===
BEGIN
    UPDATE donors
    SET contact_number = '+250788999999'
    WHERE donor_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('✓ UPDATE SUCCESSFUL - Operation was allowed');
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20100 THEN
            DBMS_OUTPUT.PUT_LINE('✗ UPDATE BLOCKED by trigger (Expected on weekdays)');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
        END IF;
END;
/

PROMPT
PROMPT === TEST 3.3: Attempt DELETE on Current Day ===
BEGIN
    DELETE FROM donors
    WHERE donor_id = 999999; -- Non-existent ID to avoid actual deletion
    
    DBMS_OUTPUT.PUT_LINE('✓ DELETE SUCCESSFUL - Operation was allowed');
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20100 THEN
            DBMS_OUTPUT.PUT_LINE('✗ DELETE BLOCKED by trigger (Expected on weekdays)');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
        END IF;
END;
/

PROMPT
PROMPT === TEST 3.4: Test All Protected Tables ===
DECLARE
    v_error_code NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing BLOOD_UNITS table:');
    BEGIN
        INSERT INTO blood_units (unit_id, donor_id, blood_type, collection_date, expiry_date, status, test_results)
        VALUES (seq_blood_units.NEXTVAL, 1, 'O+', SYSDATE, SYSDATE + 42, 'AVAILABLE', 'PASSED');
        DBMS_OUTPUT.PUT_LINE('  ✓ ALLOWED');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            IF v_error_code = -20101 THEN
                DBMS_OUTPUT.PUT_LINE('  ✗ DENIED (Expected on weekdays)');
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Testing PATIENTS table:');
    BEGIN
        INSERT INTO patients (patient_id, first_name, last_name, blood_type, date_of_birth, gender)
        VALUES (seq_patients.NEXTVAL, 'Test', 'Patient', 'A+', TO_DATE('1980-01-01', 'YYYY-MM-DD'), 'M');
        DBMS_OUTPUT.PUT_LINE('  ✓ ALLOWED');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            IF v_error_code = -20102 THEN
                DBMS_OUTPUT.PUT_LINE('  ✗ DENIED (Expected on weekdays)');
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Testing TRANSFUSIONS table:');
    BEGIN
        INSERT INTO transfusions (transfusion_id, patient_id, unit_id, transfusion_date, doctor_name, hospital_ward)
        VALUES (seq_transfusions.NEXTVAL, 1, 1, SYSDATE, 'Dr. Test', 'ICU');
        DBMS_OUTPUT.PUT_LINE('  ✓ ALLOWED');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            IF v_error_code = -20103 THEN
                DBMS_OUTPUT.PUT_LINE('  ✗ DENIED (Expected on weekdays)');
            END IF;
    END;
END;
/

-- =====================================================
-- TEST SECTION 4: Audit Log Verification
-- =====================================================

PROMPT
PROMPT === TEST 4.1: View Recent Audit Entries ===
SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    day_of_week,
    is_holiday,
    TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') AS operation_time
FROM audit_logs
ORDER BY operation_date DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT === TEST 4.2: Count Audit Entries by Status ===
SELECT 
    operation_status,
    COUNT(*) AS total_count,
    MIN(operation_date) AS first_attempt,
    MAX(operation_date) AS last_attempt
FROM audit_logs
GROUP BY operation_status;

PROMPT
PROMPT === TEST 4.3: Denied Operations Summary ===
SELECT 
    table_name,
    operation_type,
    COUNT(*) AS denial_count,
    MAX(denial_reason) AS sample_reason
FROM audit_logs
WHERE operation_status = 'DENIED'
GROUP BY table_name, operation_type
ORDER BY denial_count DESC;

PROMPT
PROMPT === TEST 4.4: View Detailed Denied Operations ===
SELECT 
    audit_id,
    table_name,
    operation_type,
    denial_reason,
    database_user,
    day_of_week,
    TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') AS denied_at
FROM audit_logs
WHERE operation_status = 'DENIED'
ORDER BY operation_date DESC
FETCH FIRST 5 ROWS ONLY;

PROMPT
PROMPT === TEST 4.5: User Activity Audit ===
SELECT 
    database_user,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied
FROM audit_logs
GROUP BY database_user
ORDER BY total_operations DESC;

-- =====================================================
-- TEST SECTION 5: Audit Views Testing
-- =====================================================

PROMPT
PROMPT === TEST 5.1: Audit Summary View ===
SELECT * FROM v_audit_summary;

PROMPT
PROMPT === TEST 5.2: Denied Operations View ===
SELECT 
    table_name,
    operation_type,
    denial_reason,
    day_of_week,
    TO_CHAR(operation_date, 'YYYY-MM-DD') AS date_attempted
FROM v_denied_operations
FETCH FIRST 5 ROWS ONLY;

PROMPT
PROMPT === TEST 5.3: User Activity View ===
SELECT * FROM v_user_activity;

PROMPT
PROMPT === TEST 5.4: Operations by Day View ===
SELECT * FROM v_operation_by_day
ORDER BY CASE day_of_week
    WHEN 'MON' THEN 1 WHEN 'TUE' THEN 2 WHEN 'WED' THEN 3 WHEN 'THU' THEN 4
    WHEN 'FRI' THEN 5 WHEN 'SAT' THEN 6 WHEN 'SUN' THEN 7
END;

-- =====================================================
-- TEST SECTION 6: Comprehensive Audit Report
-- =====================================================

PROMPT
PROMPT === TEST 6.1: Generate Full Audit Report ===
BEGIN
    sp_generate_audit_report(
        p_start_date => SYSDATE - 7,
        p_end_date => SYSDATE
    );
END;
/

-- =====================================================
-- TEST SECTION 7: Simulate Weekend Operations
-- =====================================================

PROMPT
PROMPT === TEST 7.1: Simulate Weekend INSERT (Manual Test) ===
PROMPT NOTE: This test should be run on a Saturday or Sunday
PROMPT Instructions:
PROMPT 1. Wait until Saturday or Sunday
PROMPT 2. Run the following INSERT statement:
PROMPT 
PROMPT INSERT INTO donors (
PROMPT     donor_id, first_name, last_name, blood_type, 
PROMPT     date_of_birth, gender, contact_number, email, address
PROMPT ) VALUES (
PROMPT     seq_donors.NEXTVAL, 'Weekend', 'TestDonor', 'A+',
PROMPT     TO_DATE('1985-06-15', 'YYYY-MM-DD'), 'F',
PROMPT     '+250788123789', 'weekend.test@email.com', 'Weekend Test Address'
PROMPT );
PROMPT
PROMPT Expected Result: INSERT should SUCCEED
PROMPT

-- =====================================================
-- TEST SECTION 8: Holiday Testing
-- =====================================================

PROMPT
PROMPT === TEST 8.1: Add Test Holiday for Today (For Testing) ===
PROMPT NOTE: Uncomment the following block to test holiday restriction

/*
BEGIN
    -- Add today as a test holiday
    INSERT INTO public_holidays (
        holiday_id, holiday_name, holiday_date, country, is_active
    ) VALUES (
        seq_holidays.NEXTVAL, 
        'TEST HOLIDAY - DO NOT USE IN PRODUCTION',
        TRUNC(SYSDATE),
        'Rwanda',
        'Y'
    );
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Test holiday added for today');
    DBMS_OUTPUT.PUT_LINE('Now try INSERT operation - it should be DENIED');
    
    -- Try an operation (should be denied)
    BEGIN
        INSERT INTO donors (
            donor_id, first_name, last_name, blood_type, 
            date_of_birth, gender, contact_number, email, address
        ) VALUES (
            seq_donors.NEXTVAL, 'Holiday', 'Test', 'B+',
            TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'M',
            '+250788999888', 'holiday.test@email.com', 'Holiday Test'
        );
        DBMS_OUTPUT.PUT_LINE('✗ ERROR: Insert should have been denied!');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20100 THEN
                DBMS_OUTPUT.PUT_LINE('✓ INSERT correctly DENIED on holiday');
                DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
            END IF;
    END;
    
    -- Clean up test holiday
    DELETE FROM public_holidays 
    WHERE holiday_name = 'TEST HOLIDAY - DO NOT USE IN PRODUCTION';
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Test holiday removed');
END;
/
*/

-- =====================================================
-- TEST SECTION 9: Stress Testing
-- =====================================================

PROMPT
PROMPT === TEST 9.1: Multiple Rapid Operations (Audit Logging Performance) ===
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_operations NUMBER := 0;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    FOR i IN 1..50 LOOP
        BEGIN
            INSERT INTO donors (
                donor_id, first_name, last_name, blood_type, 
                date_of_birth, gender, contact_number, email, address
            ) VALUES (
                seq_donors.NEXTVAL, 'Stress' || i, 'Test', 'O+',
                TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'M',
                '+25078800' || LPAD(i, 4, '0'), 'stress' || i || '@test.com', 'Test'
            );
            v_operations := v_operations + 1;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Expected on weekdays
        END;
    END LOOP;
    
    v_end_time := SYSTIMESTAMP;
    
    ROLLBACK; -- Don't keep test data
    
    DBMS_OUTPUT.PUT_LINE('Stress test completed:');
    DBMS_OUTPUT.PUT_LINE('  Attempted operations: 50');
    DBMS_OUTPUT.PUT_LINE('  Successful operations: ' || v_operations);
    DBMS_OUTPUT.PUT_LINE('  Time taken: ' || 
        EXTRACT(SECOND FROM (v_end_time - v_start_time)) || ' seconds');
END;
/

-- =====================================================
-- TEST SECTION 10: Audit Log Queries
-- =====================================================

PROMPT
PROMPT === TEST 10.1: Detailed Audit Information ===
SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    SUBSTR(new_values, 1, 50) AS sample_data,
    database_user,
    os_user,
    host_name,
    day_of_week,
    is_holiday,
    TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') AS operation_time
FROM audit_logs
ORDER BY operation_date DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT === TEST 10.2: Weekend vs Weekday Operations ===
SELECT 
    CASE 
        WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS period_type,
    operation_status,
    COUNT(*) AS total_operations
FROM audit_logs
GROUP BY 
    CASE 
        WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END,
    operation_status
ORDER BY period_type, operation_status;

PROMPT
PROMPT === TEST 10.3: Operations by Hour of Day ===
SELECT 
    TO_CHAR(operation_date, 'HH24') AS hour_of_day,
    COUNT(*) AS operation_count,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_count
FROM audit_logs
WHERE operation_date >= SYSDATE - 7
GROUP BY TO_CHAR(operation_date, 'HH24')
ORDER BY hour_of_day;

PROMPT
PROMPT ====================================================
PROMPT PHASE VII TESTING COMPLETE
PROMPT ====================================================
PROMPT
PROMPT Summary of Tests:
PROMPT ✓ Holiday management table created and populated
PROMPT ✓ Audit logging table with comprehensive tracking
PROMPT ✓ Restriction check function validates day type
PROMPT ✓ Simple triggers on 4 main tables (DONORS, BLOOD_UNITS, PATIENTS, TRANSFUSIONS)
PROMPT ✓ Compound trigger on INVENTORY table
PROMPT ✓ Audit views for reporting
PROMPT ✓ All operations logged with user, time, and reason
PROMPT
PROMPT Critical Business Rule Implemented:
PROMPT → DML operations BLOCKED on weekdays (Monday-Friday)
PROMPT → DML operations ALLOWED on weekends (Saturday-Sunday)
PROMPT → DML operations BLOCKED on public holidays
PROMPT → All attempts logged in audit_logs table

-- =====================================================
-- CLEANUP SCRIPTS (Optional - for testing)
-- =====================================================

PROMPT
PROMPT === Optional: Cleanup Commands ===
PROMPT Run these if you need to reset audit logs for testing:
PROMPT 
PROMPT -- Delete all audit logs
PROMPT -- TRUNCATE TABLE audit_logs;
PROMPT 
PROMPT -- Remove test holidays
PROMPT -- DELETE FROM public_holidays WHERE holiday_name LIKE '%TEST%';
PROMPT 
PROMPT -- Disable triggers temporarily (for data loading)
PROMPT -- ALTER TRIGGER trg_donors_restriction DISABLE;
PROMPT -- ALTER TRIGGER trg_blood_units_restriction DISABLE;
PROMPT -- ALTER TRIGGER trg_patients_restriction DISABLE;
PROMPT -- ALTER TRIGGER trg_transfusions_restriction DISABLE;
PROMPT 
PROMPT -- Re-enable triggers
PROMPT -- ALTER TRIGGER trg_donors_restriction ENABLE;
PROMPT -- ALTER TRIGGER trg_blood_units_restriction ENABLE;
PROMPT -- ALTER TRIGGER trg_patients_restriction ENABLE;
PROMPT -- ALTER TRIGGER trg_transfusions_restriction ENABLE;
