CREATE TABLE audit_logs (
    audit_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    operation_status VARCHAR2(10) NOT NULL CHECK (operation_status IN ('ALLOWED', 'DENIED')),
    record_id NUMBER,
    old_values CLOB,
    new_values CLOB,
    denial_reason VARCHAR2(500),
    database_user VARCHAR2(50) DEFAULT USER,
    os_user VARCHAR2(50),
    host_name VARCHAR2(100),
    ip_address VARCHAR2(50),
    session_id NUMBER,
    operation_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    day_of_week VARCHAR2(10),
    is_holiday CHAR(1) DEFAULT 'N',
    holiday_name VARCHAR2(100)
);

-- Create sequence for audit_id
CREATE SEQUENCE seq_audit_logs START WITH 1 INCREMENT BY 1 NOCACHE;

-- Create indexes for performance
CREATE INDEX idx_audit_date ON audit_logs(operation_date);
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_status ON audit_logs(operation_status);
