-- Analytical Queries
-- Query 1: Blood Shortage Prediction Model
-- Purpose: Predict when each blood type will face shortage

WITH usage_stats AS (
    SELECT 
        bu.blood_type,
        COUNT(DISTINCT DATE(t.transfusion_date)) AS days_with_usage,
        COUNT(*) AS total_transfusions,
        ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT DATE(t.transfusion_date)), 0), 2) AS avg_daily_usage
    FROM transfusions t
    JOIN blood_units bu ON t.unit_id = bu.unit_id
    WHERE t.transfusion_date >= SYSDATE - 30
    GROUP BY bu.blood_type
),
current_inventory AS (
    SELECT 
        blood_type,
        COUNT(*) AS available_units
    FROM blood_units
    WHERE status = 'AVAILABLE'
    AND expiry_date > SYSDATE
    GROUP BY blood_type
)
SELECT 
    ci.blood_type,
    ci.available_units AS current_stock,
    COALESCE(us.avg_daily_usage, 0) AS avg_daily_usage,
    CASE 
        WHEN COALESCE(us.avg_daily_usage, 0) = 0 THEN NULL
        ELSE ROUND(ci.available_units / us.avg_daily_usage, 1)
    END AS days_until_shortage,
    CASE 
        WHEN COALESCE(us.avg_daily_usage, 0) = 0 THEN 'UNKNOWN'
        WHEN ci.available_units / us.avg_daily_usage < 3 THEN 'CRITICAL'
        WHEN ci.available_units / us.avg_daily_usage < 7 THEN 'HIGH'
        WHEN ci.available_units / us.avg_daily_usage < 14 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,
    CASE 
        WHEN COALESCE(us.avg_daily_usage, 0) = 0 THEN 'No recent usage data'
        WHEN ci.available_units / us.avg_daily_usage < 3 THEN 'URGENT: Schedule emergency donor drives'
        WHEN ci.available_units / us.avg_daily_usage < 7 THEN 'Contact donors for appointments within 48 hours'
        WHEN ci.available_units / us.avg_daily_usage < 14 THEN 'Monitor daily, prepare outreach campaign'
        ELSE 'Normal operations, maintain current schedule'
    END AS recommended_action
FROM current_inventory ci
LEFT JOIN usage_stats us ON ci.blood_type = us.blood_type
ORDER BY days_until_shortage NULLS LAST, ci.blood_type;


-- Query 2: Donor Lifetime Value Analysis
-- Purpose: Identify most valuable donors for retention programs

SELECT 
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    d.blood_type,
    COUNT(bu.unit_id) AS lifetime_donations,
    MIN(bu.collection_date) AS first_donation_date,
    MAX(bu.collection_date) AS last_donation_date,
    ROUND(MONTHS_BETWEEN(MAX(bu.collection_date), MIN(bu.collection_date)) / 12, 1) AS donor_years,
    ROUND(COUNT(bu.unit_id) / NULLIF(MONTHS_BETWEEN(MAX(bu.collection_date), MIN(bu.collection_date)) / 12, 0), 2) AS avg_donations_per_year,
    COUNT(t.transfusion_id) AS units_transfused,
    ROUND(COUNT(t.transfusion_id) * 100.0 / NULLIF(COUNT(bu.unit_id), 0), 1) AS utilization_rate,
    CASE 
        WHEN COUNT(bu.unit_id) >= 10 THEN 'ELITE'
        WHEN COUNT(bu.unit_id) >= 5 THEN 'FREQUENT'
        WHEN COUNT(bu.unit_id) >= 2 THEN 'REGULAR'
        ELSE 'NEW'
    END AS donor_tier,
    TRUNC(SYSDATE - MAX(bu.collection_date)) AS days_since_last_donation
FROM donors d
LEFT JOIN blood_units bu ON d.donor_id = bu.donor_id
LEFT JOIN transfusions t ON bu.unit_id = t.unit_id
GROUP BY d.donor_id, d.first_name, d.last_name, d.blood_type
HAVING COUNT(bu.unit_id) > 0
ORDER BY lifetime_donations DESC, last_donation_date DESC;


-- Query 3: Monthly Performance Scorecard
-- Purpose: Comprehensive monthly operations summary

WITH monthly_stats AS (
    SELECT 
        TO_CHAR(collection_date, 'YYYY-MM') AS month,
        COUNT(*) AS total_collected,
        SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) AS expired_units,
        SUM(CASE WHEN test_results = 'FAILED' OR test_results = 'CONTAMINATED' THEN 1 ELSE 0 END) AS rejected_units
    FROM blood_units
    WHERE collection_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
    GROUP BY TO_CHAR(collection_date, 'YYYY-MM')
),
monthly_transfusions AS (
    SELECT 
        TO_CHAR(transfusion_date, 'YYYY-MM') AS month,
        COUNT(*) AS total_transfusions
    FROM transfusions
    WHERE transfusion_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
    GROUP BY TO_CHAR(transfusion_date, 'YYYY-MM')
),
monthly_donors AS (
    SELECT 
        TO_CHAR(bu.collection_date, 'YYYY-MM') AS month,
        COUNT(DISTINCT bu.donor_id) AS unique_donors
    FROM blood_units bu
    WHERE bu.collection_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
    GROUP BY TO_CHAR(bu.collection_date, 'YYYY-MM')
)
SELECT 
    ms.month,
    ms.total_collected,
    COALESCE(mt.total_transfusions, 0) AS total_transfused,
    COALESCE(md.unique_donors, 0) AS unique_donors,
    ms.expired_units,
    ms.rejected_units,
    ROUND(ms.expired_units * 100.0 / NULLIF(ms.total_collected, 0), 2) AS expiry_rate_percent,
    ROUND(ms.rejected_units * 100.0 / NULLIF(ms.total_collected, 0), 2) AS rejection_rate_percent,
    ROUND(COALESCE(mt.total_transfusions, 0) * 100.0 / NULLIF(ms.total_collected, 0), 2) AS utilization_rate_percent,
    ROUND(ms.total_collected / NULLIF(COALESCE(md.unique_donors, 0), 0), 2) AS avg_units_per_donor
FROM monthly_stats ms
LEFT JOIN monthly_transfusions mt ON ms.month = mt.month
LEFT JOIN monthly_donors md ON ms.month = md.month
ORDER BY ms.month DESC;
