CREATE TABLE patients (
    patient_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    blood_type VARCHAR2(3),
    date_of_birth DATE,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F', 'O')),
    contact_number VARCHAR2(15),
    emergency_contact VARCHAR2(100),
    medical_history VARCHAR2(500),
    registration_date DATE DEFAULT SYSDATE
) TABLESPACE blood_data;