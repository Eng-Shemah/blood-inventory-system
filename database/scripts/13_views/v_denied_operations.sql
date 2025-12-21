CREATE OR REPLACE VIEW v_denied_operations AS
SELECT 
    audit_id,
    table_name,
    operation_type,
    denial_reason,
    database_user,
    os_user,
    host_name,
    day_of_week,
    is_holiday,
    holiday_name,
    operation_date
FROM audit_logs
WHERE operation_status = 'DENIED'
ORDER BY operation_date DESC;
