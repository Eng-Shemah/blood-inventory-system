# Smart Blood Inventory Management & Shortage Prediction System

## Project Overview

A comprehensive PL/SQL-based healthcare database system designed to manage blood donations, track inventory levels, monitor expiry dates, and predict upcoming shortages using business intelligence. The system analyzes transfusion trends, donation patterns, and stock usage to help hospitals optimize blood availability and reduce waste.

---

## Student Information

- **Student Name:** SHEMA Gwiza Robert
- **Student ID:** 27949
- **Course:** Database Development with PL/SQL (INSY 8311)
- **Institution:** Adventist University of Central Africa (AUCA)
- **Lecturer:** Eric Maniraguha
- **Academic Year:** 2025-2026 | Semester I
- **Project Completion Date:** December 21, 2025

---

## Problem Statement

Blood banks in healthcare facilities face critical challenges in managing inventory effectively, leading to blood shortages during emergencies and wastage due to expiration. Manual tracking systems fail to predict shortages in advance, resulting in delayed patient care and inefficient resource allocation. This system provides real-time inventory monitoring, automated expiry alerts, and predictive analytics to ensure optimal blood availability while minimizing waste.

---

## Key Objectives

1. **Efficient Blood Inventory Management** - Real-time tracking of blood units by type, status, and location
2. **Donor Management** - Comprehensive donor records with donation history and eligibility tracking
3. **Transfusion Tracking** - Complete audit trail of blood transfusions with patient matching
4. **Shortage Prediction** - Intelligent forecasting based on historical usage patterns
5. **Expiry Management** - Automated alerts for units approaching expiration dates
6. **Business Intelligence** - Data-driven insights through analytics dashboards and reports
7. **Regulatory Compliance** - Comprehensive auditing with weekday/holiday restrictions
8. **Blood Compatibility Validation** - Automated verification of donor-patient blood type matching

---

## System Architecture

### Database Components

- **Oracle Pluggable Database (PDB):** `tues_27949_robert_BloodInventory_DB`
- **Total Tables:** 7 main tables + 2 audit/configuration tables
- **Total Records:** 1000+ across all tables
- **PL/SQL Objects:** 20+ procedures, functions, triggers, and packages
- **Views:** 5 analytical views for reporting

### Technology Stack

- **Database:** Oracle 21c
- **Language:** PL/SQL
- **Development Tools:** SQL Developer, SQL*Plus
- **Version Control:** GitHub
- **BI Tools:** Oracle Analytics (SQL-based dashboards)

---

## Database Schema

### Core Tables

1. **DONORS** - Blood donor information and contact details
2. **BLOOD_UNITS** - Individual blood units with collection/expiry dates
3. **INVENTORY** - Real-time stock levels by blood type
4. **PATIENTS** - Patient records requiring transfusions
5. **TRANSFUSIONS** - Complete transfusion transaction history
6. **SHORTAGE_PREDICTIONS** - AI-driven shortage forecasts
7. **PUBLIC_HOLIDAYS** - Holiday calendar for DML restrictions
8. **AUDIT_LOGS** - Comprehensive audit trail of all operations

---

## Quick Start Guide

### Prerequisites

```bash
- Oracle Database 21c
- SQL Developer or SQL*Plus
- Minimum 500MB tablespace
- SYS/SYSTEM privileges for PDB creation
```

### Installation Steps

#### 1. Create Pluggable Database

```sql
-- Connect as SYSDBA
CREATE PLUGGABLE DATABASE [YourPDBName]
  ADMIN USER pdb_admin IDENTIFIED BY YourPassword
  FILE_NAME_CONVERT = ('/path/to/pdbseed/', '/path/to/your/pdb/');

ALTER PLUGGABLE DATABASE [YourPDBName] OPEN;
ALTER PLUGGABLE DATABASE [YourPDBName] SAVE STATE;
```

#### 2. Create Tablespaces

```sql
-- Connect to your PDB
ALTER SESSION SET CONTAINER = [YourPDBName];

-- Create tablespaces
CREATE TABLESPACE blood_data
  DATAFILE '/path/to/blood_data01.dbf' SIZE 200M
  AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;

CREATE TABLESPACE blood_indexes
  DATAFILE '/path/to/blood_indexes01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 25M MAXSIZE UNLIMITED;
```

#### 3. Execute Scripts in Order

```bash
# Clone the repository
git clone https://github.com/[YourUsername]/blood-inventory-system.git
cd blood-inventory-system

# Execute in this order:
1. database/01_create_tables.sql
2. database/02_create_sequences.sql
3. database/03_insert_sample_data.sql
4. database/04_procedures.sql
5. database/05_functions.sql
6. database/06_packages.sql
7. database/07_triggers.sql
8. database/08_views.sql
```

#### 4. Verify Installation

