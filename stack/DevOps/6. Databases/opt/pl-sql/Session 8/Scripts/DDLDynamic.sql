/*********** Exemplu practic: DDL Statement (Create Table) ***********/
drop table temp_table;

SET SERVEROUTPUT ON

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE temp_table (id NUMBER, name VARCHAR2(50))';
END;

select *
from temp_table;