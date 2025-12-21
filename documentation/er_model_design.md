# PHASE III: Logical Model Design
## Smart Blood Inventory Management & Shortage Prediction System

**Project:** Blood Inventory Management  
**Student:** [Your Name] | ID: [Your ID]  
**Date:** December 21, 2025  
**Normalization Level:** Third Normal Form (3NF)

---

## 1. ENTITY-RELATIONSHIP MODEL

### 1.1 ER Diagram Structure Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     ER DIAGRAM LAYOUT                        │
│                                                              │
│                    ┌──────────┐                             │
│                    │  DONORS  │                             │
│                    └─────┬────┘                             │
│                          │ 1                                │
│                          │                                  │
│                          │ donates                          │
│                          │                                  │
│                          │ M                                │
│                    ┌─────▼─────────┐                        │
│                    │ BLOOD_UNITS   │                        │
│                    └─────┬─────────┘                        │
│                          │ 1                                │
│                          │                                  │
│                     ┌────┼────┐                             │
│                     │    │    │                             │
│                  M  │ M  │    │ 1                           │
│            ┌────────▼┐   │    └──────────┐                 │
│            │INVENTORY│   │               │                 │
│            └─────────┘   │         ┌─────▼──────┐          │
│                          │         │TRANSFUSIONS│          │
│                          │         └─────┬──────┘          │
│                          │ M             │ M                │
│                    ┌─────▼─────┐         │                 │
│                    │  PATIENTS │◄────────┘                 │
│                    └───────────┘         1                  │
│                                                              │
│            ┌─────────────────┐    ┌──────────────┐         │
│            │SHORTAGE         │    │ AUDIT_LOGS   │         │
│            │PREDICTIONS (BI) │    │ (Security)   │         │
│            └─────────────────┘    └──────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. ENTITY DEFINITIONS

### ENTITY 1: DONORS

**Purpose:** Store information about blood donors

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| donor_id | NUMBER(10) | PK, NOT NULL | Unique donor identifier |
| first_name | VARCHAR2(50) | NOT NULL | Donor first name |
| last_name | VARCHAR2(50) | NOT NULL | Donor last name |
| blood_type | VARCHAR2(3) | NOT NULL, CHECK | ABO blood type (O+, A+, B+, AB+, O-, A-, B-, AB-) |
| date_of_birth | DATE | NOT NULL | Donor birth date |
| gender | CHAR(1) | NOT NULL, CHECK | Gender (M/F) |
| contact_number | VARCHAR2(15) | NOT NULL, UNIQUE | Phone number |
| email | VARCHAR2(100) | UNIQUE | Email address |
| address | VARCHAR2(200) | NOT NULL | Physical address |
| registration_date | DATE | DEFAULT SYSDATE | When donor registered |
| last_donation_date | DATE | | Most recent donation |
| total_donations | NUMBER(5) | DEFAULT 0 | Lifetime donation count |
| status | VARCHAR2(10) | DEFAULT 'ACTIVE' | ACTIVE, DEFERRED, INACTIVE |

**Primary Key:** donor_id  
**Unique Constraints:** contact_number, email  
**Check Constraints:** 
- blood_type IN ('O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-')
- gender IN ('M', 'F')
- status IN ('ACTIVE', 'DEFERRED', 'INACTIVE')

**Business Rules:**
- Minimum age: 18 years (calculated from date_of_birth)
- Donation frequency: Max 4 times/year (males), 3 times/year (females)
- Minimum 90 days between donations

---

### ENTITY 2: BLOOD_UNITS

**Purpose:** Track individual blood collection units

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| unit_id | NUMBER(10) | PK, NOT NULL | Unique unit identifier |
| donor_id | NUMBER(10) | FK, NOT NULL | Reference to DONORS |
| blood_type | VARCHAR2(3) | NOT NULL, CHECK | ABO blood type |
| collection_date | DATE | NOT NULL | When blood was collected |
| expiry_date | DATE | NOT NULL | Expiration date (42 days from collection) |
| volume_ml | NUMBER(5) | DEFAULT 450 | Volume in milliliters |
| status | VARCHAR2(15) | NOT NULL, CHECK | COLLECTED, TESTING, AVAILABLE, RESERVED, USED, EXPIRED, QUARANTINE |
| test_results | VARCHAR2(20) | CHECK | PASSED, FAILED, PENDING |
| test_date | DATE | | When tests completed |
| location_code | VARCHAR2(20) | | Storage location |
| notes | VARCHAR2(500) | | Additional information |

