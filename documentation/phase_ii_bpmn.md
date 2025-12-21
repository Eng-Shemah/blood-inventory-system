# Phase II: Business Process Modeling
## Smart Blood Inventory Management System

---

## BPMN Diagram - Blood Donation to Transfusion Process

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  DONOR LANE                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│   (●) ──→ [Register   ] ──→ <Eligible?> ──→ [Complete    ] ──→ [Provide  ] ──→ [Receive ] ──→ (●)│
│   START   Donor Info       /        \       Questionnaire      Blood      Follow-up     END   │
│                           /          \                                     Info                │
│                      YES /            \ NO                                                      │
│                         /              \                                                        │
│                        ↓                ↓                                                       │
│                 [Schedule      ]   [Defer &    ]                                               │
│                  Donation           Record      ]                                               │
│                                     Reason                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  BLOOD BANK LANE                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│         ↓                        ↓                                                              │
│   [Collect  ] ──→ [Label &  ] ──→ [Test    ] ──→ <Test   > ──→ [Store in ] ──→ [Monitor]      │
│    Blood         Barcode        Blood         Passed?       Inventory       Expiry             │
│                  Unit                            /   \                                          │
│                                             YES /     \ NO                                      │
│                                                /       \                                        │
│                                               ↓         ↓                                       │
│                                        [Update      ] [Discard  ]                              │
│                                         Status       & Record                                   │
│                                         AVAILABLE    Reason                                     │
│                                              |                                                  │
│                                              ↓                                                  │
│                                         [Check     ] ──→ <Low     > ──→ [Trigger ] ──→ [Contact]│
│                                          Inventory       Stock?         Alert       Donors     │
│                                                            /   \                                │
│                                                       YES /     \ NO                            │
│                                                          /       \                              │
│                                                         ↓         ↓                             │
│                                                   [Generate    ] [Continue]                    │
│                                                    Shortage      Normal                         │
│                                                    Prediction    Operations                     │
│                                                         |                                       │
│                                                         ↓                                       │
│                                              [Schedule Donor Campaign]                          │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  HOSPITAL/CLINICAL LANE                                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│   (●) ──→ [Patient   ] ──→ [Determine ] ──→ [Check    ] ──→ <Blood    > ──→ [Reserve]         │
│   START   Requires        Blood Need       Inventory      Available?      Unit                │
│           Blood                                              /        \                         │
│                                                         YES /          \ NO                     │
│                                                            /            \                       │
│                                                           ↓              ↓                      │
│                                                    [Match       ]  [Emergency ]                 │
│                                                     Compatible     Procurement/                 │
│                                                     Blood Type     Transfer                     │
│                                                         |                |                      │
│                                                         ↓                ↓                      │
│                                                    [Verify      ] ←──────┘                      │
│                                                     Patient-Unit                                │
│                                                     Compatibility                               │
│                                                         |                                       │
│                                                         ↓                                       │
│                                                    [Perform     ] ──→ [Record    ] ──→ [Update ]│
│                                                     Transfusion       Transfusion     Patient  │
│                                                                       in System       Records   │
│                                                                            |                    │
│                                                                            ↓                    │
│                                                                       [Update      ]            │
│                                                                        Inventory               │
│                                                                        Status:                  │
│                                                                        IN_USE                   │
│                                                                            |                    │
│                                                                            ↓                    │
│                                                                       [Monitor     ] ──→ (●)    │
│                                                                        Patient               END│
│                                                                        Post-Trans.              │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  MANAGEMENT/BI ANALYTICS LANE                                                                   │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│         ┌──────────────────────────────────────────────────────────┐                          │
│         │  [Continuous Monitoring & Analytics]                      │                          │
│         │   • Track inventory levels (real-time)                   │                          │
│         │   • Analyze donation patterns                             │                          │
│         │   • Predict shortages (ML models)                        │                          │
│         │   • Monitor expiry dates                                  │                          │
│         │   • Generate KPI reports                                  │                          │
│         │   • Audit all transactions                                │                          │
│         └──────────────────────────────────────────────────────────┘                          │
│                           ↓                   ↓                    ↓                            │
│                   [Executive      ] [Operational    ] [Compliance   ]                          │
│                    Dashboard        Dashboard         Reports                                  │
│                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

