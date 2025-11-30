CREATE USER blood_ms_user IDENTIFIED BY user123456
  2  DEFAULT TABLESPACE blood_data
  3  TEMPORARY TABLESPACE blood_temp
  4  QUOTA UNLIMITED ON blood_data
  5  QUOTA UNLIMITED ON blood_index;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE,
  2        CREATE TRIGGER, CREATE VIEW, CREATE TYPE TO blood_ms_user;

SELECT username, account_status, default_tablespace, created
  2  FROM dba_users
  3  WHERE username = 'BLOOD_MS_USER';