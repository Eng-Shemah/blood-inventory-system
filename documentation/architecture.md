# System Architecture
## Smart Blood Inventory Management & Shortage Prediction System

**Project:** Blood Inventory Management  
**Student:** [Your Name] | ID: [Your ID]  
**Database:** Oracle 19c Enterprise Edition  
**Date:** December 21, 2025

---

## 1. SYSTEM OVERVIEW

### 1.1 Architecture Type
**Three-Tier Architecture with Business Intelligence Layer**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION TIER                         │
│  Web Interface | Mobile App | BI Dashboards | Reports       │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    APPLICATION TIER                          │
│  PL/SQL Packages | Procedures | Functions | Triggers        │
│  Business Logic | Validation | Security | Audit            │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      DATA TIER                               │
│  Oracle PDB | Tables | Indexes | Sequences | Views          │
│  Materialized Views | Data Warehouse | ML Models            │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 System Context

```
┌──────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SYSTEMS                              │
│                                                                  │
│  National Blood       Hospital Info      Lab Info     Emergency │
│  Registry (NBR)       System (HIS)       System (LIS) Services  │
└────────────┬───────────────┬───────────────┬──────────┬─────────┘
             │               │               │          │
             │               │               │          │
┌────────────▼───────────────▼───────────────▼──────────▼─────────┐
│                                                                  │
│        SMART BLOOD INVENTORY MANAGEMENT SYSTEM                   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Donor      │  │  Inventory   │  │  Transfusion │         │
│  │  Management  │  │  Tracking    │  │  Management  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  Laboratory  │  │  Shortage    │  │   Audit &    │         │
│  │  Testing     │  │  Prediction  │  │   Security   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
└────────────┬───────────────┬───────────────┬──────────┬─────────┘
             │               │               │          │
             │               │               │          │
┌────────────▼───────────────▼───────────────▼──────────▼─────────┐
│                     END USERS                                    │
│                                                                  │
│  Blood Bank    Lab        Inventory    Hospital    System       │
│  Staff         Techs      Managers     Staff       Admins       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. DATABASE ARCHITECTURE

### 2.1 Oracle Container Database Structure

```
┌─────────────────────────────────────────────────────────────┐
│                  ROOT CONTAINER (CDB$ROOT)                   │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         PLUGGABLE DATABASE (PDB)                       │ │
│  │    Name: mon_12121_yourname_bloodinventory_db          │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │              TABLESPACES                         │ │ │
│  │  │                                                  │ │ │
│  │  │  • BLOOD_DATA_TBS    (Primary data)            │ │ │
│  │  │  • BLOOD_INDEX_TBS   (Indexes)                 │ │ │
│  │  │  • BLOOD_TEMP_TBS    (Temporary operations)    │ │ │
│  │  │  • BLOOD_BI_TBS      (BI/Analytics data)       │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │              SCHEMAS                             │ │ │
│  │  │                                                  │ │ │
│  │  │  • BLOOD_ADMIN    (Main schema - owns objects) │ │ │
│  │  │  • BLOOD_APP      (Application user)           │ │ │
│  │  │  • BLOOD_READONLY (Reporting user)             │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Tablespace Configuration

```sql
-- Data Tablespace (8GB initial, autoextend)
CREATE TABLESPACE blood_data_tbs
DATAFILE 'blood_data_01.dbf' SIZE 8G
AUTOEXTEND ON NEXT 512M MAXSIZE 32G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- Index Tablespace (4GB initial)
CREATE TABLESPACE blood_index_tbs
DATAFILE 'blood_index_01.dbf' SIZE 4G
AUTOEXTEND ON NEXT 256M MAXSIZE 16G
EXTENT MANAGEMENT LOCAL;

-- Temporary Tablespace (2GB)
CREATE TEMPORARY TABLESPACE blood_temp_tbs
TEMPFILE 'blood_temp_01.dbf' SIZE 2G
AUTOEXTEND ON NEXT 128M MAXSIZE 8G;

-- BI/Analytics Tablespace (4GB)
CREATE TABLESPACE blood_bi_tbs
DATAFILE 'blood_bi_01.dbf' SIZE 4G
AUTOEXTEND ON NEXT 256M MAXSIZE 16G
EXTENT MANAGEMENT LOCAL;
```

