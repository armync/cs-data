/*********** Exemplu practic: DDL Statement (Create Table) ***********/
drop table temp_table;

SET SERVEROUTPUT ON

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE temp_table (id NUMBER, name VARCHAR2(50))';
END;

select *
from temp_table;

/*********** Exemplu practic: DML Statement with Bind Variable ***********/
SET SERVEROUTPUT ON
DECLARE
  v_sql   VARCHAR2(200);
  v_count NUMBER;
BEGIN
  v_sql := 'SELECT COUNT(*) FROM employees WHERE department_id = :dept';
  EXECUTE IMMEDIATE v_sql 
  INTO v_count 
  USING 20;
  DBMS_OUTPUT.PUT_LINE('Total: ' || v_count);
END;

/*********** Exemplu practic: DML Statement with Bind Variable ***********/
SET SERVEROUTPUT ON
DECLARE
  v_sql VARCHAR2(200);
  v_name employees.first_name%TYPE;
BEGIN
  v_sql := 'SELECT first_name FROM employees WHERE employee_id = :id';
  EXECUTE IMMEDIATE v_sql 
  INTO v_name
  USING 100;
  DBMS_OUTPUT.PUT_LINE(v_name);
END;

/*********** Exemplu practic: Dynamic SQL with Table Name  ***********/
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE safe_count_rows(p_table_name IN VARCHAR2) IS
  v_sql    VARCHAR2(1000);
  v_count  NUMBER;
BEGIN
  -- Step 1: Validate that the table exists
 /* DECLARE
    v_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X' INTO v_dummy
    FROM user_tables
    WHERE table_name = UPPER(p_table_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid table name.');
  END;*/
   v_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
  -- Step 2: Use DBMS_ASSERT to sanitize object name
  --v_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SQL_OBJECT_NAME(UPPER(p_table_name));
  DBMS_OUTPUT.PUT_LINE(v_sql);
  -- Step 3: Execute the query safely
  EXECUTE IMMEDIATE v_sql INTO v_count;

  -- Output result
  DBMS_OUTPUT.PUT_LINE('Row count in table ' || p_table_name || ': ' || v_count);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

--🚫 If You Didn't Do This...If someone passed:
exec safe_count_rows(' EMPLOYEES_DEMO ''; DROP TABLE EMPLOYEES_DEMO; --''' );

-- Fully Working Injection-Friendly Procedure (DO NOT USE IN REAL APPS)
CREATE OR REPLACE PROCEDURE vulnerable_proc(p_sql IN VARCHAR2) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(p_sql);
  EXECUTE IMMEDIATE p_sql;
END;

---call procedure
vulnerable_proc(' DROP TABLE EMPLOYEES_DEMO --');


SELECT *
FROM EMPLOYEES_DEMO;

/*********** Exemplu practic: Returning Rows with OPEN FOR (Ref Cursor) ***********/
SET SERVEROUTPUT ON
DECLARE
  v_ref SYS_REFCURSOR;
  v_name employees.first_name%TYPE;
BEGIN
  OPEN v_ref FOR 'SELECT first_name FROM employees WHERE department_id = :1' USING 90;

  LOOP
    FETCH v_ref INTO v_name;
    EXIT WHEN v_ref%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_name);
  END LOOP;

  CLOSE v_ref;
END;

/*********** Exemplu practic: Safe Dynamic SQL with Table + Column + Filter  ***********/
--Table Setup Example
CREATE TABLE employees_demo (
  emp_id    NUMBER,
  emp_name  VARCHAR2(50),
  dept_id   NUMBER
);

CREATE OR REPLACE PROCEDURE safe_filtered_count (
  p_table_name  IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_filter_value IN VARCHAR2
) IS
  v_sql    VARCHAR2(1000);
  v_count  NUMBER;
BEGIN
  -- 1. Check table exists in current schema
  DECLARE
    v_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X' INTO v_dummy
    FROM user_tables
    WHERE table_name = UPPER(p_table_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid table name.');
  END;

  -- 2. Check column exists in that table
  DECLARE
    v_col_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_col_count
    FROM user_tab_columns
    WHERE table_name = UPPER(p_table_name)
      AND column_name = UPPER(p_column_name);

    IF v_col_count = 0 THEN
     NULL;
      RAISE_APPLICATION_ERROR(-20002, 'Invalid column name.');
    END IF;
  END;
   
  -- 3. Build SQL safely
  v_sql := 'SELECT COUNT(*) FROM ' ||
            DBMS_ASSERT.SQL_OBJECT_NAME(UPPER(p_table_name)) ||
           ' WHERE ' ||
            DBMS_ASSERT.ENQUOTE_NAME(UPPER(p_column_name), FALSE) ||
           ' = :1';
  --the query         
  DBMS_OUTPUT.PUT_LINE(v_sql);
  
  -- 4. Execute SQL safely with bind variable
  EXECUTE IMMEDIATE v_sql INTO v_count USING p_filter_value;

  -- 5. Show result
  DBMS_OUTPUT.PUT_LINE('Matching rows: ' || v_count);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


exec safe_filtered_count('employees_demo','dept_id','20');

/*********** Exemplu practic: Call procedure with SYS_REFCURSOR  ***********/
SET SERVEROUTPUT ON
DECLARE
  v_dept_id     NUMBER := 50;
  v_job_id      VARCHAR2(20) := 'ST_CLERK';
  v_sql         VARCHAR2(1000);
  v_cursor      SYS_REFCURSOR;

  v_name        employees.first_name%TYPE;
  v_salary      employees.salary%TYPE;
  v_dep         employees.department_id%TYPE;
BEGIN
  -- Build the dynamic SQL
  v_sql := 'SELECT first_name, salary, :v_dept_id as depId FROM employees ' ||
           'WHERE department_id = :v_dept_id AND job_id = :v_job_id';
  DBMS_OUTPUT.PUT_LINE(v_sql);
  
  -- Open dynamic cursor with multiple bind values
  OPEN v_cursor FOR v_sql USING v_dept_id, v_dept_id, v_job_id;

  -- Fetch and display results
  LOOP
    FETCH v_cursor INTO v_name, v_salary, v_dep;
    --FETCH v_cursor INTO v_name, v_salary, v_dep;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Dep:'||v_dep||' Name: ' || v_name || ' | Salary: ' || v_salary);
  END LOOP;

  CLOSE v_cursor;
END;

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



