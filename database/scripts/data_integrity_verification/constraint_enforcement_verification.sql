SELECT blood_type, COUNT(*) as unit_count
FROM blood_units
GROUP BY blood_type
ORDER BY unit_count DESC;

-- Check Health Status logic
SELECT health_status, is_active, COUNT(*) 
FROM donors 
GROUP BY health_status, is_active;