### 2.3 Memory Architecture (SGA/PGA)

```
System Global Area (SGA): 2GB
├── Shared Pool: 800MB
│   ├── Library Cache (SQL/PL/SQL)
│   └── Data Dictionary Cache
├── Database Buffer Cache: 1GB
│   └── Frequently accessed data blocks
├── Redo Log Buffer: 64MB
└── Large Pool: 136MB

Program Global Area (PGA): 512MB per session
├── Sort Area
├── Hash Area
└── Session Memory
```

---

## 3. DATA MODEL ARCHITECTURE

### 3.1 Logical Schema Design

```
┌─────────────────────────────────────────────────────────────┐
│                    CORE DOMAIN                               │
│                                                              │
│  ┌──────────┐      ┌────────────┐      ┌──────────┐       │
│  │  DONORS  │──────│ BLOOD_UNITS│──────│INVENTORY │       │
│  └──────────┘      └────────────┘      └──────────┘       │
│       │                   │                   │            │
│       │                   │                   │            │
│  ┌────▼────┐         ┌───▼──────┐       ┌───▼─────┐      │
│  │DONATION │         │  TESTS   │       │STORAGE  │      │
│  │HISTORY  │         │ RESULTS  │       │LOCATIONS│      │
│  └─────────┘         └──────────┘       └─────────┘      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 TRANSFUSION DOMAIN                           │
│                                                              │
│  ┌──────────┐      ┌──────────────┐    ┌──────────┐       │
│  │ PATIENTS │──────│TRANSFUSIONS  │────│BLOOD_UNITS│      │
│  └──────────┘      └──────────────┘    └──────────┘       │
│                           │                                 │
│                    ┌──────▼────────┐                       │
│                    │ COMPATIBILITY │                       │
│                    │   RECORDS     │                       │
│                    └───────────────┘                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              BUSINESS INTELLIGENCE DOMAIN                    │
│                                                              │
│  ┌──────────────────┐      ┌────────────────┐             │
│  │  SHORTAGE        │      │  TREND         │             │
│  │  PREDICTIONS     │      │  ANALYSIS      │             │
│  └──────────────────┘      └────────────────┘             │
│                                                            │
│  ┌──────────────────┐      ┌────────────────┐             │
│  │  KPI_METRICS     │      │  ALERT_HISTORY │             │
│  └──────────────────┘      └────────────────┘             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                AUDIT & SECURITY DOMAIN                       │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐   ┌──────────┐      │
│  │  AUDIT_LOGS  │    │  HOLIDAYS    │   │  USERS   │      │
│  └──────────────┘    └──────────────┘   └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Table Relationships (Entity Count)

| Domain | Tables | Relationships |
|--------|--------|---------------|
| Donor Management | 3 | 2 FK |
| Blood Unit Tracking | 4 | 5 FK |
| Inventory Management | 2 | 3 FK |
| Transfusion Management | 3 | 4 FK |
| Business Intelligence | 4 | 2 FK |
| Audit & Security | 3 | 1 FK |
| **TOTAL** | **19** | **17** |

---

## 4. APPLICATION LAYER ARCHITECTURE

### 4.1 PL/SQL Component Structure

```
┌─────────────────────────────────────────────────────────────┐
│                   PL/SQL PACKAGES                            │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PKG_DONOR_MANAGEMENT                                  │ │
│  │  • register_donor()                                    │ │
│  │  • update_donor_info()                                 │ │
│  │  • check_eligibility()                                 │ │
│  │  • get_donation_history()                              │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PKG_INVENTORY_MANAGEMENT                              │ │
│  │  • add_blood_unit()                                    │ │
│  │  • update_inventory_level()                            │ │
│  │  • check_expiry()                                      │ │
│  │  • transfer_unit()                                     │ │
│  │  • get_stock_levels()                                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PKG_TRANSFUSION_MANAGEMENT                            │ │
│  │  • create_request()                                    │ │
│  │  • check_compatibility()                               │ │
│  │  • reserve_unit()                                      │ │
│  │  • record_transfusion()                                │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PKG_ANALYTICS                                         │ │
│  │  • predict_shortage()                                  │ │
│  │  • calculate_kpis()                                    │ │
│  │  • generate_trends()                                   │ │
│  │  • identify_patterns()                                 │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 STANDALONE PROCEDURES                        │
│                                                              │
│  • proc_collect_blood_unit()                                │
│  • proc_process_test_results()                              │
│  • proc_expire_old_units()                                  │
│  • proc_generate_alerts()                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    FUNCTIONS                                 │
│                                                              │
│  • fn_check_operation_allowed()     [Security]              │
│  • fn_calculate_days_to_expiry()    [Utility]               │
│  • fn_get_compatible_blood_types()  [Business Logic]        │
│  • fn_calculate_wastage_rate()      [Analytics]             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      TRIGGERS                                │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  COMPOUND TRIGGERS (Business Rules + Auditing)      │   │
│  │  • trg_inventory_compound                            │   │
│  │  • trg_donors_compound                               │   │
│  │  • trg_transfusions_compound                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  SIMPLE TRIGGERS (Data Validation)                   │   │
│  │  • trg_validate_blood_type                           │   │
│  │  • trg_check_expiry_date                             │   │
│  │  • trg_update_inventory_timestamp                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                           │
│                                                              │
│  Layer 1: Database Authentication                           │
│  ├── Oracle user accounts with password policy             │
│  ├── Account lockout after 3 failed attempts               │
│  └── Password expiry: 90 days                              │
│                                                              │
│  Layer 2: Role-Based Access Control (RBAC)                  │
│  ├── ROLE_ADMIN      (Full access)                         │
│  ├── ROLE_MANAGER    (Read + Update)                       │
│  ├── ROLE_STAFF      (Read + Limited Insert)               │
│  └── ROLE_READONLY   (Read only)                           │
│                                                              │
│  Layer 3: Business Rule Enforcement                         │
│  ├── Weekday operation restrictions (Mon-Fri)              │
│  ├── Holiday operation restrictions                        │
│  ├── Data validation triggers                              │
│  └── Audit trail for all DML operations                    │
│                                                              │
│  Layer 4: Audit & Monitoring                                │
│  ├── Comprehensive audit logging                           │
│  ├── Failed login tracking                                 │
│  ├── Suspicious activity alerts                            │
│  └── Compliance reporting                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. DATA FLOW ARCHITECTURE

