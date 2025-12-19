ALTER SESSION SET CONTAINER = tues_27949_robert_bloodInventoryMS_db;

-- 1. MEMORY PARAMETERS (PDB-modifiable)
ALTER SYSTEM SET sga_target=512M SCOPE=both;
ALTER SYSTEM SET pga_aggregate_target=256M SCOPE=both;

-- 2. SESSION AND PROCESS PARAMETERS
ALTER SYSTEM SET processes=150 SCOPE=both;
ALTER SYSTEM SET sessions=200 SCOPE=both;
ALTER SYSTEM SET transactions=300 SCOPE=both;

-- 3. OPTIMIZER PARAMETERS
ALTER SYSTEM SET optimizer_mode=ALL_ROWS SCOPE=both;
ALTER SYSTEM SET cursor_sharing=EXACT SCOPE=both;

-- 4. SECURITY PARAMETERS
ALTER SYSTEM SET sec_case_sensitive_logon=TRUE SCOPE=both;

-- 5. AUDITING PARAMETERS (for Phase VII)
ALTER SYSTEM SET audit_trail=DB SCOPE=spfile;

-- 6. PERFORMANCE PARAMETERS
ALTER SYSTEM SET db_file_multiblock_read_count=16 SCOPE=both;
ALTER SYSTEM SET sort_area_size=65536 SCOPE=both;

-- Display current configuration
PROMPT === Current Database Configuration ===
SELECT name, value, ispdb_modifiable 
FROM v$system_parameter 
WHERE name IN (
    'sga_target', 
    'pga_aggregate_target', 
    'processes', 
    'sessions',
    'optimizer_mode',
    'audit_trail'
);