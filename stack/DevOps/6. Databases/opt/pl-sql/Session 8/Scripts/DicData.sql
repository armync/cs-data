/*********** Exemplu practic: DDL Statement (Create Table) ***********/
--Listează toate TABELE deținute de utilizatorul curent /List All TABLES Owned by Current User
select *
from user_tables;

-- Listează toate tabelele la care poate accesa utilizatorul/List All Tables the user can access
select *
from all_tables;

-- Listează toate obiectele deținute de utilizatorul curent/ List All Objects Owned by Current User
select *
from user_objects;

--pentru a vizualiza scriptul unui object(nu tabele)
select *
from user_source
where name='GET_EMPLOYEES_CURSOR';


--pentru a genera scriptul DDL al  obiectului din baza de date Folosind DBMS_METADATA.GET_DDL
SELECT DBMS_METADATA.GET_DDL('TABLE', 'LOCATIONS') FROM DUAL;

--pentru a genera scriptul DDL al obiectului dintr-o anumita schema 
SELECT DBMS_METADATA.GET_DDL('TABLE', 'LOCATIONS', 'HR') FROM DUAL;

--pentru a genera scriptul DDL FUNCTIEI 
SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_EMPLOYEES_BY_DEPTF') FROM DUAL;