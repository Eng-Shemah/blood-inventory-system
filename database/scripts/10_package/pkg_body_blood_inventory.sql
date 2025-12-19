CREATE OR REPLACE PACKAGE BODY pkg_blood_inventory AS

    -- ==========================================
    -- PROCEDURE: register_donor
    -- Wrapper calling standalone procedure
    -- ==========================================
    PROCEDURE register_donor(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_blood_type IN VARCHAR2,
        p_dob IN DATE,
        p_gender IN CHAR,
        p_contact IN VARCHAR2,
        p_email IN VARCHAR2,
        p_address IN VARCHAR2,
        p_donor_id OUT NUMBER
    ) IS
    BEGIN
        sp_register_donor(
            p_first_name,
            p_last_name,
            p_blood_type,
            p_dob,
            p_gender,
            p_contact,
            p_email,
            p_address,
            p_donor_id
        );
    END register_donor;


    -- ==========================================
    -- PROCEDURE: record_donation
    -- ==========================================
    PROCEDURE record_donation(
        p_donor_id IN NUMBER,
        p_unit_id OUT NUMBER
    ) IS
    BEGIN
        sp_record_donation(
            p_donor_id,
            SYSDATE,
            p_unit_id
        );
    END record_donation;


    -- ==========================================
    -- PROCEDURE: process_transfusion
    -- ==========================================
    PROCEDURE process_transfusion(
        p_patient_id IN NUMBER,
        p_unit_id IN NUMBER,
        p_doctor_name IN VARCHAR2,
        p_hospital_ward IN VARCHAR2,
        p_transfusion_id OUT NUMBER
    ) IS
    BEGIN
        sp_record_transfusion(
            p_patient_id,
            p_unit_id,
            p_doctor_name,
            p_hospital_ward,
            p_transfusion_id
        );
    END process_transfusion;


    -- ==========================================
    -- FUNCTION: get_inventory_level
    -- ==========================================
    FUNCTION get_inventory_level(
        p_blood_type IN VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN fn_get_inventory_level(p_blood_type);
    END get_inventory_level;


    -- ==========================================
    -- FUNCTION: get_shortage_risk
    -- ==========================================
    FUNCTION get_shortage_risk(
        p_blood_type IN VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN
        RETURN fn_get_shortage_risk(p_blood_type);
    END get_shortage_risk;


    -- ==========================================
    -- FUNCTION: days_until_expiry
    -- ==========================================
    FUNCTION days_until_expiry(
        p_unit_id IN NUMBER
    ) RETURN NUMBER IS
    BEGIN
        RETURN fn_days_until_expiry(p_unit_id);
    END days_until_expiry;

END pkg_blood_inventory;
/
