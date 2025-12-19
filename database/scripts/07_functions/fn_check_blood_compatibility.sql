-- FUNCTION 2: Validate Blood Type Compatibility
-- Purpose: Check if donor blood can be given to patient
-- Returns: TRUE if compatible, FALSE otherwise
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_blood_compatibility (
    p_donor_blood IN VARCHAR2,
    p_patient_blood IN VARCHAR2
) RETURN BOOLEAN
AS
BEGIN
    -- Universal donor O- can give to anyone
    IF p_donor_blood = 'O-' THEN
        RETURN TRUE;
    END IF;
    
    -- O+ can give to all positive types
    IF p_donor_blood = 'O+' AND p_patient_blood IN ('O+', 'A+', 'B+', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- A- can give to A and AB (both + and -)
    IF p_donor_blood = 'A-' AND p_patient_blood IN ('A-', 'A+', 'AB-', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- A+ can give to A+ and AB+
    IF p_donor_blood = 'A+' AND p_patient_blood IN ('A+', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- B- can give to B and AB (both + and -)
    IF p_donor_blood = 'B-' AND p_patient_blood IN ('B-', 'B+', 'AB-', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- B+ can give to B+ and AB+
    IF p_donor_blood = 'B+' AND p_patient_blood IN ('B+', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- AB- can give to AB- and AB+
    IF p_donor_blood = 'AB-' AND p_patient_blood IN ('AB-', 'AB+') THEN
        RETURN TRUE;
    END IF;
    
    -- AB+ can only give to AB+
    IF p_donor_blood = 'AB+' AND p_patient_blood = 'AB+' THEN
        RETURN TRUE;
    END IF;
    
    -- Exact match always works
    IF p_donor_blood = p_patient_blood THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END fn_check_blood_compatibility;
/