CREATE OR REPLACE VIEW v_operation_by_day AS
SELECT 
    day_of_week,
    CASE 
        WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS day_type,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied
FROM audit_logs
GROUP BY day_of_week,
         CASE 
            WHEN day_of_week IN ('SAT', 'SUN') THEN 'WEEKEND'
            ELSE 'WEEKDAY'
         END
ORDER BY 
    CASE day_of_week
        WHEN 'MON' THEN 1
        WHEN 'TUE' THEN 2
        WHEN 'WED' THEN 3
        WHEN 'THU' THEN 4
        WHEN 'FRI' THEN 5
        WHEN 'SAT' THEN 6
        WHEN 'SUN' THEN 7
    END;