**Primary Key:** unit_id  
**Foreign Keys:** 
- donor_id REFERENCES donors(donor_id) ON DELETE CASCADE

**Check Constraints:**
- blood_type IN ('O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-')
- status IN ('COLLECTED', 'TESTING', 'AVAILABLE', 'RESERVED', 'USED', 'EXPIRED', 'QUARANTINE')
- test_results IN ('PASSED', 'FAILED', 'PENDING')
- volume_ml BETWEEN 400 AND 500
- expiry_date > collection_date

**Business Rules:**
- Expiry date automatically set to collection_date + 42 days
- Status transitions: COLLECTED → TESTING → AVAILABLE/QUARANTINE → RESERVED → USED
- Cannot be AVAILABLE unless test_results = 'PASSED'

---

### ENTITY 3: INVENTORY

**Purpose:** Track storage and monitoring of blood units

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| inventory_id | NUMBER(10) | PK, NOT NULL | Unique inventory record ID |
| unit_id | NUMBER(10) | FK, NOT NULL, UNIQUE | Reference to BLOOD_UNITS |
| blood_type | VARCHAR2(3) | NOT NULL | Blood type (denormalized for queries) |
| storage_section | VARCHAR2(20) | | Refrigerator section (A1, A2, B1, etc.) |
| temperature_monitor | NUMBER(4,1) | CHECK | Temperature in Celsius |
| last_checked_date | DATE | | Last quality check date |
| checked_by | VARCHAR2(50) | | Staff who checked |
| notes | VARCHAR2(200) | | Monitoring notes |

**Primary Key:** inventory_id  
**Foreign Keys:**
- unit_id REFERENCES blood_units(unit_id) ON DELETE CASCADE

**Unique Constraints:** unit_id (one inventory record per unit)  
**Check Constraints:**
- temperature_monitor BETWEEN 2.0 AND 6.0 (FDA requirement)

**Business Rules:**
- Temperature must be checked every 4 hours
- Alert if temperature outside 2-6°C range
- Only AVAILABLE or RESERVED units should be in inventory

---

### ENTITY 4: PATIENTS

**Purpose:** Store patient information for transfusion tracking

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| patient_id | NUMBER(10) | PK, NOT NULL | Unique patient identifier |
| first_name | VARCHAR2(50) | NOT NULL | Patient first name |
| last_name | VARCHAR2(50) | NOT NULL | Patient last name |
| blood_type | VARCHAR2(3) | NOT NULL, CHECK | ABO blood type |
| date_of_birth | DATE | NOT NULL | Patient birth date |
| gender | CHAR(1) | NOT NULL, CHECK | Gender (M/F) |
| hospital_id | VARCHAR2(20) | | Hospital patient ID |
| registration_date | DATE | DEFAULT SYSDATE | When registered in system |

**Primary Key:** patient_id  
**Check Constraints:**
- blood_type IN ('O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-')
- gender IN ('M', 'F')

**Business Rules:**
- Patient blood type must be verified before transfusion
- Cross-matching required for all transfusions

---

### ENTITY 5: TRANSFUSIONS

**Purpose:** Record blood transfusion transactions

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| transfusion_id | NUMBER(10) | PK, NOT NULL | Unique transfusion ID |
| patient_id | NUMBER(10) | FK, NOT NULL | Reference to PATIENTS |
| unit_id | NUMBER(10) | FK, NOT NULL | Reference to BLOOD_UNITS |
| transfusion_date | TIMESTAMP | NOT NULL | When transfusion occurred |
| doctor_name | VARCHAR2(100) | NOT NULL | Prescribing physician |
| hospital_ward | VARCHAR2(50) | | Ward/department |
| indication | VARCHAR2(200) | | Medical reason |
| cross_match_result | VARCHAR2(20) | CHECK | COMPATIBLE, INCOMPATIBLE |
| adverse_reaction | VARCHAR2(500) | | Any reactions noted |
| performed_by | VARCHAR2(100) | | Staff who performed transfusion |

**Primary Key:** transfusion_id  
**Foreign Keys:**
- patient_id REFERENCES patients(patient_id) ON DELETE RESTRICT
- unit_id REFERENCES blood_units(unit_id) ON DELETE RESTRICT

**Check Constraints:**
- cross_match_result IN ('COMPATIBLE', 'INCOMPATIBLE')

