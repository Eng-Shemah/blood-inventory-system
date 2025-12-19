-- Verify Audit Trail
SELECT table_name, operation_type, changed_by, change_timestamp, operation_status
FROM audit_logs
ORDER BY change_timestamp DESC
FETCH FIRST 10 ROWS ONLY;