-- WINDOW FUNCTION 3: Partition by Blood Type
-- Purpose: Show inventory distribution with percentages
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_inventory_distribution AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Blood Inventory Distribution ===');
    
    FOR rec IN (
        SELECT blood_type,
               available_units,
               ROUND(available_units * 100.0 / SUM(available_units) OVER (), 2) AS percentage,
               RANK() OVER (ORDER BY available_units DESC) AS availability_rank
        FROM (
            SELECT blood_type, COUNT(*) AS available_units
            FROM blood_units
            WHERE status = 'AVAILABLE'
            AND expiry_date > SYSDATE
            GROUP BY blood_type
        )
        ORDER BY available_units DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Type: ' || RPAD(rec.blood_type, 4) || ' | ' ||
            'Units: ' || LPAD(rec.available_units, 5) || ' | ' ||
            'Percentage: ' || LPAD(rec.percentage || '%', 8) || ' | ' ||
            'Rank: ' || rec.availability_rank
        );
    END LOOP;
END sp_inventory_distribution;
/