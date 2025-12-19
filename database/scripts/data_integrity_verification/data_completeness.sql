-- Check row counts for all main tables
SELECT 'Donors' as table_name, COUNT(*) as row_count FROM donors
UNION ALL
SELECT 'Blood Units', COUNT(*) FROM blood_units
UNION ALL
SELECT 'Patients', COUNT(*) FROM patients
UNION ALL
SELECT 'Inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'Transfusions', COUNT(*) FROM transfusions
UNION ALL
SELECT 'Shortage Predictions', COUNT(*) FROM shortage_predictions
UNION ALL
SELECT 'Audit Logs', COUNT(*) FROM audit_logs;

-- Retrieve first 5 donors to verify column formatting
SELECT donor_id, first_name, last_name, blood_type, health_status 
FROM donors 
WHERE ROWNUM <= 5;