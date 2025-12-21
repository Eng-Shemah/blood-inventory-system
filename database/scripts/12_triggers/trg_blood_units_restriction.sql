create or replace TRIGGER trg_blood_units_restriction
BEFORE INSERT OR UPDATE OR DELETE ON blood_units
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
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.unit_id;
        v_new_values := 'Unit: ' || :NEW.unit_id || ', Blood: ' || :NEW.blood_type || 
                       ', Status: ' || :NEW.status || ', Donor: ' || :NEW.donor_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :OLD.unit_id;
        v_old_values := 'Status: ' || :OLD.status || ', Test: ' || :OLD.test_results;
        v_new_values := 'Status: ' || :NEW.status || ', Test: ' || :NEW.test_results;
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
        v_record_id := :OLD.unit_id;
        v_old_values := 'Unit: ' || :OLD.unit_id || ', Blood: ' || :OLD.blood_type || 
                       ', Status: ' || :OLD.status;
    END IF;

    v_operation_allowed := fn_check_operation_allowed(SYSDATE, v_denial_reason);

    IF NOT v_operation_allowed THEN
        v_audit_id := fn_log_audit_attempt(
            'BLOOD_UNITS', v_operation_type, 'DENIED',
            v_record_id, v_old_values, v_new_values, v_denial_reason
        );
        RAISE_APPLICATION_ERROR(-20101, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit_attempt(
            'BLOOD_UNITS', v_operation_type, 'ALLOWED',
            v_record_id, v_old_values, v_new_values, NULL
        );
    END IF;
END;
