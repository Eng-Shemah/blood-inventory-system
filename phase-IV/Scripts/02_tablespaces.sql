ALTER SESSION SET CONTAINER = tues_27949_robert_bloodInventoryMS_db;

SELECT tablespace_name FROM dba_tablespaces;

CREATE TABLESPACE blood_data
  2  DATAFILE 'blood_data01.dbf'
  3  SIZE 100M
  4  AUTOEXTEND ON NEXT 50M
  5  MAXSIZE 500M;

CREATE TABLESPACE blood_index
  2  DATAFILE 'blood_index01.dbf'
  3  SIZE 50M
  4  AUTOEXTEND ON NEXT 25M
  5  MAXSIZE 300M;

CREATE TEMPORARY TABLESPACE blood_temp
  2  TEMPFILE 'blood_temp01.dbf'
  3  SIZE 50M
  4  AUTOEXTEND ON NEXT 25M
  5  MAXSIZE 200M;

SELECT tablespace_name FROM dba_tablespaces;