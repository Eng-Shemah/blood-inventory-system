sqlplus / as sysdba

SHOW con_name;

ALTER SESSION SET CONTAINER = CDB$ROOT;

CREATE PLUGGABLE DATABASE tues_27949_robert_bloodInventoryMS_db
ADMIN USER blood_admin IDENTIFIED BY Robert
FILE_NAME_CONVERT = ('D:\oracle21c\oradata\ORCL\pdbseed\', 
                     'D:\oracle21c\oradata\ORCL\tues_27949_robert_bloodInventoryMS_db\');

ALTER PLUGGABLE DATABASE tues_27949_robert_bloodInventoryMS_db OPEN;

ALTER PLUGGABLE DATABASE tues_27949_robert_bloodInventoryMS_db SAVE STATE;