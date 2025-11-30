# Database Setup Instructions

## Prerequisites
- Oracle Database 19c or later
- SYSDBA privileges for initial setup
- Sufficient disk space (minimum 1GB)

## Step-by-Step Setup

### 1. Create Pluggable Database
- Connect to CDB as SYSDBA
- Execute `01_database_creation.sql`
- Verify PDB creation: `SELECT name, open_mode FROM v$pdbs;`

### 2. Create Tablespaces
- Connect to the new PDB as blood_admin
- Execute `02_tablespaces.sql`
- Verify: `SELECT tablespace_name, status FROM dba_tablespaces;`

### 3. User Setup
- Execute `03_user_setup.sql`
- Verify users: `SELECT username, account_status FROM dba_users;`

### 4. Configuration
- Execute `04_configuration.sql`
- Restart the PDB for parameters to take effect

## Verification Checklist
- [ ] PDB created and open
- [ ] Tablespaces created and online
- [ ] Users created with correct privileges
- [ ] Memory parameters set
- [ ] Archive logging enabled
