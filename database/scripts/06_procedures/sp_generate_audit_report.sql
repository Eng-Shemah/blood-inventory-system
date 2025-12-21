create or replace PROCEDURE sp_generate_audit_report (
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
