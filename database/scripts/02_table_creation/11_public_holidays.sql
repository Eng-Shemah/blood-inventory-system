CREATE TABLE public_holidays (
    holiday_id NUMBER PRIMARY KEY,
    holiday_name VARCHAR2(100) NOT NULL,
    holiday_date DATE NOT NULL,
    country VARCHAR2(50) DEFAULT 'Rwanda',
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT uk_holiday_date UNIQUE (holiday_date, country)
);

CREATE SEQUENCE seq_holidays START WITH 1 INCREMENT BY 1 NOCACHE;
