CREATE TABLE transfusions (
    transfusion_id NUMBER(10) PRIMARY KEY,
    patient_id NUMBER(10) NOT NULL,
    unit_id NUMBER(10) NOT NULL,
    transfusion_date DATE NOT NULL,
    doctor_name VARCHAR2(100) NOT NULL,
    hospital_ward VARCHAR2(50),
    transfusion_reason VARCHAR2(200),
    transfusion_status VARCHAR2(20) DEFAULT 'COMPLETED' CHECK (transfusion_status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    notes VARCHAR2(500),
    CONSTRAINT fk_transfusion_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_transfusion_unit FOREIGN KEY (unit_id) REFERENCES blood_units(unit_id)
) TABLESPACE blood_data;