```sql
-- Check table creation
SELECT table_name FROM user_tables ORDER BY table_name;

-- Verify data load
SELECT 
    'DONORS' AS table_name, COUNT(*) AS row_count FROM donors
UNION ALL
SELECT 'BLOOD_UNITS', COUNT(*) FROM blood_units
UNION ALL
SELECT 'PATIENTS', COUNT(*) FROM patients
UNION ALL
SELECT 'TRANSFUSIONS', COUNT(*) FROM transfusions;

-- Test procedures
EXEC pkg_blood_inventory.display_inventory_summary;
```

---

## 📁 Project Structure

```
blood-inventory-system/
├── README.md                          # This file
├── database/
│   ├── ddl/
│   │   ├── 01_create_tables.sql      # Table definitions
│   │   ├── 02_create_sequences.sql   # Sequence objects
│   │   └── 03_create_indexes.sql     # Index definitions
│   ├── dml/
│   │   ├── donors_data.sql           # 200 donor records
│   │   ├── blood_units_data.sql      # 200 blood units
│   │   ├── patients_data.sql         # 200 patient records
│   │   └── transfusions_data.sql     # 200 transfusions
│   ├── plsql/
│   │   ├── procedures/
│   │   │   ├── sp_register_donor.sql
│   │   │   ├── sp_record_donation.sql
│   │   │   ├── sp_update_blood_status.sql
│   │   │   ├── sp_record_transfusion.sql
│   │   │   └── sp_cleanup_expired_units.sql
│   │   ├── functions/
│   │   │   ├── fn_get_inventory_level.sql
│   │   │   ├── fn_check_blood_compatibility.sql
│   │   │   ├── fn_days_until_expiry.sql
│   │   │   ├── fn_get_donor_donation_count.sql
│   │   │   └── fn_get_shortage_risk.sql
│   │   ├── packages/
│   │   │   └── pkg_blood_inventory.sql
│   │   └── triggers/
│   │       ├── trg_donors_restriction.sql
│   │       ├── trg_blood_units_restriction.sql
│   │       ├── trg_patients_restriction.sql
│   │       └── trg_transfusions_restriction.sql
│   └── views/
│       ├── v_audit_summary.sql
│       ├── v_denied_operations.sql
│       └── v_inventory_distribution.sql
├── queries/
│   ├── analytics/
│   │   ├── shortage_analysis.sql
│   │   ├── donation_trends.sql
│   │   └── expiry_report.sql
│   └── reports/
│       ├── daily_inventory.sql
│       └── monthly_summary.sql
├── business_intelligence/
│   ├── dashboards/
│   │   ├── executive_dashboard.md
│   │   ├── inventory_dashboard.md
│   │   └── audit_dashboard.md
│   ├── kpi_definitions.md
│   └── bi_requirements.md
├── documentation/
│   ├── data_dictionary.md            # Complete data dictionary
│   ├── architecture.md               # System architecture
│   ├── design_decisions.md           # Technical decisions
│   └── user_guide.md                 # User manual
├── screenshots/
│   ├── er_diagram.png
│   ├── database_structure.png
│   ├── test_results/
│   └── dashboard_mockups/
└── tests/
    ├── phase_vi_tests.sql            # Procedure/function tests
    └── phase_vii_tests.sql           # Trigger tests
```

---

## Core Functionality

### 1. Donor Management

```sql
-- Register new donor
DECLARE
    v_donor_id NUMBER;
BEGIN
    pkg_blood_inventory.register_donor(
        p_first_name => 'John',
        p_last_name => 'Doe',
        p_blood_type => 'O+',
        p_dob => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        p_gender => 'M',
        p_contact => '+250788123456',
        p_email => 'john.doe@email.com',
        p_address => 'Kigali, Rwanda',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('Donor registered: ' || v_donor_id);
END;
```

### 2. Blood Donation Recording

```sql
-- Record donation
DECLARE
    v_unit_id NUMBER;
BEGIN
    pkg_blood_inventory.record_donation(
        p_donor_id => 101,
        p_unit_id => v_unit_id
    );
    DBMS_OUTPUT.PUT_LINE('Blood unit created: ' || v_unit_id);
END;
```

### 3. Transfusion Processing

```sql
-- Process transfusion
DECLARE
    v_transfusion_id NUMBER;
BEGIN
    pkg_blood_inventory.process_transfusion(
        p_patient_id => 501,
        p_unit_id => 1001,
        p_doctor_name => 'Dr. Smith',
        p_hospital_ward => 'EMERGENCY',
        p_transfusion_id => v_transfusion_id
    );
END;
```

### 4. Inventory Monitoring

```sql
-- Check inventory levels
SELECT 
    blood_type,
    fn_get_inventory_level(blood_type) AS available_units,
    fn_get_shortage_risk(blood_type) AS risk_level
FROM (SELECT DISTINCT blood_type FROM blood_units);
```

---

## Business Intelligence Features

