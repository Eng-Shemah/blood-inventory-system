create or replace TRIGGER trg_transfusions_restriction
BEFORE INSERT OR UPDATE OR DELETE ON transfusions
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
        v_record_id := :NEW.transfusion_id;
        v_new_values := 'Patient: ' || :NEW.patient_id || ', Unit: ' || :NEW.unit_id || 
                       ', Doctor: ' || :NEW.doctor_name || ', Ward: ' || :NEW.hospital_ward;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :OLD.transfusion_id;
        v_old_values := 'Doctor: ' || :OLD.doctor_name || ', Ward: ' || :OLD.hospital_ward;
        v_new_values := 'Doctor: ' || :NEW.doctor_name || ', Ward: ' || :NEW.hospital_ward;
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
        v_record_id := :OLD.transfusion_id;
        v_old_values := 'Patient: ' || :OLD.patient_id || ', Unit: ' || :OLD.unit_id || 
                       ', Date: ' || TO_CHAR(:OLD.transfusion_date, 'YYYY-MM-DD');
    END IF;

    v_operation_allowed := fn_check_operation_allowed(SYSDATE, v_denial_reason);

    IF NOT v_operation_allowed THEN
        v_audit_id := fn_log_audit_attempt(
            'TRANSFUSIONS', v_operation_type, 'DENIED',
            v_record_id, v_old_values, v_new_values, v_denial_reason
        );
        RAISE_APPLICATION_ERROR(-20103, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit_attempt(
            'TRANSFUSIONS', v_operation_type, 'ALLOWED',
            v_record_id, v_old_values, v_new_values, NULL
        );
    END IF;
END;
