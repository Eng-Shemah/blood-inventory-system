# Business Intelligence Dashboards
## Smart Blood Inventory Management & Shortage Prediction System

**Project:** Blood Inventory Management  
**Student:** [Your Name] | ID: [Your ID]  
**Date:** December 21, 2025

---

## EXECUTIVE SUMMARY

This document defines three core dashboards that provide real-time visibility, predictive insights, and operational intelligence for blood inventory management. Each dashboard serves specific stakeholder needs and supports data-driven decision-making.

---

## DASHBOARD 1: EXECUTIVE SUMMARY DASHBOARD

### Purpose
High-level overview for hospital executives, blood bank directors, and senior management to monitor overall system health and strategic KPIs.

### Target Users
- Hospital CEO/COO
- Blood Bank Director
- Ministry of Health Officials
- Regional Coordinators

### Refresh Rate
Real-time updates every 15 minutes

---

### LAYOUT & COMPONENTS

#### TOP ROW: KPI CARDS (4 Cards)

**Card 1: Total Inventory Status**
```
┌─────────────────────────┐
│ TOTAL BLOOD UNITS       │
│                         │
│      1,247 units        │
│   ↑ 8.3% vs Last Week   │
│                         │
│ Status: ● HEALTHY       │
└─────────────────────────┘
```
- **Metric:** Total available blood units across all types
- **Trend:** Week-over-week change
- **Status Indicator:** 
  - 🟢 GREEN: >1000 units
  - 🟡 YELLOW: 500-1000 units
  - 🔴 RED: <500 units

---

**Card 2: Critical Shortages**
```
┌─────────────────────────┐
│ SHORTAGE ALERTS         │
│                         │
│         3 types         │
│   ⚠️ IMMEDIATE ACTION   │
│                         │
│ O-, AB-, B- Low         │
└─────────────────────────┘
```
- **Metric:** Number of blood types below critical threshold
- **Severity:** Color-coded by urgency
- **Action Link:** Drill-down to shortage details

---

**Card 3: Donation Rate**
```
┌─────────────────────────┐
│ DAILY DONATIONS         │
│                         │
│      187 units          │
│   Target: 200/day       │
│                         │
│ Achievement: 93.5%      │
└─────────────────────────┘
```
- **Metric:** Donations collected today vs. daily target
- **Progress Bar:** Visual completion indicator
- **Trend:** 7-day moving average

---

**Card 4: Wastage Rate**
```
┌─────────────────────────┐
│ EXPIRED UNITS (30d)     │
│                         │
│         24 units        │
│   ↓ 15.2% vs Last Month │
│                         │
│ Wastage: 1.8%           │
└─────────────────────────┘
```
- **Metric:** Units expired in last 30 days
- **Target:** <2% wastage rate
- **Trend:** Month-over-month comparison

---

#### MIDDLE ROW: VISUALIZATIONS (2 Charts)

**Chart 1: Inventory Distribution by Blood Type (Donut Chart)**
```
        O+: 35% (437 units)
        A+: 28% (349 units)
        B+: 18% (224 units)
        AB+: 8% (100 units)
        O-: 5% (62 units)
        A-: 3% (37 units)
        B-: 2% (25 units)
        AB-: 1% (13 units)
```
- **Visualization:** Donut chart with percentages
- **Color Coding:** Each blood type has unique color
- **Interactive:** Click to filter entire dashboard by blood type

---

**Chart 2: 30-Day Demand vs. Supply Trend (Line Chart)**
```
Units
│     ╱╲    Demand (Red)
│    ╱  ╲  ╱
│   ╱    ╲╱   Supply (Blue)
│  ╱      ╲
│ ╱        ╲
└─────────────────────► Time
```
- **Metrics:** Daily collection (supply) vs. transfusion requests (demand)
- **Prediction Line:** Dotted line showing 7-day forecast
- **Gap Analysis:** Shaded areas where demand exceeds supply

---

#### BOTTOM ROW: INSIGHTS (2 Panels)

**Panel 1: Predicted Shortages (Next 14 Days)**
```
┌────────────────────────────────────────┐
│ UPCOMING SHORTAGE ALERTS               │
├────────────┬────────┬─────────┬────────┤
│ Blood Type │ Days   │ Severity│ Action │
├────────────┼────────┼─────────┼────────┤
│ O-         │ 3 days │ 🔴 HIGH │ ➜ Plan │
│ AB-        │ 5 days │ 🟡 MED  │ ➜ Plan │
│ B-         │ 8 days │ 🟡 MED  │ ➜ Plan │
│ A+         │ 12 days│ 🟢 LOW  │ ➜ Plan │
└────────────┴────────┴─────────┴────────┘
```
- **Data Source:** ML prediction model
- **Confidence:** 85% accuracy based on historical patterns
- **Actions:** Link to procurement planning module