LEGEND:
───────
(●) = Start/End Event
[ ] = Activity/Task
< > = Decision Gateway (Diamond)
──→ = Sequence Flow
↓   = Data Flow
```

---

## BPMN SYMBOLS USED

| Symbol | Name | Usage in Process |
|--------|------|------------------|
| **●** | Start/End Event | Process initiation and completion |
| **[ ]** | Activity/Task | Actions performed (Register, Test, Store) |
| **< >** | Gateway (Decision) | Conditional branching (Eligible?, Test Passed?) |
| **→** | Sequence Flow | Order of activities |
| **↓** | Message/Data Flow | Information exchange between lanes |
| **Swimlanes** | Pools/Lanes | Responsibility separation by actor |

---

## TEXT-BASED BPMN FOR LUCIDCHART/DRAW.IO

### Instructions for Creating Diagram:

**In Lucidchart/Draw.io:**

1. **Create 4 Swimlanes (Horizontal Pools):**
   - Donor Lane (Top)
   - Blood Bank Lane
   - Hospital/Clinical Lane
   - Management/BI Analytics Lane (Bottom)

2. **Add BPMN Elements:**
   - Start Events: Green circle with thin border
   - End Events: Red circle with thick border
   - Tasks/Activities: Rounded rectangles (blue)
   - Gateways: Yellow diamonds (for decisions)
   - Sequence Flows: Solid arrows
   - Message Flows: Dashed arrows between lanes

3. **Key Decision Points:**
   - "Eligible?" (Donor Lane)
   - "Test Passed?" (Blood Bank Lane)
   - "Blood Available?" (Hospital Lane)
   - "Low Stock?" (Blood Bank Lane)

4. **Data Flows Between Lanes:**
   - Donor data → Blood Bank
   - Blood unit info → Inventory system
   - Inventory status → Hospital
   - All activities → BI Analytics

---

## DETAILED PROCESS DESCRIPTIONS

### SWIMLANE 1: DONOR LANE

**Actors:** Blood Donors, Donor Relations Staff

**Activities:**
1. **Register Donor Info** - Capture personal details, contact info, blood type
2. **Eligibility Check** - Verify age (18-65), health questionnaire, donation history
3. **Complete Questionnaire** - Health screening, travel history, medications
4. **Provide Blood** - Donation process (450ml collection)
5. **Receive Follow-up Info** - Next eligible date, care instructions

**Decision Points:**
- **Eligible?** 
  - YES → Proceed to donation
  - NO → Defer and record reason (age, health, recent donation)

**MIS Functions:**
- Store donor demographics in DONORS table
- Track eligibility status
- Schedule next donation (56-day interval)
- Generate donor ID via sequence

---

### SWIMLANE 2: BLOOD BANK LANE

**Actors:** Phlebotomists, Lab Technicians, Inventory Managers

**Activities:**
1. **Collect Blood** - Sterile collection process, donor supervision
2. **Label & Barcode Unit** - Unique unit ID, blood type verification
3. **Test Blood** - Screen for infectious diseases, blood type confirmation
4. **Store in Inventory** - Refrigerated storage (2-6°C)
5. **Monitor Expiry** - Track 42-day shelf life
6. **Check Inventory** - Real-time stock level monitoring
7. **Trigger Alert** - Automated notifications for low stock
8. **Contact Donors** - Recall eligible donors for specific blood types

**Decision Points:**
- **Test Passed?**
  - YES → Update status to AVAILABLE, store in inventory
  - NO → Discard unit, record failure reason (contamination, disease markers)
- **Low Stock?**
  - YES → Generate shortage prediction, schedule donor campaign
  - NO → Continue normal operations

**MIS Functions:**
- Insert BLOOD_UNITS records with status tracking
- Execute fn_get_inventory_level() for stock checks
- Trigger shortage prediction algorithm
- Generate expiry alerts (units < 7 days)
- Update inventory aggregates

---

### SWIMLANE 3: HOSPITAL/CLINICAL LANE

**Actors:** Doctors, Nurses, Lab Staff, Transfusion Services

**Activities:**
1. **Patient Requires Blood** - Clinical assessment, transfusion order
2. **Determine Blood Need** - Blood type, volume required, urgency level
3. **Check Inventory** - Query available compatible units
4. **Match Compatible Blood Type** - Verify ABO/Rh compatibility
5. **Verify Patient-Unit Compatibility** - Cross-match testing
6. **Perform Transfusion** - Administer blood, monitor patient
7. **Record Transfusion** - Document in patient record and system
8. **Update Inventory Status** - Change unit status to IN_USE
9. **Monitor Patient Post-Transfusion** - Adverse reaction surveillance

**Decision Points:**
- **Blood Available?**
  - YES → Reserve unit, proceed to compatibility check
  - NO → Emergency procurement (transfer from other facility or emergency donors)

**MIS Functions:**
- Insert PATIENTS record if new patient
- Execute fn_check_blood_compatibility()
- Call sp_record_transfusion() procedure
- Update BLOOD_UNITS.status to IN_USE
- Generate TRANSFUSIONS record
- Link patient and unit via foreign keys

---

### SWIMLANE 4: MANAGEMENT/BI ANALYTICS LANE

**Actors:** Blood Bank Manager, Hospital Administrators, Quality Assurance

**Continuous Activities:**
- **Track Inventory Levels** - Real-time dashboard monitoring
- **Analyze Donation Patterns** - Identify trends, seasonal variations
- **Predict Shortages** - Execute predictive models (fn_get_shortage_risk)
- **Monitor Expiry Dates** - Automated daily scans
- **Generate KPI Reports** - Daily, weekly, monthly summaries
- **Audit All Transactions** - AUDIT_LOGS table captures every operation

**Outputs:**
- **Executive Dashboard** - High-level KPIs, alerts, trends
- **Operational Dashboard** - Detailed inventory, expiry calendar
- **Compliance Reports** - Audit logs, policy adherence, quality metrics

**MIS Functions:**
- Execute analytical queries (window functions)
- Generate views (v_audit_summary, v_inventory_distribution)
- Run sp_generate_audit_report()
- Populate SHORTAGE_PREDICTIONS table
- Export reports (PDF, Excel)

---

## HANDOFF POINTS & DATA FLOWS

### Critical Integration Points:

1. **Donor → Blood Bank**
   - Handoff: Completed donation
   - Data: Donor ID, donation timestamp, health clearance
   - System Action: Insert BLOOD_UNITS record, link to DONOR_ID

2. **Blood Bank → Inventory System**
   - Handoff: Test completion
   - Data: Unit ID, test results, storage location
   - System Action: Update status to AVAILABLE, refresh inventory counts

3. **Inventory → Hospital**
   - Handoff: Blood request
   - Data: Available units by type, expiry dates
   - System Action: Query BLOOD_UNITS where status='AVAILABLE'

4. **Hospital → Patient Record**
   - Handoff: Transfusion completion
   - Data: Patient ID, unit ID, transfusion details
   - System Action: Insert TRANSFUSIONS record, update unit status

5. **All Activities → BI Analytics**
   - Handoff: Every database operation
   - Data: Complete audit trail
   - System Action: Populate AUDIT_LOGS via triggers

---

## MIS RELEVANCE & ORGANIZATIONAL IMPACT

### MIS Functions Demonstrated:

1. **Transaction Processing System (TPS)**
   - Real-time capture of donor registrations
   - Blood unit tracking from collection to transfusion
   - Inventory updates with every operation

2. **Management Information System (MIS)**
   - Daily/weekly/monthly operational reports
   - KPI dashboards for managers
   - Exception reports (low stock, expiring units)

3. **Decision Support System (DSS)**
   - Shortage prediction models
   - Donor campaign planning
   - Inventory optimization recommendations

4. **Executive Information System (EIS)**
   - High-level strategic dashboards
   - Trend analysis and forecasting
   - Performance against targets

### Organizational Impact:

**Operational Efficiency:**
- Reduce manual data entry by 80%
- Real-time inventory visibility eliminates phone calls
- Automated alerts prevent stockouts

**Cost Reduction:**
- 40% reduction in expired blood waste = $50K-$100K annually
- Optimized inventory levels reduce excess stock costs
- Better donor retention reduces recruitment costs

**Patient Safety:**
- Ensure blood availability for emergencies (95% SLA)
- Automated compatibility checking prevents errors
- Complete audit trail supports quality assurance

**Regulatory Compliance:**
- 100% traceability from donor to patient
- Comprehensive audit logs for inspections
- Automated compliance reporting

**Strategic Decision Support:**
- Data-driven donor campaign planning
- Resource allocation optimization
- Long-term capacity planning

---

## ANALYTICS OPPORTUNITIES

### Predictive Analytics:
1. **Shortage Forecasting** - 7-14 day advance warning using time series analysis
2. **Donor Churn Prediction** - Identify at-risk donors before they become inactive
3. **Seasonal Demand Patterns** - Adjust collection schedules based on historical trends

### Descriptive Analytics:
1. **Inventory Turnover Rate** - Track freshness of blood supply
2. **Donor Lifetime Value** - Calculate contribution per donor over time
3. **Waste Analysis** - Root cause analysis of expiry patterns

### Prescriptive Analytics:
1. **Optimal Collection Schedule** - Recommend best days/times for donor campaigns
2. **Inventory Rebalancing** - Suggest transfers between blood types
3. **Donor Engagement Strategy** - Personalized outreach recommendations

### Real-Time Monitoring:
1. **Live Dashboards** - Current inventory status, trending up/down
2. **Alert Systems** - Immediate notifications for critical situations
3. **Performance Metrics** - Track against daily/weekly targets

---

## PROCESS OBJECTIVES & OUTCOMES

### Primary Objectives:
1. ✅ Ensure continuous blood supply availability
2. ✅ Minimize waste through expiry management
3. ✅ Maintain 100% traceability and compliance
4. ✅ Optimize donor engagement and retention

### Expected Outcomes:
- **Shortage Incidents:** Reduce from 5/month to < 1/month (80% reduction)
- **Blood Waste:** Decrease from 15% to < 5% expiry rate
- **Donor Retention:** Increase from 55% to 70%
- **Data Accuracy:** Achieve 99.9% data integrity
- **Response Time:** Critical alerts delivered within 1 minute

### Success Metrics:
- 95% blood availability SLA for planned surgeries
- Zero stockouts for O- blood type (universal donor)
- 100% audit coverage for regulatory compliance
- $100K-$190K annual cost savings

---

*This business process model demonstrates a comprehensive MIS solution integrating transaction processing, decision support, and executive information systems while addressing critical healthcare inventory management challenges.*

**Document Version:** 1.0  
**Last Updated:** December 2025