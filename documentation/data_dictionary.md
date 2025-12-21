# Data Dictionary
## Smart Blood Inventory Management System

---

## Table of Contents
1. [DONORS Table](#1-donors-table)
2. [BLOOD_UNITS Table](#2-blood_units-table)
3. [INVENTORY Table](#3-inventory-table)
4. [PATIENTS Table](#4-patients-table)
5. [TRANSFUSIONS Table](#5-transfusions-table)
6. [SHORTAGE_PREDICTIONS Table](#6-shortage_predictions-table)
7. [PUBLIC_HOLIDAYS Table](#7-public_holidays-table)
8. [AUDIT_LOGS Table](#8-audit_logs-table)
9. [Sequences](#9-sequences)
10. [Indexes](#10-indexes)

---

## 1. DONORS Table

**Purpose:** Stores comprehensive information about blood donors including contact details, blood type, and demographic data.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| DONOR_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each donor | 1001 |
| FIRST_NAME | VARCHAR2(50) | NOT NULL | Donor's first name | John |
| LAST_NAME | VARCHAR2(50) | NOT NULL | Donor's last name | Smith |
| BLOOD_TYPE | VARCHAR2(3) | NOT NULL, CHECK | Blood type (O+, O-, A+, A-, B+, B-, AB+, AB-) | O+ |
| DATE_OF_BIRTH | DATE | NOT NULL | Donor's date of birth | 1990-05-15 |
| GENDER | CHAR(1) | NOT NULL, CHECK | Gender (M/F) | M |
| CONTACT_NUMBER | VARCHAR2(20) | NOT NULL, UNIQUE | Primary contact phone number | +250788123456 |
| EMAIL | VARCHAR2(100) | UNIQUE | Email address | john.smith@email.com |
| ADDRESS | VARCHAR2(200) | NULL | Physical address | Kigali, Rwanda |

**Constraints:**
- `PK_DONORS`: Primary Key on DONOR_ID
- `UK_DONOR_CONTACT`: Unique constraint on CONTACT_NUMBER
- `UK_DONOR_EMAIL`: Unique constraint on EMAIL
- `CHK_BLOOD_TYPE`: CHECK (BLOOD_TYPE IN ('O+','O-','A+','A-','B+','B-','AB+','AB-'))
- `CHK_GENDER`: CHECK (GENDER IN ('M','F'))

**Relationships:**
- One-to-Many with BLOOD_UNITS (One donor can donate multiple blood units)

**Indexes:**
- Primary Key index on DONOR_ID
- Index on BLOOD_TYPE for filtering
- Index on EMAIL for lookups

**Business Rules:**
- Donor age must be between 18 and 65 years (enforced in procedure)
- Contact number must be unique
- Email must be unique if provided

---

## 2. BLOOD_UNITS Table

**Purpose:** Tracks individual blood units from collection through transfusion or disposal, including status and test results.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| UNIT_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each blood unit | 5001 |
| DONOR_ID | NUMBER(10) | FK, NOT NULL | References donor who provided this unit | 1001 |
| BLOOD_TYPE | VARCHAR2(3) | NOT NULL, CHECK | Blood type of this unit | O+ |
| COLLECTION_DATE | DATE | NOT NULL | Date blood was collected | 2025-12-01 |
| EXPIRY_DATE | DATE | NOT NULL | Expiration date (typically 42 days after collection) | 2026-01-12 |
| STATUS | VARCHAR2(20) | NOT NULL, CHECK | Current status of the blood unit | AVAILABLE |
| TEST_RESULTS | VARCHAR2(20) | NOT NULL | Result of blood screening tests | PASSED |

**Constraints:**
- `PK_BLOOD_UNITS`: Primary Key on UNIT_ID
- `FK_DONOR`: Foreign Key to DONORS(DONOR_ID)
- `CHK_STATUS`: CHECK (STATUS IN ('AVAILABLE','IN_USE','EXPIRED','DISCARDED'))
- `CHK_TEST_RESULTS`: CHECK (TEST_RESULTS IN ('PASSED','FAILED','CONTAMINATED','PENDING'))
- `CHK_EXPIRY`: CHECK (EXPIRY_DATE > COLLECTION_DATE)

**Relationships:**
- Many-to-One with DONORS (Multiple units per donor)
- One-to-One with TRANSFUSIONS (Each unit used once)

**Indexes:**
- Primary Key index on UNIT_ID
- Foreign Key index on DONOR_ID
- Index on BLOOD_TYPE for inventory queries
- Index on STATUS for availability checks
- Index on EXPIRY_DATE for expiry monitoring

**Business Rules:**
- Blood units expire 42 days after collection
- Only AVAILABLE units can be used for transfusion
- FAILED or CONTAMINATED units must be DISCARDED
- Status changes tracked in audit logs

**Valid Status Transitions:**
```
AVAILABLE → IN_USE (during transfusion)
AVAILABLE → EXPIRED (past expiry date)
AVAILABLE → DISCARDED (failed tests)
IN_USE → Cannot change (transfusion complete)
EXPIRED → Cannot change back to AVAILABLE
DISCARDED → Cannot change back to AVAILABLE
```

---

## 3. INVENTORY Table

**Purpose:** Maintains real-time aggregated counts of blood units by type and location for quick inventory queries.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| INVENTORY_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for inventory record | 101 |
| BLOOD_TYPE | VARCHAR2(3) | NOT NULL, UNIQUE, CHECK | Blood type being tracked | O+ |
| AVAILABLE_UNITS | NUMBER(10) | NOT NULL, DEFAULT 0 | Count of available units | 45 |
| RESERVED_UNITS | NUMBER(10) | NOT NULL, DEFAULT 0 | Count of reserved units | 5 |
| IN_USE_UNITS | NUMBER(10) | NOT NULL, DEFAULT 0 | Count of units being used | 3 |
| EXPIRED_UNITS | NUMBER(10) | NOT NULL, DEFAULT 0 | Count of expired units | 12 |
| LAST_UPDATED | TIMESTAMP | NOT NULL, DEFAULT SYSTIMESTAMP | Last update timestamp | 2025-12-21 10:30:00 |

**Constraints:**
- `PK_INVENTORY`: Primary Key on INVENTORY_ID
- `UK_BLOOD_TYPE`: Unique constraint on BLOOD_TYPE
- `CHK_BLOOD_TYPE_INV`: CHECK (BLOOD_TYPE IN ('O+','O-','A+','A-','B+','B-','AB+','AB-'))
- `CHK_NON_NEGATIVE`: CHECK (AVAILABLE_UNITS >= 0 AND RESERVED_UNITS >= 0)

**Relationships:**
- No direct foreign keys (aggregated data from BLOOD_UNITS)

**Indexes:**
- Primary Key index on INVENTORY_ID
- Unique index on BLOOD_TYPE

**Business Rules:**
- Updated automatically via triggers or scheduled jobs
- Available units = COUNT(BLOOD_UNITS WHERE STATUS='AVAILABLE')
- Critical level: AVAILABLE_UNITS < 20 for common types

---

## 4. PATIENTS Table

**Purpose:** Stores patient information for individuals requiring blood transfusions.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| PATIENT_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each patient | 2001 |
| FIRST_NAME | VARCHAR2(50) | NOT NULL | Patient's first name | Alice |
| LAST_NAME | VARCHAR2(50) | NOT NULL | Patient's last name | Brown |
| BLOOD_TYPE | VARCHAR2(3) | NOT NULL, CHECK | Patient's blood type | A+ |
| DATE_OF_BIRTH | DATE | NOT NULL | Patient's date of birth | 1978-11-30 |
| GENDER | CHAR(1) | NOT NULL, CHECK | Gender (M/F) | F |

**Constraints:**
- `PK_PATIENTS`: Primary Key on PATIENT_ID
- `CHK_BLOOD_TYPE_PAT`: CHECK (BLOOD_TYPE IN ('O+','O-','A+','A-','B+','B-','AB+','AB-'))
- `CHK_GENDER_PAT`: CHECK (GENDER IN ('M','F'))

**Relationships:**
- One-to-Many with TRANSFUSIONS (One patient can receive multiple transfusions)

**Indexes:**
- Primary Key index on PATIENT_ID
- Index on BLOOD_TYPE for compatibility matching

**Business Rules:**
- Blood type must be compatible with donor blood type
- Patient information protected by HIPAA-equivalent privacy rules

---

## 5. TRANSFUSIONS Table

**Purpose:** Records all blood transfusion transactions linking patients with blood units.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| TRANSFUSION_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each transfusion | 3001 |
| PATIENT_ID | NUMBER(10) | FK, NOT NULL | Patient receiving the transfusion | 2001 |
| UNIT_ID | NUMBER(10) | FK, NOT NULL, UNIQUE | Blood unit being transfused | 5001 |
| TRANSFUSION_DATE | DATE | NOT NULL, DEFAULT SYSDATE | Date and time of transfusion | 2025-12-19 |
| DOCTOR_NAME | VARCHAR2(100) | NOT NULL | Name of supervising physician | Dr. James Wilson |
| HOSPITAL_WARD | VARCHAR2(50) | NOT NULL | Hospital ward where transfusion occurred | EMERGENCY |

**Constraints:**
- `PK_TRANSFUSIONS`: Primary Key on TRANSFUSION_ID
- `FK_PATIENT`: Foreign Key to PATIENTS(PATIENT_ID)
- `FK_UNIT`: Foreign Key to BLOOD_UNITS(UNIT_ID)
- `UK_UNIT_ID`: Unique constraint on UNIT_ID (one unit used once)

**Relationships:**
- Many-to-One with PATIENTS (Multiple transfusions per patient)
- One-to-One with BLOOD_UNITS (Each unit used once)

**Indexes:**
- Primary Key index on TRANSFUSION_ID
- Foreign Key index on PATIENT_ID
- Foreign Key index on UNIT_ID
- Index on TRANSFUSION_DATE for reporting

**Business Rules:**
- Blood compatibility verified before transfusion (by function)
- Unit status must be AVAILABLE before transfusion
- Unit status changed to IN_USE after transfusion
- Complete audit trail maintained

**Valid Hospital Wards:**
- EMERGENCY
- ICU
- SURGERY
- MATERNITY
- PEDIATRICS
- ONCOLOGY

---

## 6. SHORTAGE_PREDICTIONS Table

**Purpose:** Stores AI/BI-generated predictions for blood shortage forecasting.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| PREDICTION_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each prediction | 401 |
| BLOOD_TYPE | VARCHAR2(3) | NOT NULL, CHECK | Blood type being predicted | O+ |
| PREDICTION_DATE | DATE | NOT NULL | Date prediction was generated | 2025-12-21 |
| PREDICTED_SHORTAGE_DATE | DATE | NULL | Estimated date of shortage | 2025-12-28 |
| CURRENT_STOCK | NUMBER(10) | NOT NULL | Current inventory level | 35 |
| PREDICTED_DEMAND | NUMBER(10) | NOT NULL | Forecasted demand | 50 |
| RISK_LEVEL | VARCHAR2(20) | NOT NULL, CHECK | Risk severity | CRITICAL |
| RECOMMENDATION | VARCHAR2(500) | NULL | Suggested actions | Urgent: Schedule 15+ donors |

**Constraints:**
- `PK_SHORTAGE_PRED`: Primary Key on PREDICTION_ID
- `CHK_BLOOD_TYPE_PRED`: CHECK (BLOOD_TYPE IN ('O+','O-','A+','A-','B+','B-','AB+','AB-'))
- `CHK_RISK_LEVEL`: CHECK (RISK_LEVEL IN ('CRITICAL','HIGH','MEDIUM','LOW','ADEQUATE'))

**Relationships:**
- No direct foreign keys (analytical/reporting table)

**Indexes:**
- Primary Key index on PREDICTION_ID
- Index on BLOOD_TYPE
- Index on PREDICTION_DATE

**Business Rules:**
- Predictions generated weekly via scheduled job
- Risk levels based on supply/demand ratio:
  - CRITICAL: Stock < 50% of weekly demand
  - HIGH: Stock < 100% of weekly demand
  - MEDIUM: Stock < 150% of weekly demand
  - LOW: Stock < 200% of weekly demand
  - ADEQUATE: Stock > 200% of weekly demand

---

## 7. PUBLIC_HOLIDAYS Table

**Purpose:** Stores public holidays for Rwanda to enforce DML operation restrictions.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| HOLIDAY_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each holiday | 1 |
| HOLIDAY_NAME | VARCHAR2(100) | NOT NULL | Name of the holiday | Independence Day |
| HOLIDAY_DATE | DATE | NOT NULL | Date of the holiday | 2025-07-01 |
| COUNTRY | VARCHAR2(50) | DEFAULT 'Rwanda' | Country for the holiday | Rwanda |
| IS_ACTIVE | CHAR(1) | DEFAULT 'Y', CHECK | Whether holiday is active | Y |
| CREATED_DATE | DATE | DEFAULT SYSDATE | When holiday was added | 2025-11-15 |

**Constraints:**
- `PK_HOLIDAYS`: Primary Key on HOLIDAY_ID
- `UK_HOLIDAY_DATE`: Unique constraint on (HOLIDAY_DATE, COUNTRY)
- `CHK_IS_ACTIVE`: CHECK (IS_ACTIVE IN ('Y','N'))

**Relationships:**
- No foreign keys (reference table)

**Indexes:**
- Primary Key index on HOLIDAY_ID
- Unique index on (HOLIDAY_DATE, COUNTRY)

**Business Rules:**
- DML operations blocked on active holidays (IS_ACTIVE = 'Y')
- Only checks holidays within upcoming month
- System administrators can add/deactivate holidays

**Rwanda Public Holidays:**
- New Year's Day (Jan 1)
- Genocide Memorial Day (Apr 7)
- Labour Day (May 1)
- Independence Day (Jul 1)
- Liberation Day (Jul 4)
- Umuganura Day (Aug 2)
- Christmas Day (Dec 25)
- Boxing Day (Dec 26)

---

## 8. AUDIT_LOGS Table

**Purpose:** Comprehensive audit trail capturing all DML operations, access attempts, and system events.

**Tablespace:** BLOOD_DATA

| Column Name | Data Type | Constraints | Purpose | Sample Value |
|------------|-----------|-------------|---------|--------------|
| AUDIT_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for each audit entry | 10001 |
| TABLE_NAME | VARCHAR2(50) | NOT NULL | Table being accessed | DONORS |
| OPERATION_TYPE | VARCHAR2(10) | NOT NULL, CHECK | Type of operation | INSERT |
| OPERATION_STATUS | VARCHAR2(10) | NOT NULL, CHECK | Whether operation was allowed | DENIED |
| RECORD_ID | NUMBER(10) | NULL | ID of affected record | 1001 |
| OLD_VALUES | CLOB | NULL | Previous values (for UPDATE/DELETE) | Name: John Smith, Blood: O+ |
| NEW_VALUES | CLOB | NULL | New values (for INSERT/UPDATE) | Name: John Doe, Blood: O+ |
| DENIAL_REASON | VARCHAR2(500) | NULL | Reason if operation was denied | Operation denied: Weekday (MON) |
| DATABASE_USER | VARCHAR2(50) | DEFAULT USER | Oracle database username | BLOOD_ADMIN |
| OS_USER | VARCHAR2(50) | NULL | Operating system username | jsmith |
| HOST_NAME | VARCHAR2(100) | NULL | Client hostname | WORKSTATION-01 |
| IP_ADDRESS | VARCHAR2(50) | NULL | Client IP address | 192.168.1.100 |
| SESSION_ID | NUMBER | NULL | Oracle session identifier | 12345 |
| OPERATION_DATE | TIMESTAMP | DEFAULT SYSTIMESTAMP | Timestamp of operation | 2025-12-21 14:30:15.123 |
| DAY_OF_WEEK | VARCHAR2(10) | NULL | Day of week | MON |
| IS_HOLIDAY | CHAR(1) | DEFAULT 'N' | Whether day was a holiday | N |
| HOLIDAY_NAME | VARCHAR2(100) | NULL | Name of holiday if applicable | NULL |

**Constraints:**
- `PK_AUDIT_LOGS`: Primary Key on AUDIT_ID
- `CHK_OPERATION_TYPE`: CHECK (OPERATION_TYPE IN ('INSERT','UPDATE','DELETE'))
- `CHK_OPERATION_STATUS`: CHECK (OPERATION_STATUS IN ('ALLOWED','DENIED'))

**Relationships:**
- No foreign keys (audit/logging table)

**Indexes:**
- Primary Key index on AUDIT_ID
- Index on OPERATION_DATE for time-based queries
- Index on TABLE_NAME for filtering
- Index on OPERATION_STATUS for denied operation reports

**Business Rules:**
- Every DML operation logged (successful or denied)
- Retention period: 2 years minimum
- Cannot be modified (insert-only table)
- Logged via autonomous transaction
- Used for compliance and security audits

---

## 9. Sequences

| Sequence Name | Start Value | Increment | Cache | Purpose |
|--------------|-------------|-----------|-------|---------|
| SEQ_DONORS | 1 | 1 | NOCACHE | Generate DONOR_ID |
| SEQ_BLOOD_UNITS | 1 | 1 | NOCACHE | Generate UNIT_ID |
| SEQ_INVENTORY | 1 | 1 | NOCACHE | Generate INVENTORY_ID |
| SEQ_PATIENTS | 1 | 1 | NOCACHE | Generate PATIENT_ID |
| SEQ_TRANSFUSIONS | 1 | 1 | NOCACHE | Generate TRANSFUSION_ID |
| SEQ_SHORTAGE_PRED | 1 | 1 | NOCACHE | Generate PREDICTION_ID |
| SEQ_HOLIDAYS | 1 | 1 | NOCACHE | Generate HOLIDAY_ID |
| SEQ_AUDIT_LOGS | 1 | 1 | NOCACHE | Generate AUDIT_ID |

**Usage Example:**
```sql
INSERT INTO donors VALUES (seq_donors.NEXTVAL, ...);
```

---

## 10. Indexes

### Primary Key Indexes (Automatic)
- `PK_DONORS` on DONORS(DONOR_ID)
- `PK_BLOOD_UNITS` on BLOOD_UNITS(UNIT_ID)
- `PK_INVENTORY` on INVENTORY(INVENTORY_ID)
- `PK_PATIENTS` on PATIENTS(PATIENT_ID)
- `PK_TRANSFUSIONS` on TRANSFUSIONS(TRANSFUSION_ID)
- `PK_SHORTAGE_PRED` on SHORTAGE_PREDICTIONS(PREDICTION_ID)
- `PK_HOLIDAYS` on PUBLIC_HOLIDAYS(HOLIDAY_ID)
- `PK_AUDIT_LOGS` on AUDIT_LOGS(AUDIT_ID)

### Foreign Key Indexes
- `IDX_BLOOD_UNITS_DONOR` on BLOOD_UNITS(DONOR_ID)
- `IDX_TRANSFUSIONS_PATIENT` on TRANSFUSIONS(PATIENT_ID)
- `IDX_TRANSFUSIONS_UNIT` on TRANSFUSIONS(UNIT_ID)

### Performance Indexes
- `IDX_BLOOD_TYPE_DONORS` on DONORS(BLOOD_TYPE)
- `IDX_BLOOD_TYPE_UNITS` on BLOOD_UNITS(BLOOD_TYPE)
- `IDX_STATUS_UNITS` on BLOOD_UNITS(STATUS)
- `IDX_EXPIRY_DATE` on BLOOD_UNITS(EXPIRY_DATE)
- `IDX_AUDIT_DATE` on AUDIT_LOGS(OPERATION_DATE)
- `IDX_AUDIT_TABLE` on AUDIT_LOGS(TABLE_NAME)
- `IDX_AUDIT_STATUS` on AUDIT_LOGS(OPERATION_STATUS)

**Tablespace:** BLOOD_INDEXES

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 8 |
| Total Columns | 68 |
| Total Indexes | 23 |
| Total Sequences | 8 |
| Total Constraints | 40+ |
| Sample Data Records | 1,000+ |
| Estimated Size | 150MB |