---

**Panel 2: Performance Scorecard**
```
┌─────────────────────────────────────────┐
│ KEY PERFORMANCE METRICS (This Month)    │
├────────────────────────────┬────────────┤
│ Fulfillment Rate           │ 98.7%  ✓   │
│ Average Response Time      │ 12 min ✓   │
│ Donor Retention Rate       │ 67%    ✓   │
│ Blood Utilization Rate     │ 94.3%  ✓   │
│ System Uptime              │ 99.9%  ✓   │
└────────────────────────────┴────────────┘
```
- **Benchmarks:** Industry standards shown for comparison
- **Status Icons:** ✓ = Meeting target, ⚠ = Below target

---

### FILTERS & CONTROLS
- **Date Range:** Last 7/30/90 days, Custom
- **Location:** All Hospitals / Specific Facility
- **Blood Type:** All / Individual types
- **Export:** PDF report, Excel data

---

## DASHBOARD 2: OPERATIONAL MONITORING DASHBOARD

### Purpose
Real-time operational metrics for blood bank managers, inventory staff, and laboratory supervisors to monitor daily operations and identify issues.

### Target Users
- Blood Bank Managers
- Inventory Coordinators
- Lab Supervisors
- Quality Assurance Staff

### Refresh Rate
Real-time updates every 5 minutes

---

### LAYOUT & COMPONENTS

#### SECTION 1: REAL-TIME INVENTORY STATUS

**Table: Current Stock Levels by Blood Type**
```
┌──────────┬───────────┬──────────┬──────────┬────────────┬─────────┐
│Blood Type│Available  │Reserved  │Expiring  │ Min Level  │ Status  │
│          │  Units    │  Units   │  (7d)    │            │         │
├──────────┼───────────┼──────────┼──────────┼────────────┼─────────┤
│ O+       │   437     │    23    │    15    │    100     │ 🟢 OK   │
│ A+       │   349     │    18    │    12    │    80      │ 🟢 OK   │
│ B+       │   224     │    11    │    8     │    60      │ 🟢 OK   │
│ AB+      │   100     │    5     │    4     │    40      │ 🟢 OK   │
│ O-       │    62     │    8     │    6     │    50      │ 🟡 LOW  │
│ A-       │    37     │    4     │    3     │    30      │ 🟢 OK   │
│ B-       │    25     │    2     │    2     │    25      │ 🔴 CRIT │
│ AB-      │    13     │    1     │    1     │    15      │ 🔴 CRIT │
└──────────┴───────────┴──────────┴──────────┴────────────┴─────────┘
```
- **Automatic Highlighting:** Rows turn red when below minimum
- **Drill-down:** Click to see unit-level details
- **Actions:** Quick buttons for procurement, transfer

---

#### SECTION 2: TODAY'S ACTIVITY METRICS

**Chart: Hourly Collection & Usage (Bar Chart)**
```
Units
 30│    ██              ██
 25│    ██    ██        ██    ██
 20│    ██    ██  ██    ██    ██
 15│ ██ ██    ██  ██    ██    ██  ██
 10│ ██ ██ ██ ██  ██ ██ ██ ██ ██  ██
  5│ ██ ██ ██ ██  ██ ██ ██ ██ ██  ██
  0└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──
     8  9  10 11 12  1  2  3  4  5  6
         Blue = Collections | Red = Usage
```
- **Purpose:** Identify peak collection/usage times
- **Insight:** Optimize staffing based on patterns

---

#### SECTION 3: EXPIRY MONITORING

**Table: Units Expiring Soon**
```
┌──────────┬───────────┬──────────────┬────────────┬──────────┐
│ Unit ID  │Blood Type │ Expiry Date  │ Days Left  │  Action  │
├──────────┼───────────┼──────────────┼────────────┼──────────┤
│ U-45231  │ O+        │ 2025-12-24   │     3      │ ➜ USE    │
│ U-45189  │ A+        │ 2025-12-25   │     4      │ ➜ USE    │
│ U-45156  │ B+        │ 2025-12-26   │     5      │ ➜ ALERT  │
│ U-45098  │ O-        │ 2025-12-27   │     6      │ ➜ ALERT  │
│ U-45034  │ AB+       │ 2025-12-28   │     7      │ ➜ WATCH  │
└──────────┴───────────┴──────────────┴────────────┴──────────┘
```
- **Auto-Sort:** By days remaining (ascending)
- **Alert System:** Automated emails at 7, 5, 3 days
- **Actions:** Mark as priority, transfer to high-demand facility

