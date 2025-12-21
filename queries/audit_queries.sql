-- AUDIT LOG TABLE
-- Purpose: Comprehensive audit trail for all DML operations

CREATE TABLE audit_logs (
    audit_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    operation_status VARCHAR2(10) NOT NULL CHECK (operation_status IN ('ALLOWED', 'DENIED')),
    record_id NUMBER,
    old_values CLOB,
    new_values CLOB,
    denial_reason VARCHAR2(500),
    database_user VARCHAR2(50) DEFAULT USER,
    os_user VARCHAR2(50),
    host_name VARCHAR2(100),
    ip_address VARCHAR2(50),
    session_id NUMBER,
    operation_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    day_of_week VARCHAR2(10),
    is_holiday CHAR(1) DEFAULT 'N',
    holiday_name VARCHAR2(100)
);

-- Create sequence for audit_id
CREATE SEQUENCE seq_audit_logs START WITH 1 INCREMENT BY 1 NOCACHE;

-- Create indexes for performance
CREATE INDEX idx_audit_date ON audit_logs(operation_date);
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_status ON audit_logs(operation_status);

-- =====================================================
-- AUDIT LOGGING FUNCTION
-- Purpose: Log all DML attempts with detailed information
-- =====================================================

CREATE OR REPLACE FUNCTION fn_log_audit_attempt (
    p_table_name IN VARCHAR2,
    p_operation_type IN VARCHAR2,
    p_operation_status IN VARCHAR2,
    p_record_id IN NUMBER DEFAULT NULL,
    p_old_values IN CLOB DEFAULT NULL,
    p_new_values IN CLOB DEFAULT NULL,
    p_denial_reason IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_audit_id NUMBER;
    v_os_user VARCHAR2(50);
    v_host_name VARCHAR2(100);
    v_ip_address VARCHAR2(50);
    v_session_id NUMBER;
    v_day_of_week VARCHAR2(10);
    v_is_holiday CHAR(1) := 'N';
    v_holiday_name VARCHAR2(100) := NULL;
BEGIN
    -- Get session information
    SELECT SYS_CONTEXT('USERENV', 'OS_USER'),
           SYS_CONTEXT('USERENV', 'HOST'),
           SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
           SYS_CONTEXT('USERENV', 'SESSIONID')
    INTO v_os_user, v_host_name, v_ip_address, v_session_id
    FROM DUAL;
    
    -- Get day of week
    v_day_of_week := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    -- Check if today is a holiday
    BEGIN
        SELECT 'Y', holiday_name
        INTO v_is_holiday, v_holiday_name
        FROM public_holidays
        WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
        AND is_active = 'Y'
        AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_is_holiday := 'N';
            v_holiday_name := NULL;
    END;
    
    -- Insert audit record
    INSERT INTO audit_logs (
        audit_id, table_name, operation_type, operation_status,
        record_id, old_values, new_values, denial_reason,
        database_user, os_user, host_name, ip_address, session_id,
        operation_date, day_of_week, is_holiday, holiday_name
    ) VALUES (
        seq_audit_logs.NEXTVAL, p_table_name, p_operation_type, p_operation_status,
        p_record_id, p_old_values, p_new_values, p_denial_reason,
        USER, v_os_user, v_host_name, v_ip_address, v_session_id,
        SYSTIMESTAMP, v_day_of_week, v_is_holiday, v_holiday_name
    ) RETURNING audit_id INTO v_audit_id;
    
    COMMIT;
    
    RETURN v_audit_id;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -1;
END fn_log_audit_attempt;
/

  
-- Query 1: Summary of All Audit Attempts
CREATE OR REPLACE VIEW v_audit_summary AS
SELECT 
    table_name,
    operation_type,
    operation_status,
    COUNT(*) AS total_attempts,
    COUNT(DISTINCT database_user) AS unique_users,
    COUNT(DISTINCT session_id) AS unique_sessions,
    MIN(operation_date) AS first_attempt,
    MAX(operation_date) AS last_attempt
FROM audit_logs
GROUP BY table_name, operation_type, operation_status
ORDER BY table_name, operation_type, operation_status;

-- Query 2: Denied Operations Report
CREATE OR REPLACE VIEW v_denied_operations AS
SELECT 
    audit_id,
    table_name,
    operation_type,
    denial_reason,
    database_user,
    os_user,
    host_name,
    day_of_week,
    is_holiday,
    holiday_name,
    operation_date
FROM audit_logs
WHERE operation_status = 'DENIED'
ORDER BY operation_date DESC;

-- Query 3: User Activity Report
CREATE OR REPLACE VIEW v_user_activity AS
SELECT 
    database_user,
    os_user,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_ops,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_ops,
    ROUND(SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS denial_rate,
    MIN(operation_date) AS first_activity,
    MAX(operation_date) AS last_activity
FROM audit_logs
GROUP BY database_user, os_user
ORDER BY total_operations DESC;

-- Query 4: Weekend vs Weekday Operations
CREATE OR REPLACE VIEW v_operation_by_day AS
SELECT 
    day_of_week,
    CASE 
        WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS day_type,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied
FROM audit_logs
GROUP BY day_of_week,
         CASE 
            WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
            ELSE 'WEEKDAY'
         END
ORDER BY 
    CASE day_of_week
        WHEN 'MON' THEN 1
        WHEN 'TUE' THEN 2
        WHEN 'WED' THEN 3
        WHEN 'THU' THEN 4
        WHEN 'FRI' THEN 5
        WHEN 'SAT' THEN 6
        WHEN 'SUN' THEN 7
    END;

-- Query 5: Holiday Operations Report
CREATE OR REPLACE VIEW v_holiday_operations AS
SELECT 
    audit_id,
    table_name,
    operation_type,
    holiday_name,
    operation_status,
    database_user,
    operation_date
FROM audit_logs
WHERE is_holiday = 'Y'
ORDER BY operation_date DESC;

-- =====================================================
-- STORED PROCEDURE: Generate Audit Report
-- =====================================================

CREATE OR REPLACE PROCEDURE sp_generate_audit_report (
    p_start_date IN DATE DEFAULT SYSDATE - 30,
    p_end_date IN DATE DEFAULT SYSDATE
) AS
    v_total_attempts NUMBER;
    v_allowed NUMBER;
    v_denied NUMBER;
    v_denial_rate NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('AUDIT REPORT');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || 
                        ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Overall Statistics
    SELECT COUNT(*),
           SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END),
           SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END)
    INTO v_total_attempts, v_allowed, v_denied
    FROM audit_logs
    WHERE operation_date BETWEEN p_start_date AND p_end_date;
    
    v_denial_rate := CASE WHEN v_total_attempts > 0 
                     THEN ROUND((v_denied / v_total_attempts) * 100, 2)
                     ELSE 0 END;
    
    DBMS_OUTPUT.PUT_LINE('OVERALL STATISTICS:');
    DBMS_OUTPUT.PUT_LINE('  Total Attempts: ' || v_total_attempts);
    DBMS_OUTPUT.PUT_LINE('  Allowed: ' || v_allowed);
    DBMS_OUTPUT.PUT_LINE('  Denied: ' || v_denied);
    DBMS_OUTPUT.PUT_LINE('  Denial Rate: ' || v_denial_rate || '%');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- By Table
    DBMS_OUTPUT.PUT_LINE('OPERATIONS BY TABLE:');
    FOR rec IN (
        SELECT table_name, operation_type,
               COUNT(*) AS total,
               SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied
        FROM audit_logs
        WHERE operation_date BETWEEN p_start_date AND p_end_date
        GROUP BY table_name, operation_type
        ORDER BY table_name, operation_type
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || RPAD(rec.table_name, 15) || ' ' || 
                            RPAD(rec.operation_type, 10) || ' Total: ' || 
                            LPAD(rec.total, 5) || ' Denied: ' || rec.denied);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Denial Reasons
    DBMS_OUTPUT.PUT_LINE('TOP DENIAL REASONS:');
    FOR rec IN (
        SELECT denial_reason, COUNT(*) AS count
        FROM audit_logs
        WHERE operation_status = 'DENIED'
        AND operation_date BETWEEN p_start_date AND p_end_date
        AND denial_reason IS NOT NULL
        GROUP BY denial_reason
        ORDER BY count DESC
        FETCH FIRST 5 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  [' || rec.count || 'x] ' || rec.denial_reason);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
END sp_generate_audit_report;
/