### Key Performance Indicators (KPIs)

1. **Inventory Levels** - Real-time stock by blood type
2. **Shortage Risk Score** - Predictive shortage indicators
3. **Expiry Rate** - Percentage of units expiring before use
4. **Donation Rate** - Donors per day/week/month
5. **Transfusion Volume** - Daily/weekly transfusion trends
6. **Blood Waste** - Expired/discarded unit percentage
7. **Donor Retention** - Repeat donor rate

### Analytics Queries

```sql
-- Top 10 donors
SELECT * FROM (
    SELECT 
        d.donor_id,
        d.first_name || ' ' || d.last_name AS donor_name,
        d.blood_type,
        COUNT(bu.unit_id) AS total_donations,
        RANK() OVER (ORDER BY COUNT(bu.unit_id) DESC) AS rank
    FROM donors d
    JOIN blood_units bu ON d.donor_id = bu.donor_id
    GROUP BY d.donor_id, d.first_name, d.last_name, d.blood_type
)
WHERE rank <= 10;

-- Shortage prediction
SELECT 
    blood_type,
    available_units,
    avg_weekly_usage,
    CASE 
        WHEN available_units < avg_weekly_usage * 0.5 THEN 'CRITICAL'
        WHEN available_units < avg_weekly_usage * 1.5 THEN 'LOW'
        ELSE 'ADEQUATE'
    END AS risk_level
FROM (
    SELECT 
        bu.blood_type,
        COUNT(*) AS available_units,
        (SELECT COUNT(*) / 4 
         FROM transfusions t 
         JOIN blood_units b ON t.unit_id = b.unit_id 
         WHERE b.blood_type = bu.blood_type 
         AND t.transfusion_date >= SYSDATE - 30) AS avg_weekly_usage
    FROM blood_units bu
    WHERE bu.status = 'AVAILABLE'
    AND bu.expiry_date > SYSDATE
    GROUP BY bu.blood_type
);
```

---

## Security & Auditing

### Business Rules Enforced

-  **Weekday Restriction:** DML operations BLOCKED Monday-Friday
-  **Weekend Access:** Operations ALLOWED Saturday-Sunday
-  **Holiday Protection:** Public holidays automatically blocked
-  **Comprehensive Auditing:** All operations logged with user details

### Audit Queries

```sql
-- View denied operations
SELECT * FROM v_denied_operations ORDER BY operation_date DESC;

-- User activity report
SELECT * FROM v_user_activity;

-- Generate audit report
EXEC sp_generate_audit_report(SYSDATE-30, SYSDATE);
```

---

## Sample Queries & Reports

### Daily Inventory Report

```sql
SELECT 
    blood_type,
    SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available,
    SUM(CASE WHEN status = 'IN_USE' THEN 1 ELSE 0 END) AS in_use,
    SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) AS expired,
    SUM(CASE WHEN expiry_date < SYSDATE + 7 THEN 1 ELSE 0 END) AS expiring_soon
FROM blood_units
GROUP BY blood_type
ORDER BY blood_type;
```

### Donor Activity Report

```sql
SELECT 
    TRUNC(collection_date, 'MM') AS month,
    COUNT(DISTINCT donor_id) AS unique_donors,
    COUNT(*) AS total_donations
FROM blood_units
WHERE collection_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TRUNC(collection_date, 'MM')
ORDER BY month DESC;
```

---

## Testing

### Run All Tests

```sql
-- Phase VI: Procedures & Functions
@tests/phase_vi_tests.sql

-- Phase VII: Triggers & Auditing
@tests/phase_vii_tests.sql
```

### Expected Test Results

-  20+ test cases pass
-  All procedures execute without errors
-  All functions return correct values
-  Triggers block weekday operations
-  Audit logs capture all attempts

---

##  Documentation Links

- **[Data Dictionary](documentation/data_dictionary.md)** - Complete table and column definitions
- **[Architecture Guide](documentation/architecture.md)** - System design and structure
- **[User Manual](database/documentation/user_setup.md)** - End-user instructions
- **[Setup Instructions](database/documentation/setup_instructions.md)** - Setup instructions
- **[BI Requirements](business_intelligence/bi_requirements.md)** - Analytics specifications
- **[API Documentation](documentation/api_docs.md)** - Procedure/function reference

---

##  Contributing

This is an academic project. For questions or suggestions:

- **Email:** shemagwizarobert250@gmail.com
- **Lecturer:** eric.maniraguha@auca.ac.rw
- **GitHub Issues:** [Repository Issues Page]

---

## Acknowledgments

- **Lecturer:** Eric Maniraguha for guidance and instruction
- **AUCA:** For providing the learning environment
- **Rwanda Blood Banks:** For domain inspiration

---

## Support

For technical support or questions:

1. Check the [documentation folder](documentation/)
2. Review [test results](tests/)
3. Contact: shemagwizarobert250@gmail.com