---

#### SECTION 4: QUALITY METRICS

**Gauge Charts: Quality Performance**
```
    Test Pass Rate          Temperature Compliance
    ┌──────────┐            ┌──────────┐
    │    99.2% │            │    99.8% │
    │   ╱──────╲│            │   ╱──────╲│
    │  │  ●    ││            │  │   ●   ││
    │   ╲──────╱│            │   ╲──────╱│
    └──────────┘            └──────────┘
    Target: 98%+            Target: 99%+
```
- **Metrics:** Pass rates for blood screening tests
- **Compliance:** Temperature monitoring adherence
- **Alerts:** Notify QA team if below threshold

---

#### SECTION 5: DONOR ACTIVITY

**Chart: Donor Registration & Collections (Combo Chart)**
```
Donors
│     ●─────●          ● = Registered
│    /       \        / 
│   /         ●──────●   ▓ = Collected
│  /          ▓▓▓▓▓▓▓
│ /         ▓▓▓▓▓▓▓▓
│●        ▓▓▓▓▓▓▓▓▓
└─────────────────────► Days
  Mon  Tue  Wed  Thu  Fri
```
- **Metrics:** Daily donor registrations vs. successful collections
- **Conversion Rate:** % of registered donors who donated
- **Insights:** Identify deferral reasons

---

### ALERTS & NOTIFICATIONS PANEL
```
┌─────────────────────────────────────────────┐
│ ACTIVE ALERTS                               │
├────────┬────────────────────────────────────┤
│ 🔴 HIGH│ B- blood type below critical (2h)  │
│ 🟡 MED │ 15 units expiring in 3 days        │
│ 🟡 MED │ Temperature excursion in Fridge-3  │
│ 🟢 LOW │ Donor retention rate trending down │
└────────┴────────────────────────────────────┘
```

---

## DASHBOARD 3: AUDIT & COMPLIANCE DASHBOARD

### Purpose
Track system security, audit logs, and compliance with regulatory requirements for administrators and compliance officers.

### Target Users
- System Administrators
- Compliance Officers
- Security Auditors
- Quality Assurance Managers

### Refresh Rate
Updates every 30 minutes

---

### LAYOUT & COMPONENTS

#### SECTION 1: OPERATION AUDIT SUMMARY

**Table: Recent Operations by Status**
```
┌──────────────┬─────────┬─────────┬─────────┬──────────┐
│ Operation    │ Allowed │ Denied  │ Total   │ % Denied │
├──────────────┼─────────┼─────────┼─────────┼──────────┤
│ INSERT       │   342   │   87    │   429   │  20.3%   │
│ UPDATE       │   521   │   124   │   645   │  19.2%   │
│ DELETE       │    45   │   15    │    60   │  25.0%   │
├──────────────┼─────────┼─────────┼─────────┼──────────┤
│ TOTAL        │   908   │   226   │  1,134  │  19.9%   │
└──────────────┴─────────┴─────────┴─────────┴──────────┘
```
- **Time Range:** Last 30 days
- **Drill-Down:** Click to see individual audit entries

---

#### SECTION 2: WEEKDAY RESTRICTION COMPLIANCE

**Chart: Operations by Day of Week (Stacked Bar)**
```
Operations
│     
│ Mon ▓▓▓▓▓▓▓▓▓▓▓▓ (124 denied) 🔴
│ Tue ▓▓▓▓▓▓▓▓▓▓▓  (118 denied) 🔴
│ Wed ▓▓▓▓▓▓▓▓▓▓▓▓ (135 denied) 🔴
│ Thu ▓▓▓▓▓▓▓▓▓▓▓  (121 denied) 🔴
│ Fri ▓▓▓▓▓▓▓▓▓▓▓▓ (142 denied) 🔴
│ Sat ░░░░░░ (28 allowed) 🟢
│ Sun ░░░░░ (22 allowed) 🟢
└────────────────────────────────
  Red = Denied | Green = Allowed
```
- **Purpose:** Verify restriction trigger is working
- **Expected:** High denial rate Mon-Fri, low on weekends
- **Anomaly Detection:** Alert if weekday operations allowed

---

#### SECTION 3: USER ACTIVITY LOG

