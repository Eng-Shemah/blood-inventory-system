create or replace TRIGGER trg_inventory_compound
        FOR INSERT OR UPDATE OR DELETE ON inventory
        COMPOUND TRIGGER

            TYPE t_audit_info IS RECORD (
                operation_type VARCHAR2(10),
                record_id NUMBER,
                old_values CLOB,
                new_values CLOB
            );
            TYPE t_audit_collection IS TABLE OF t_audit_info;
            v_audit_records t_audit_collection := t_audit_collection();

            v_operation_allowed BOOLEAN;
            v_denial_reason VARCHAR2(500);
            v_operation_blocked BOOLEAN := FALSE;

            BEFORE STATEMENT IS
            BEGIN
                v_operation_allowed := fn_check_operation_allowed(SYSDATE, v_denial_reason);

                IF NOT v_operation_allowed THEN
                    v_operation_blocked := TRUE;
                    DECLARE
                        v_audit_id NUMBER;
                        v_op_type VARCHAR2(10);
                    BEGIN
                        IF INSERTING THEN v_op_type := 'INSERT';
                        ELSIF UPDATING THEN v_op_type := 'UPDATE';
                        ELSIF DELETING THEN v_op_type := 'DELETE';
                        END IF;

                        v_audit_id := fn_log_audit_attempt(
                            'INVENTORY', v_op_type, 'DENIED',
                            NULL, NULL, NULL, v_denial_reason
                        );
                    END;

                    RAISE_APPLICATION_ERROR(-20104, v_denial_reason);
                END IF;
            END BEFORE STATEMENT;

            BEFORE EACH ROW IS
                v_audit_rec t_audit_info;
            BEGIN
                IF INSERTING THEN
                    v_audit_rec.operation_type := 'INSERT';
                    v_audit_rec.record_id := :NEW.inventory_id;
                    v_audit_rec.new_values := 'Blood: ' || :NEW.blood_type || 
                                             ', Available: ' || :NEW.available_units;
                ELSIF UPDATING THEN
                    v_audit_rec.operation_type := 'UPDATE';
                    v_audit_rec.record_id := :OLD.inventory_id;
                    v_audit_rec.old_values := 'Available: ' || :OLD.available_units || 
                                             ', Reserved: ' || :OLD.reserved_units;
                    v_audit_rec.new_values := 'Available: ' || :NEW.available_units || 
                                             ', Reserved: ' || :NEW.reserved_units;
                ELSIF DELETING THEN
                    v_audit_rec.operation_type := 'DELETE';
                    v_audit_rec.record_id := :OLD.inventory_id;
                    v_audit_rec.old_values := 'Blood: ' || :OLD.blood_type || 
                                             ', Available: ' || :OLD.available_units;
                END IF;

                v_audit_records.EXTEND;
                v_audit_records(v_audit_records.COUNT) := v_audit_rec;
            END BEFORE EACH ROW;

            AFTER STATEMENT IS
                v_audit_id NUMBER;
            BEGIN
                IF NOT v_operation_blocked THEN
                    FOR i IN 1..v_audit_records.COUNT LOOP
                        v_audit_id := fn_log_audit_attempt(
                            'INVENTORY',
                            v_audit_records(i).operation_type,
                            'ALLOWED',
                            v_audit_records(i).record_id,
                            v_audit_records(i).old_values,
                            v_audit_records(i).new_values,
                            NULL
                        );
                    END LOOP;
                END IF;

                v_audit_records.DELETE;
            END AFTER STATEMENT;

        END trg_inventory_compound
