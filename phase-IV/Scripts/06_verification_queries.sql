-- Verify PDB status
SELECT name, open_mode FROM v$pdbs;

-- Verify tablespaces
SELECT tablespace_name, status, contents FROM dba_tablespaces;

-- Verify users
SELECT username, account_status, default_tablespace FROM dba_users;

-- Verify datafiles
SELECT name, bytes/1024/1024 as size_mb FROM v$datafile;