**Table: Top Users by Activity**
```
┌────────────────┬──────────┬─────────┬─────────┬────────────┐
│ Database User  │ Allowed  │ Denied  │ Total   │ Last Active│
├────────────────┼──────────┼─────────┼─────────┼────────────┤
│ ADMIN_USER     │   245    │    12   │   257   │ 2h ago     │
│ INVENTORY_MGR  │   198    │    45   │   243   │ 30m ago    │
│ LAB_TECH1      │   167    │    38   │   205   │ 1h ago     │
│ BLOOD_BANK_01  │   143    │    52   │   195   │ 45m ago    │
│ HOSPITAL_STAFF │    89    │    67   │   156   │ 15m ago    │
└────────────────┴──────────┴─────────┴─────────┴────────────┘
```
- **Purpose:** Monitor user behavior and potential violations
- **Alerts:** Flag users with unusually high denial rates

---

#### SECTION 4: DENIAL REASONS ANALYSIS

**Pie Chart: Why Operations Were Denied**
```
        Weekday Restriction: 68%
        Holiday Restriction: 22%
        Invalid Permissions: 7%
        System Error: 3%
```
- **Insight:** Most denials are expected (weekday rules)
- **Action:** Investigate permission and system errors

---

#### SECTION 5: DETAILED AUDIT LOG

**Table: Recent Audit Entries (Last 100)**
```
┌──────────┬───────────┬──────────┬────────┬────────────┬─────────────────┐
│ Audit ID │ Table     │ Operation│ Status │ User       │ Timestamp       │
├──────────┼───────────┼──────────┼────────┼────────────┼─────────────────┤
│ 89234    │ INVENTORY │ INSERT   │ DENIED │ INV_MGR_02 │ 2025-12-21 14:23│
│ 89233    │ DONORS    │ UPDATE   │ ALLOWED│ BLOOD_BNKR │ 2025-12-21 14:18│
│ 89232    │ INVENTORY │ UPDATE   │ DENIED │ LAB_TECH3  │ 2025-12-21 14:12│
│ 89231    │ TRANSFUSE │ INSERT   │ ALLOWED│ DOCTOR_05  │ 2025-12-21 14:05│
└──────────┴───────────┴──────────┴────────┴────────────┴─────────────────┘
```
- **Expandable Rows:** Click to see old/new values
- **Export:** Download full audit trail for compliance reports
- **Search:** Filter by user, table, date range, status

---

#### SECTION 6: COMPLIANCE INDICATORS

**KPI Cards: Regulatory Compliance**
```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Audit Log        │  │ Data Retention   │  │ Access Control   │
│ Completeness     │  │ Compliance       │  │ Enforcement      │
│                  │  │                  │  │                  │
│     100%    ✓    │  │     100%    ✓    │  │     98.7%   ✓    │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

---

## DASHBOARD ACCESS & PERMISSIONS

### Role-Based Access Control

| Dashboard | Executive | Manager | Staff | Admin |
|-----------|-----------|---------|-------|-------|
| Executive Summary | ✓ Full | ✓ Full | ✗ No | ✓ Full |
| Operational Monitoring | ✓ View | ✓ Full | ✓ Limited | ✓ Full |
| Audit & Compliance | ✗ No | ✗ No | ✗ No | ✓ Full |

---

## TECHNICAL SPECIFICATIONS

### Data Sources
- **Primary Database:** Oracle PDB (blood inventory system)
- **Refresh Mechanism:** Materialized views (15-min refresh)
- **Analytics Engine:** Oracle Analytics Cloud / Power BI
- **Prediction Model:** Python ML service (API integration)

### Performance Requirements
- **Load Time:** <3 seconds for initial dashboard load
- **Query Response:** <1 second for filters and drill-downs
- **Concurrent Users:** Support 50+ simultaneous users
- **Mobile Responsive:** Fully functional on tablets/phones

---

## IMPLEMENTATION NOTES

### Phase 1 (Current)
✓ SQL queries for all metrics created  
✓ Views and materialized views defined  
✓ Mock data populated for testing  

### Phase 2 (Future)
⏳ Integrate with BI tool (Power BI/Tableau)  
⏳ Deploy prediction ML model  
⏳ Set up automated email alerts  

### Phase 3 (Enhancement)
⏳ Mobile app dashboards  
⏳ Voice-activated queries  
⏳ AI-powered insights  

---

**Document Version:** 1.0  
**Last Updated:** December 21, 2025  
**Next Review:** January 2026