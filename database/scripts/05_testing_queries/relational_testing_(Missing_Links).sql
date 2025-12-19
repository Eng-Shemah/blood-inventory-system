-- Find Blood Units that are NOT yet recorded in Inventory
SELECT unit_id, blood_type, status
FROM blood_units bu
WHERE NOT EXISTS (
    SELECT 1 FROM inventory i WHERE i.unit_id = bu.unit_id
);