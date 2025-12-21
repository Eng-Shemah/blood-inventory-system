CREATE OR REPLACE VIEW v_holiday_operations AS
SELECT 
    audit_id,
    table_name,
    operation_type,
    holiday_name,
    operation_status,
    database_user,
    operation_date
FROM audit_logs
WHERE is_holiday = 'Y'
ORDER BY operation_date DESC;
