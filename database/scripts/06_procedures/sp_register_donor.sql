-- PROCEDURE 1: Register New Donor
-- Purpose: Insert a new donor with validation
-- Parameters: All donor details with OUT parameter for generated ID
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_register_donor (
    p_first_name IN donors.first_name%TYPE,
    p_last_name IN donors.last_name%TYPE,
    p_blood_type IN donors.blood_type%TYPE,
    p_dob IN donors.date_of_birth%TYPE,
    p_gender IN donors.gender%TYPE,
    p_contact IN donors.contact_number%TYPE,
    p_email IN donors.email%TYPE,
    p_address IN donors.address%TYPE,
    p_donor_id OUT donors.donor_id%TYPE
) AS
    v_age NUMBER;
    e_invalid_age EXCEPTION;
    e_invalid_blood_type EXCEPTION;
    e_duplicate_email EXCEPTION;
    v_email_count NUMBER;
BEGIN
    -- Validate age (must be 18-65)
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    IF v_age < 18 OR v_age > 65 THEN
        RAISE e_invalid_age;
    END IF;
    
    -- Validate blood type
    IF p_blood_type NOT IN ('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') THEN
        RAISE e_invalid_blood_type;
    END IF;
    
    -- Check for duplicate email
    SELECT COUNT(*) INTO v_email_count
    FROM donors
    WHERE email = p_email;
    
    IF v_email_count > 0 THEN
        RAISE e_duplicate_email;
    END IF;
    
    -- Insert donor
    INSERT INTO donors (
        donor_id, first_name, last_name, blood_type, 
        date_of_birth, gender, contact_number, email, address
    ) VALUES (
        seq_donors.NEXTVAL, p_first_name, p_last_name, p_blood_type,
        p_dob, p_gender, p_contact, p_email, p_address
    ) RETURNING donor_id INTO p_donor_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Donor registered successfully. ID: ' || p_donor_id);
    
EXCEPTION
    WHEN e_invalid_age THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Donor age must be between 18 and 65 years.');
    WHEN e_invalid_blood_type THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Invalid blood type. Must be O+, O-, A+, A-, B+, B-, AB+, or AB-.');
    WHEN e_duplicate_email THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Email already exists in the system.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error registering donor: ' || SQLERRM);
END sp_register_donor;
/