create or replace TRIGGER trg_patients_restriction
BEFORE INSERT OR UPDATE OR DELETE ON patients
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
        v_record_id := :NEW.patient_id;
        v_new_values := 'Name: ' || :NEW.first_name || ' ' || :NEW.last_name || 
                       ', Blood: ' || :NEW.blood_type;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :OLD.patient_id;
        v_old_values := 'Name: ' || :OLD.first_name || ' ' || :OLD.last_name;
        v_new_values := 'Name: ' || :NEW.first_name || ' ' || :NEW.last_name;
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
        v_record_id := :OLD.patient_id;
        v_old_values := 'Name: ' || :OLD.first_name || ' ' || :OLD.last_name || 
                       ', Blood: ' || :OLD.blood_type;
    END IF;

    v_operation_allowed := fn_check_operation_allowed(SYSDATE, v_denial_reason);

    IF NOT v_operation_allowed THEN
        v_audit_id := fn_log_audit_attempt(
            'PATIENTS', v_operation_type, 'DENIED',
            v_record_id, v_old_values, v_new_values, v_denial_reason
        );
        RAISE_APPLICATION_ERROR(-20102, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit_attempt(
            'PATIENTS', v_operation_type, 'ALLOWED',
            v_record_id, v_old_values, v_new_values, NULL
        );
    END IF;
END;
