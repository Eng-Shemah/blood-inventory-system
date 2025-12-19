CREATE TABLE donors (
    donor_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    date_of_birth DATE NOT NULL,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F', 'O')),
    contact_number VARCHAR2(15),
    email VARCHAR2(100),
    address VARCHAR2(200),
    registration_date DATE DEFAULT SYSDATE,
    last_donation_date DATE,
    health_status VARCHAR2(20) DEFAULT 'ELIGIBLE' CHECK (health_status IN ('ELIGIBLE', 'DEFERRED', 'PERMANENT_DEFERRED')),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N'))
) TABLESPACE blood_data;