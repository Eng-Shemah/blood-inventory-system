-- PACKAGE SPECIFICATION
CREATE OR REPLACE PACKAGE pkg_blood_inventory AS
    -- Public procedures
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
    );
    
    PROCEDURE record_donation(
        p_donor_id IN NUMBER,
        p_unit_id OUT NUMBER
    );
    
    PROCEDURE process_transfusion(
        p_patient_id IN NUMBER,
        p_unit_id IN NUMBER,
        p_doctor_name IN VARCHAR2,
        p_hospital_ward IN VARCHAR2,
        p_transfusion_id OUT NUMBER
    );
    
    -- Public functions
    FUNCTION get_inventory_level(
            p_blood_type IN VARCHAR2
        ) RETURN NUMBER;

        FUNCTION get_shortage_risk(
            p_blood_type IN VARCHAR2
        ) RETURN VARCHAR2;

        FUNCTION days_until_expiry(
            p_unit_id IN NUMBER
        ) RETURN NUMBER;
END pkg_blood_inventory;
/