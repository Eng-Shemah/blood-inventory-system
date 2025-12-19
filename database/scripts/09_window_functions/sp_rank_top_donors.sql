-- WINDOW FUNCTION 1: Rank Donors by Donation Count
-- Purpose: Show top donors with ranking
-- =====================================================
CREATE OR REPLACE PROCEDURE sp_rank_top_donors AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Top Donors Ranking ===');
    
    FOR rec IN (
        SELECT donor_id, first_name, last_name, blood_type, 
               donation_count,
               RANK() OVER (ORDER BY donation_count DESC) AS overall_rank,
               DENSE_RANK() OVER (ORDER BY donation_count DESC) AS dense_rank,
               ROW_NUMBER() OVER (ORDER BY donation_count DESC, donor_id) AS row_num
        FROM (
            SELECT d.donor_id, d.first_name, d.last_name, d.blood_type,
                   COUNT(bu.unit_id) AS donation_count
            FROM donors d
            LEFT JOIN blood_units bu ON d.donor_id = bu.donor_id
            GROUP BY d.donor_id, d.first_name, d.last_name, d.blood_type
        )
        WHERE donation_count > 0
        ORDER BY donation_count DESC
        FETCH FIRST 20 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Rank: ' || rec.overall_rank || ' | ' ||
            rec.first_name || ' ' || rec.last_name || ' | ' ||
            'Donations: ' || rec.donation_count || ' | ' ||
            'Blood Type: ' || rec.blood_type
        );
    END LOOP;
END sp_rank_top_donors;
/