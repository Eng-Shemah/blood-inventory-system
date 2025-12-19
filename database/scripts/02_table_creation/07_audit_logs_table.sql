CREATE TABLE audit_logs (
    log_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id VARCHAR2(100),
    old_values CLOB,
    new_values CLOB,
    changed_by VARCHAR2(50),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR2(45),
    operation_status VARCHAR2(10) CHECK (operation_status IN ('SUCCESS', 'FAILED', 'BLOCKED'))
) TABLESPACE blood_data;