### 5.1 Blood Collection Flow

```
┌────────────┐
│   DONOR    │
│  Arrives   │
└─────┬──────┘
      │
      ▼
┌────────────────────┐
│ Registration Check │──────► Existing donor? → Update info
│ (proc_register)    │──────► New donor? → Create record
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│ Health Screening   │──────► Eligible? → Proceed
│ (fn_check_eligib)  │──────► Not eligible? → Defer
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│ Blood Collection   │
│ (proc_collect)     │──────► Create BLOOD_UNITS record
└─────┬──────────────┘        Status: COLLECTED
      │
      ▼
┌────────────────────┐
│ Lab Testing        │──────► Update test_results
│ (proc_test)        │──────► Status: TESTING
└─────┬──────────────┘
      │
      ├──► PASSED ──┐
      │             │
      └──► FAILED ──┤
                    │
                    ▼
            ┌───────────────┐
            │ Update Status │
            │ AVAILABLE or  │
            │ QUARANTINE    │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │  INVENTORY    │
            │   Updated     │
            └───────────────┘
```

### 5.2 Transfusion Request Flow

```
┌────────────┐
│  PATIENT   │
│Needs Blood │
└─────┬──────┘
      │
      ▼
┌────────────────────┐
│ Doctor Creates     │
│ Transfusion Req    │──────► Insert TRANSFUSION_REQUESTS
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│ Check Blood Type   │
│ Compatibility      │──────► fn_get_compatible_types()
└─────┬──────────────┘
      │
      ├──► Match Found ──┐
      │                  │
      └──► No Match ─────┤
                         │
                         ▼
                 ┌───────────────┐
                 │ Reserve Unit  │
                 │(proc_reserve) │
                 └───────┬───────┘
                         │
                         ▼
                 ┌───────────────┐
                 │ Cross-Match   │
                 │ in Lab        │
                 └───────┬───────┘
                         │
                         ▼
                 ┌───────────────┐
                 │ Update Status │
                 │ RESERVED →    │
                 │ USED          │
                 └───────┬───────┘
                         │
                         ▼
                 ┌───────────────┐
                 │Record in      │
                 │TRANSFUSIONS   │
                 │table          │
                 └───────────────┘
```

