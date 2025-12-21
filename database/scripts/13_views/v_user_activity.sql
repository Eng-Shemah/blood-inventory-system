CREATE OR REPLACE VIEW v_user_activity AS
SELECT 
    database_user,
    os_user,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN operation_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_ops,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_ops,
    ROUND(SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS denial_rate,
    MIN(operation_date) AS first_activity,
    MAX(operation_date) AS last_activity
FROM audit_logs
GROUP BY database_user, os_user
ORDER BY total_operations DESC;
