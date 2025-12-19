-- FUNCTION 5: Calculate Shortage Risk Level
-- Purpose: Determine if blood type is at critical, low, or adequate level
-- Returns: 'CRITICAL', 'LOW', 'ADEQUATE', 'SURPLUS'
-- =====================================================
CREATE OR REPLACE FUNCTION fn_get_shortage_risk (
    p_blood_type IN VARCHAR2
) RETURN VARCHAR2
AS
    v_available_count NUMBER;
    v_avg_weekly_usage NUMBER;
    v_risk_level VARCHAR2(20);
BEGIN
    -- Get available units
    v_available_count := fn_get_inventory_level(p_blood_type);
    
    -- Calculate average weekly usage (last 30 days)
    SELECT COUNT(*) / 4
    INTO v_avg_weekly_usage
    FROM transfusions t
    JOIN blood_units bu ON t.unit_id = bu.unit_id
    WHERE bu.blood_type = p_blood_type
    AND t.transfusion_date >= SYSDATE - 30;
    
    -- Determine risk level
    IF v_available_count < v_avg_weekly_usage * 0.5 THEN
        v_risk_level := 'CRITICAL';
    ELSIF v_available_count < v_avg_weekly_usage * 1.5 THEN
        v_risk_level := 'LOW';
    ELSIF v_available_count < v_avg_weekly_usage * 3 THEN
        v_risk_level := 'ADEQUATE';
    ELSE
        v_risk_level := 'SURPLUS';
    END IF;
    
    RETURN v_risk_level;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'UNKNOWN';
END fn_get_shortage_risk;
/