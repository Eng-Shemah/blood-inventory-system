CREATE OR REPLACE VIEW v_audit_summary AS
SELECT 
    table_name,
    operation_type,
    operation_status,
    COUNT(*) AS total_attempts,
    COUNT(DISTINCT database_user) AS unique_users,
    COUNT(DISTINCT session_id) AS unique_sessions,
    MIN(operation_date) AS first_attempt,
    MAX(operation_date) AS last_attempt
FROM audit_logs
GROUP BY table_name, operation_type, operation_status
ORDER BY table_name, operation_type, operation_status;
