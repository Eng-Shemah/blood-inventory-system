-- Aggregation: Inventory levels by storage section and temperature
SELECT storage_section, 
       AVG(temperature_monitor) as avg_temp, 
       COUNT(*) as item_count
FROM inventory
GROUP BY storage_section;

-- Subquery: Find donors who have donated more than the average volume
SELECT first_name, last_name, blood_type
FROM donors
WHERE donor_id IN (
    SELECT donor_id 
    FROM blood_units 
    WHERE volume_ml > (SELECT AVG(volume_ml) FROM blood_units)
);