**Business Rules:**
- Cannot transfuse unless cross_match_result = 'COMPATIBLE'
- Blood unit status must be RESERVED before transfusion
- After transfusion, unit status changes to USED

---

### ENTITY 6: SHORTAGE_PREDICTIONS (BI Table)

**Purpose:** Store predictive analytics for shortage prevention

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| prediction_id | NUMBER(10) | PK, NOT NULL | Unique prediction ID |
| blood_type | VARCHAR2(3) | NOT NULL, CHECK | Blood type predicted |
| prediction_date | DATE | NOT NULL | When prediction made |
| predicted_shortage_date | DATE | NOT NULL | Expected shortage date |
| current_stock_level | NUMBER(5) | NOT NULL | Stock at prediction time |
| predicted_demand | NUMBER(5) | NOT NULL | Expected usage |
| confidence_score | NUMBER(3,2) | CHECK | Prediction confidence (0-1) |
| recommendation | VARCHAR2(500) | | Suggested action |
| actual_shortage | CHAR(1) | CHECK | Did shortage occur? (Y/N) |
| model_version | VARCHAR2(20) | | ML model version used |

**Primary Key:** prediction_id  
**Check Constraints:**
- blood_type IN ('O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-')
- confidence_score BETWEEN 0 AND 1
- actual_shortage IN ('Y', 'N')
- predicted_shortage_date > prediction_date

**Business Rules:**
- Predictions generated daily at 6:00 AM
- Confidence score ≥ 0.75 triggers alerts
- Model accuracy tracked monthly for retraining

---

### ENTITY 7: AUDIT_LOGS (Security Table)

**Purpose:** Comprehensive audit trail for all operations

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| audit_id | NUMBER | PK, NOT NULL | Unique audit record ID |
| table_name | VARCHAR2(50) | NOT NULL | Table affected |
| operation_type | VARCHAR2(10) | NOT NULL, CHECK | INSERT, UPDATE, DELETE |
| operation_status | VARCHAR2(10) | NOT NULL, CHECK | ALLOWED, DENIED |
| record_id | NUMBER | | ID of affected record |
| old_values | CLOB | | Before values (UPDATE/DELETE) |
| new_values | CLOB | | After values (INSERT/UPDATE) |
| denial_reason | VARCHAR2(500) | | Why operation denied |
| database_user | VARCHAR2(50) | NOT NULL | Oracle user |
| os_user | VARCHAR2(50) | | Operating system user |
| host_name | VARCHAR2(100) | | Client machine |
| ip_address | VARCHAR2(50) | | Client IP |
| session_id | NUMBER | | Oracle session ID |
| operation_date | TIMESTAMP | DEFAULT SYSTIMESTAMP | When operation occurred |
| day_of_week | VARCHAR2(10) | | Day name |
| is_holiday | CHAR(1) | CHECK | Is public holiday? (Y/N) |
| holiday_name | VARCHAR2(100) | | Holiday name if applicable |

**Primary Key:** audit_id  
**Check Constraints:**
- operation_type IN ('INSERT', 'UPDATE', 'DELETE')
- operation_status IN ('ALLOWED', 'DENIED')
- is_holiday IN ('Y', 'N')

**Business Rules:**
- All DML operations must be logged
- Audit records never deleted (compliance requirement)
- Weekday/holiday restriction logic enforced

---

### ENTITY 8: HOLIDAYS (Reference Table)

**Purpose:** Store public holidays for restriction logic

**Attributes:**
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| holiday_id | NUMBER(10) | PK, NOT NULL | Unique holiday ID |
| holiday_name | VARCHAR2(100) | NOT NULL | Holiday name |
| holiday_date | DATE | NOT NULL, UNIQUE | Date of holiday |
| is_recurring | CHAR(1) | CHECK | Repeats annually? (Y/N) |
| country | VARCHAR2(50) | DEFAULT 'Rwanda' | Country |

**Primary Key:** holiday_id  
**Unique Constraints:** holiday_date  
**Check Constraints:**
- is_recurring IN ('Y', 'N')

**Business Rules:**
- System automatically checks holidays before allowing operations
- Upcoming month's holidays loaded in advance

---

## 3. RELATIONSHIP DEFINITIONS

### Relationship 1: DONORS to BLOOD_UNITS
- **Cardinality:** One-to-Many (1:M)
- **Description:** One donor can donate multiple blood units over time
- **Implementation:** Foreign key donor_id in BLOOD_UNITS table
- **Business Rule:** A donor can donate maximum 4 times per year (males) or 3 times (females)

