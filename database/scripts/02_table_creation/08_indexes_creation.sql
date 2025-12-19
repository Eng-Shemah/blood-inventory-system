-- Create indexes for better query performance
CREATE INDEX idx_blood_units_donor ON blood_units(donor_id) TABLESPACE blood_index;
CREATE INDEX idx_blood_units_status ON blood_units(status) TABLESPACE blood_index;
CREATE INDEX idx_blood_units_expiry ON blood_units(expiry_date) TABLESPACE blood_index;
CREATE INDEX idx_transfusions_patient ON transfusions(patient_id) TABLESPACE blood_index;
CREATE INDEX idx_transfusions_unit ON transfusions(unit_id) TABLESPACE blood_index;
CREATE INDEX idx_inventory_unit ON inventory(unit_id) TABLESPACE blood_index;
CREATE INDEX idx_shortage_blood_type ON shortage_predictions(blood_type) TABLESPACE blood_index;
CREATE INDEX idx_audit_table_date ON audit_logs(table_name, change_timestamp) TABLESPACE blood_index;