### 5.3 Shortage Prediction Flow

```
┌────────────────────┐
│ Scheduled Job      │
│ (Daily 6:00 AM)    │
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│ Collect Historical │
│ Data (30-90 days)  │──────► Query BLOOD_UNITS
└─────┬──────────────┘        Query TRANSFUSIONS
      │                       Query INVENTORY
      ▼
┌────────────────────┐
│ Calculate Trends   │
│ • Daily usage      │
│ • Donation rate    │
│ • Seasonal patterns│
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│ ML Prediction Model│
│ (pkg_analytics)    │──────► Input: Historical data
└─────┬──────────────┘        Output: 14-day forecast
      │
      ▼
┌────────────────────┐
│ Compare Forecast   │
│ vs. Current Stock  │
└─────┬──────────────┘
      │
      ├──► Shortage Predicted ──┐
      │                         │
      └──► Stock Adequate ──────┤
                                │
                                ▼
                        ┌───────────────┐
                        │ Insert into   │
                        │ SHORTAGE_     │
                        │ PREDICTIONS   │
                        └───────┬───────┘
                                │
                        ┌───────▼───────┐
                        │ Generate Alert│
                        │ to Managers   │
                        └───────────────┘
```

---

## 6. INTEGRATION ARCHITECTURE

### 6.1 External System Interfaces

```
┌─────────────────────────────────────────────────────────────┐
│              EXTERNAL SYSTEM INTEGRATION                     │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  API Gateway Layer                                   │   │
│  │  • RESTful API endpoints                             │   │
│  │  • JSON data exchange                                │   │
│  │  • OAuth 2.0 authentication                          │   │
│  └────────────┬──────────────┬──────────────┬───────────┘   │
│               │              │              │               │
│  ┌────────────▼──┐  ┌───────▼───┐  ┌──────▼──────┐        │
│  │ National Blood│  │ Hospital  │  │ Laboratory  │        │
│  │ Registry      │  │ Info Sys  │  │ Info System │        │
│  │ (NBR)         │  │ (HIS)     │  │ (LIS)       │        │
│  └───────────────┘  └───────────┘  └─────────────┘        │
│                                                              │
│  Data Exchange:                                              │
│  • Donor records sync (daily)                               │
│  • Patient blood type data (real-time)                      │
│  • Test results import (automated)                          │
│  • Inventory sharing (hourly)                               │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 BI Tool Integration

```
┌─────────────────────────────────────────────────────────────┐
│                BI TOOLS CONNECTION                           │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │ Power BI     │◄────────┤ ODBC/JDBC    │                 │
│  │ Dashboards   │         │ Connection   │                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                         │
│  ┌──────────────┐                │                         │
│  │ Tableau      │◄───────────────┤                         │
│  │ Reports      │                │                         │
│  └──────────────┘                │                         │
│                                   │                         │
│                          ┌────────▼────────┐               │
│                          │ Materialized    │               │
│                          │ Views (BI Layer)│               │
│                          │                 │               │
│                          │ • mv_stock_     │               │
│                          │   summary       │               │
│                          │ • mv_kpi_daily  │               │
│                          │ • mv_trends     │               │
│                          └─────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. BACKUP & RECOVERY ARCHITECTURE

