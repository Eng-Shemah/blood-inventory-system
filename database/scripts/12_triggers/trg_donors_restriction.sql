create or replace TRIGGER trg_donors_restriction
BEFORE INSERT OR UPDATE OR DELETE ON donors
FOR EACH ROW
DECLARE
    v_operation_allowed BOOLEAN;
    v_denial_reason VARCHAR2(500);
    v_operation_type VARCHAR2(10);
    v_record_id NUMBER;
    v_old_values CLOB;
    v_new_values CLOB;
    v_audit_id NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.donor_id;
        v_new_values := 'Name: ' || :NEW.first_name || ' ' || :NEW.last_name || 
                       ', Blood: ' || :NEW.blood_type || ', Email: ' || :NEW.email;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :OLD.donor_id;
        v_old_values := 'Name: ' || :OLD.first_name || ' ' || :OLD.last_name || 
                       ', Blood: ' || :OLD.blood_type || ', Email: ' || :OLD.email;
        v_new_values := 'Name: ' || :NEW.first_name || ' ' || :NEW.last_name || 
                       ', Blood: ' || :NEW.blood_type || ', Email: ' || :NEW.email;
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
        v_record_id := :OLD.donor_id;
        v_old_values := 'Name: ' || :OLD.first_name || ' ' || :OLD.last_name || 
                       ', Blood: ' || :OLD.blood_type || ', Email: ' || :OLD.email;
    END IF;

    -- Check if operation is allowed
    v_operation_allowed := fn_check_operation_allowed(SYSDATE, v_denial_reason);

    IF NOT v_operation_allowed THEN
        -- Log denied attempt
        v_audit_id := fn_log_audit_attempt(
            p_table_name => 'DONORS',
            p_operation_type => v_operation_type,
            p_operation_status => 'DENIED',
            p_record_id => v_record_id,
            p_old_values => v_old_values,
            p_new_values => v_new_values,
            p_denial_reason => v_denial_reason
        );

        -- Raise error to block operation
        RAISE_APPLICATION_ERROR(-20100, v_denial_reason);
    ELSE
        -- Log allowed attempt
        v_audit_id := fn_log_audit_attempt(
            p_table_name => 'DONORS',
            p_operation_type => v_operation_type,
            p_operation_status => 'ALLOWED',
            p_record_id => v_record_id,
            p_old_values => v_old_values,
            p_new_values => v_new_values,
            p_denial_reason => NULL
        );
    END IF;
END;
