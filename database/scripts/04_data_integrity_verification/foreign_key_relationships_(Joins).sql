-- Multi-table Join: Trace a unit from Donor to Patient
SELECT 
    d.first_name || ' ' || d.last_name AS Donor_Name,
    bu.blood_type,
    bu.status AS Unit_Status,
    p.first_name || ' ' || p.last_name AS Recipient_Patient,
    t.transfusion_date
FROM donors d
JOIN blood_units bu ON d.donor_id = bu.donor_id
JOIN transfusions t ON bu.unit_id = t.unit_id
JOIN patients p ON t.patient_id = p.patient_id
WHERE t.transfusion_status = 'COMPLETED';