### Relationship 2: BLOOD_UNITS to INVENTORY
- **Cardinality:** One-to-One (1:1)
- **Description:** Each blood unit has one inventory record for storage tracking
- **Implementation:** Foreign key unit_id in INVENTORY table with UNIQUE constraint
- **Business Rule:** Only AVAILABLE or RESERVED units stored in inventory

### Relationship 3: BLOOD_UNITS to TRANSFUSIONS
- **Cardinality:** One-to-One (1:1)
- **Description:** Each blood unit can be transfused to one patient
- **Implementation:** Foreign key unit_id in TRANSFUSIONS table
- **Business Rule:** Unit cannot be reused after transfusion

### Relationship 4: PATIENTS to TRANSFUSIONS
- **Cardinality:** One-to-Many (1:M)
- **Description:** One patient can receive multiple transfusions
- **Implementation:** Foreign key patient_id in TRANSFUSIONS table
- **Business Rule:** Blood type compatibility must be verified

---

## 4. CARDINALITY NOTATION

```
DONORS (1) ──────< BLOOD_UNITS (M)
   │
   │ "A donor can give multiple donations"
   │ "Each donation is from one donor"

BLOOD_UNITS (1) ──────── INVENTORY (1)
   │
   │ "Each unit has one inventory record"
   │ "Each inventory record tracks one unit"

BLOOD_UNITS (1) ──────── TRANSFUSIONS (1)
   │
   │ "Each unit used in one transfusion"
   │ "Each transfusion uses one unit"

PATIENTS (1) ──────< TRANSFUSIONS (M)
   │
   │ "A patient can receive multiple transfusions"
   │ "Each transfusion is for one patient"
```

---

## 5. CONSTRAINTS SUMMARY

### Primary Key Constraints
- PK_DONORS: donor_id
- PK_BLOOD_UNITS: unit_id
- PK_INVENTORY: inventory_id
- PK_PATIENTS: patient_id
- PK_TRANSFUSIONS: transfusion_id
- PK_SHORTAGE_PREDICTIONS: prediction_id
- PK_AUDIT_LOGS: audit_id
- PK_HOLIDAYS: holiday_id

### Foreign Key Constraints
- FK_BLOOD_DONOR: blood_units.donor_id → donors.donor_id
- FK_INV_UNIT: inventory.unit_id → blood_units.unit_id
- FK_TRANS_PATIENT: transfusions.patient_id → patients.patient_id
- FK_TRANS_UNIT: transfusions.unit_id → blood_units.unit_id

### Unique Constraints
- UQ_DONOR_CONTACT: donors.contact_number
- UQ_DONOR_EMAIL: donors.email
- UQ_INV_UNIT: inventory.unit_id
- UQ_HOLIDAY_DATE: holidays.holiday_date

### Check Constraints
- CHK_BLOOD_TYPE: blood_type IN ('O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-')
- CHK_GENDER: gender IN ('M', 'F')
- CHK_UNIT_STATUS: status IN ('COLLECTED', 'TESTING', 'AVAILABLE', ...)
- CHK_TEMPERATURE: temperature_monitor BETWEEN 2.0 AND 6.0
- CHK_CONFIDENCE: confidence_score BETWEEN 0 AND 1

### NOT NULL Constraints
All primary keys and critical business fields (names, dates, blood types)

---

## 6. ER DIAGRAM CREATION GUIDE

### For Lucidchart/Draw.io:

**Entities (Rectangles):**
```
┌─────────────────────┐
│      DONORS         │
├─────────────────────┤
│ PK: donor_id        │
│     first_name      │
│     last_name       │
│     blood_type      │
│     ...             │
└─────────────────────┘
```

**Relationships (Diamonds):**
```
       donates
      ◇────────
```

**Cardinality Notation:**
- Use crow's foot notation
- (1) = one line
- (M) = crow's foot (three lines)

**Color Coding:**
- Core Entities (Blue): DONORS, BLOOD_UNITS, PATIENTS, TRANSFUSIONS
- Supporting Entities (Green): INVENTORY
- BI/Analytics (Purple): SHORTAGE_PREDICTIONS
- Security (Red): AUDIT_LOGS, HOLIDAYS

---

**Document Version:** 1.0  
**Last Updated:** December 21, 2025