### 7.1 Backup Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                   BACKUP STRATEGY                            │
│                                                              │
│  Level 0 (Full Backup)                                       │
│  • Frequency: Weekly (Sunday 2:00 AM)                       │
│  • Retention: 4 weeks                                       │
│  • Location: /backup/full/                                  │
│                                                              │
│  Level 1 (Incremental Backup)                               │
│  • Frequency: Daily (2:00 AM)                               │
│  • Retention: 7 days                                        │
│  • Location: /backup/incremental/                           │
│                                                              │
│  Archive Log Backup                                          │
│  • Frequency: Every 15 minutes                              │
│  • Retention: 7 days                                        │
│  • Location: /backup/archivelogs/                           │
│                                                              │
│  Critical Table Export                                       │
│  • Tables: DONORS, BLOOD_UNITS, TRANSFUSIONS                │
│  • Frequency: Hourly                                        │
│  • Format: Data Pump export (.dmp)                          │
│  • Location: /backup/exports/                               │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Recovery Time Objectives (RTO/RPO)

| Scenario | RTO | RPO | Recovery Method |
|----------|-----|-----|-----------------|
| Database Crash | 30 min | 0 min | Instance recovery (redo logs) |
| Data Corruption | 2 hours | 15 min | Point-in-time recovery (PITR) |
| Hardware Failure | 4 hours | 15 min | Restore from backup |
| Disaster Recovery | 24 hours | 1 hour | Restore to standby site |
| Table Drop | 1 hour | 1 hour | Flashback table / Export restore |

---

## 8. PERFORMANCE ARCHITECTURE

### 8.1 Indexing Strategy

```
Primary Key Indexes (Automatic):
├── pk_donors           ON donors(donor_id)
├── pk_blood_units      ON blood_units(unit_id)
├── pk_inventory        ON inventory(inventory_id)
├── pk_patients         ON patients(patient_id)
└── pk_transfusions     ON transfusions(transfusion_id)

Foreign Key Indexes (Manual):
├── idx_blood_donor_fk  ON blood_units(donor_id)
├── idx_inv_unit_fk     ON inventory(unit_id)
├── idx_trans_patient   ON transfusions(patient_id)
└── idx_trans_unit      ON transfusions(unit_id)

Search Optimization Indexes:
├── idx_blood_type      ON blood_units(blood_type, status)
├── idx_expiry_date     ON blood_units(expiry_date)
├── idx_collection_date ON blood_units(collection_date)
└── idx_trans_date      ON transfusions(transfusion_date)

Full-Text Search:
└── ctx_donor_search    ON donors(first_name, last_name, email)
```

### 8.2 Query Optimization

```
Materialized Views (Refresh: 15 minutes):
├── mv_stock_summary
│   └── Aggregates inventory by blood type
├── mv_daily_kpis
│   └── Pre-calculated KPI metrics
├── mv_shortage_predictions
│   └── Cached prediction results
└── mv_audit_summary
    └── Aggregated audit statistics

Partitioning Strategy:
├── transfusions (RANGE partition by month)
├── audit_logs (RANGE partition by month)
└── shortage_predictions (RANGE partition by quarter)

Query Result Cache:
├── Enabled for frequently accessed queries
└── Cache size: 256MB
```

---

## 9. SCALABILITY ARCHITECTURE

### 9.1 Horizontal Scalability

```
┌─────────────────────────────────────────────────────────────┐
│                 READ REPLICAS (Future)                       │
│                                                              │
│  ┌────────────┐      ┌────────────┐      ┌────────────┐    │
│  │ Primary DB │      │ Replica 1  │      │ Replica 2  │    │
│  │ (Read/Write)──────►(Read Only) │      │(Read Only) │    │
│  └────────────┘      └────────────┘      └────────────┘    │
│                                                              │
│  Use Case:                                                   │
│  • BI queries routed to replicas                            │
│  • Transactional queries to primary                         │
│  • Load balancing for reporting                             │
└─────────────────────────────────────────────────────────────┘
```

### 9.2 Vertical Scalability

| Component | Current | Max Capacity | Upgrade Path |
|-----------|---------|--------------|--------------|
| CPU | 4 cores | 32 cores | Add cores as needed |
| RAM | 8 GB | 64 GB | Increase SGA/PGA |
| Storage | 20 GB | 2 TB | Add datafiles |
| Connections | 100 | 1000 | Increase processes param |

---

## 10. MONITORING & OBSERVABILITY

### 10.1 Monitoring Points

```
Database