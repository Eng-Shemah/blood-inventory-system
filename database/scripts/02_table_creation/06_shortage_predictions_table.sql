CREATE TABLE shortage_predictions (
    prediction_id NUMBER(10) PRIMARY KEY,
    blood_type VARCHAR2(3) NOT NULL,
    prediction_date DATE NOT NULL,
    predicted_shortage_date DATE NOT NULL,
    risk_level VARCHAR2(15) CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    confidence_level NUMBER(3) CHECK (confidence_level BETWEEN 0 AND 100),
    current_stock_level NUMBER(5),
    predicted_demand NUMBER(5),
    recommended_action VARCHAR2(200),
    created_date DATE DEFAULT SYSDATE
) TABLESPACE blood_data;