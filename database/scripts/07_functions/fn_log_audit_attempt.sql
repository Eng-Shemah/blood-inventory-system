create or replace FUNCTION fn_log_audit_attempt (
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
