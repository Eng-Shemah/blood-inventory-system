CREATE TABLE blood_units (
    unit_id NUMBER(10) PRIMARY KEY,
    donor_id NUMBER(10) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL,
    collection_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    volume_ml NUMBER(4) DEFAULT 450 CHECK (volume_ml BETWEEN 400 AND 500),
    status VARCHAR2(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'ISSUED', 'EXPIRED', 'DISCARDED', 'TESTING')),
    test_results VARCHAR2(10) CHECK (test_results IN ('PASSED', 'FAILED', 'PENDING')),
    storage_location VARCHAR2(50),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_blood_donor FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
) TABLESPACE blood_data;