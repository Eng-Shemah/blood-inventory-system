-- PROCEDURE 4: Record Blood Transfusion
-- Purpose: Create transfusion record and update blood unit status
-- Parameters: Patient ID, Unit ID, Doctor name, Hospital ward
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_record_transfusion (
    p_patient_id IN transfusions.patient_id%TYPE,
    p_unit_id IN transfusions.unit_id%TYPE,
    p_doctor_name IN transfusions.doctor_name%TYPE,
    p_hospital_ward IN transfusions.hospital_ward%TYPE,
    p_transfusion_id OUT transfusions.transfusion_id%TYPE
) AS
    v_patient_blood_type patients.blood_type%TYPE;
    v_unit_blood_type blood_units.blood_type%TYPE;
    v_unit_status blood_units.status%TYPE;
    v_patient_exists NUMBER;
    v_unit_exists NUMBER;
    e_patient_not_found EXCEPTION;
    e_unit_not_found EXCEPTION;
    e_incompatible_blood EXCEPTION;
    e_unit_not_available EXCEPTION;
BEGIN
    -- Check patient exists
    SELECT COUNT(*) INTO v_patient_exists FROM patients WHERE patient_id = p_patient_id;
    IF v_patient_exists = 0 THEN RAISE e_patient_not_found; END IF;
    
    -- Check unit exists
    SELECT COUNT(*) INTO v_unit_exists FROM blood_units WHERE unit_id = p_unit_id;
    IF v_unit_exists = 0 THEN RAISE e_unit_not_found; END IF;
    
    -- Get blood types
    SELECT blood_type INTO v_patient_blood_type FROM patients WHERE patient_id = p_patient_id;
    SELECT blood_type, status INTO v_unit_blood_type, v_unit_status 
    FROM blood_units WHERE unit_id = p_unit_id;
    
    -- Check unit availability
    IF v_unit_status != 'AVAILABLE' THEN
        RAISE e_unit_not_available;
    END IF;
    
    -- Basic blood compatibility check (simplified)
    IF v_unit_blood_type NOT IN (v_patient_blood_type, 'O-') THEN
        RAISE e_incompatible_blood;
    END IF;
    
    -- Insert transfusion record
    INSERT INTO transfusions (
        transfusion_id, patient_id, unit_id, transfusion_date,
        doctor_name, hospital_ward
    ) VALUES (
        seq_transfusions.NEXTVAL, p_patient_id, p_unit_id, SYSDATE,
        p_doctor_name, p_hospital_ward
    ) RETURNING transfusion_id INTO p_transfusion_id;
    
    -- Update blood unit status to IN_USE
    UPDATE blood_units SET status = 'IN_USE' WHERE unit_id = p_unit_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfusion recorded. ID: ' || p_transfusion_id);
    
EXCEPTION
    WHEN e_patient_not_found THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20008, 'Patient ID not found.');
    WHEN e_unit_not_found THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'Blood unit ID not found.');
    WHEN e_unit_not_available THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Blood unit is not available for transfusion.');
    WHEN e_incompatible_blood THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Incompatible blood types for transfusion.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error recording transfusion: ' || SQLERRM);
END sp_record_transfusion;
/