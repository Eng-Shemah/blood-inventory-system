CREATE TABLE inventory (
    inventory_id NUMBER(10) PRIMARY KEY,
    unit_id NUMBER(10) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL,
    storage_section VARCHAR2(20) CHECK (storage_section IN ('REFRIGERATOR_A', 'REFRIGERATOR_B', 'FREEZER', 'QUARANTINE')),
    temperature_monitor NUMBER(4,1),
    last_checked_date DATE DEFAULT SYSDATE,
    checked_by VARCHAR2(50),
    notes VARCHAR2(200),
    CONSTRAINT fk_inventory_unit FOREIGN KEY (unit_id) REFERENCES blood_units(unit_id)
) TABLESPACE blood_data;