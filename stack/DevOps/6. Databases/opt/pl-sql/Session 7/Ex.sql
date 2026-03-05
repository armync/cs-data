/*********** Exemplu practic: BULK + LIMIT  ***********/
set SERVEROUTPUT on
DECLARE
  CURSOR emp_cur IS SELECT employee_id FROM employees;
  TYPE t_id_tab IS TABLE OF employees.employee_id%TYPE;
  v_ids t_id_tab;
  v_packetLimit numeric:=70;
BEGIN
  OPEN emp_cur;
  LOOP
    FETCH emp_cur BULK COLLECT INTO v_ids LIMIT v_packetLimit;
    EXIT WHEN v_ids.COUNT = 0;
    DBMS_OUTPUT.PUT_LINE('Processam cate:************ ' || v_ids.COUNT);
    FOR i IN 1 .. v_ids.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_ids(i));
    END LOOP;
  END LOOP;
  CLOSE emp_cur;
END;
/
/*********** Exemplu practic: BULK + RETURNING  ***********/
set SERVEROUTPUT on
DECLARE
   TYPE ids_t IS TABLE OF employees.employee_id%TYPE;
   l_ids ids_t;
BEGIN
   UPDATE employees
      SET last_name = UPPER (last_name)
    WHERE department_id = 20
      RETURNING employee_id BULK COLLECT INTO l_ids;

   FOR indx IN 1 .. l_ids.COUNT 
   LOOP
      DBMS_OUTPUT.PUT_LINE (l_ids (indx));
   END LOOP;
ROLLBACK;
END;
/

/*********** Exemplu practic: BULK + Function  ***********/
set SERVEROUTPUT on
DECLARE
   TYPE ids_t IS TABLE OF employees.employee_id%TYPE;
   l_ids ids_t;
BEGIN
   UPDATE employees
      SET last_name = UPPER (last_name)
    WHERE department_id = 20
      RETURNING employee_id BULK COLLECT INTO l_ids;

   FOR indx IN 1 .. l_ids.COUNT 
   LOOP
      DBMS_OUTPUT.PUT_LINE (l_ids (indx));
   END LOOP;
ROLLBACK;
END;
/
--1. Create Object and Collection Types
-- Row type
CREATE OR REPLACE TYPE emp_row_type AS OBJECT (
  emp_id   NUMBER,
  emp_name VARCHAR2(100)
);
/

-- Table of rows
CREATE OR REPLACE TYPE emp_table_type AS TABLE OF emp_row_type;
/
--2. Create the Table Function
CREATE OR REPLACE FUNCTION get_employees_by_dept2 (p_dept_id NUMBER)
RETURN emp_table_type
IS
  v_result emp_table_type := emp_table_type();
BEGIN
  /*FOR rec IN (SELECT employee_id, first_name || ' ' || last_name AS emp_name
              FROM employees
              WHERE department_id = p_dept_id) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := emp_row_type(rec.employee_id, rec.emp_name);
  END LOOP;*/
  SELECT emp_row_type(employee_id, first_name || ' ' || last_name)
  BULK COLLECT INTO v_result
  FROM employees
  WHERE department_id = p_dept_id;

  RETURN v_result;
END;
/

--3. Query the Function Like a Table

SELECT * FROM TABLE(get_employees_by_dept2(30));


CREATE OR REPLACE FUNCTION get_employees_by_dept (p_dept_id NUMBER)
RETURN emp_table_type
IS
  v_result emp_table_type := emp_table_type();
BEGIN
  FOR rec IN (SELECT employee_id, first_name || ' ' || last_name AS emp_name
              FROM employees
              WHERE department_id = p_dept_id) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := emp_row_type(rec.employee_id, rec.emp_name);
  END LOOP;

  RETURN v_result;
END;
/
--3. Query the Function Like a Table

SELECT * FROM TABLE(get_employees_by_dept(20));

-- Returns a rowset just like querying a real table.

-- Optional: PIPELINED Table Function (for streaming)
CREATE OR REPLACE FUNCTION get_employees_pipe (p_dept_id NUMBER)
RETURN emp_table_type
PIPELINED
IS
BEGIN
  FOR rec IN (SELECT employee_id, first_name || ' ' || last_name AS emp_name
              FROM employees
              WHERE department_id = p_dept_id) LOOP
    PIPE ROW(emp_row_type(rec.employee_id, rec.emp_name));
  END LOOP;

  RETURN;
END;
/

SELECT * FROM TABLE(get_employees_pipe(20));

--Same usage, better performance for large datasets, since rows are returned one-by-one (streamed).

/*********** Exemplu practic: FORALL + BULK_EXCEPTIONS  ***********/
SET SERVEROUTPUT ON
---Setup (Tabl si Date de testare)
CREATE TABLE test_employees (
  emp_id NUMBER PRIMARY KEY,
  name   VARCHAR2(50)
);

-- Insert test data
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO test_employees VALUES (i, 'Emp_' || i);
  END LOOP;
  COMMIT;
END;
/

select *
from test_employees;

SET SERVEROUTPUT ON
DECLARE
  TYPE emp_id_table IS TABLE OF NUMBER;
  v_emp_ids emp_id_table := emp_id_table(1, 2, 999, 3, 888, 4, 5,99999999); -- 999 and 888 don't exist

BEGIN
  -- Attempt to delete all listed employee IDs
  FORALL i IN v_emp_ids.FIRST .. v_emp_ids.LAST SAVE EXCEPTIONS
    DELETE FROM test_employees WHERE emp_id = v_emp_ids(i);

  DBMS_OUTPUT.PUT_LINE('All deletions attempted. Successful deletes: ' || SQL%ROWCOUNT);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Some deletions failed.');
    FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Error at index ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                           ' (emp_id = ' || v_emp_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || '): ' ||
                           'Error code = ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE);
    END LOOP;
END;
/

/*********** Exemplu practic: performance  ***********/
--of row-by-row processing vs. bulk processing using BULK COLLECT + FORALL 
SET SERVEROUTPUT ON
--Create a Test Table and Populate Data
-- Drop and recreate test table
DROP TABLE test_data PURGE;

CREATE TABLE test_data (
  id     NUMBER PRIMARY KEY,
  value  VARCHAR2(100)
);

-- Insert 500,000 test rows
BEGIN
  FOR i IN 1 .. 500000 LOOP
    INSERT INTO test_data VALUES (i, 'Row ' || i);
  END LOOP;
  COMMIT;
END;
/

--Example 1: Row-by-Row Processing (Slow)
SET SERVEROUTPUT ON
DECLARE
  v_start   NUMBER;
  v_end     NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;

  FOR rec IN (SELECT id FROM test_data) LOOP
    UPDATE test_data 
    SET value = value || ' updated' 
    WHERE id = rec.id;
  END LOOP;

  COMMIT;

  v_end := DBMS_UTILITY.GET_TIME;
  DBMS_OUTPUT.PUT_LINE('Row-by-row time (secs): ' || TO_CHAR((v_end - v_start)/100));
END;
/

-- Example 2: BULK COLLECT + FORALL (Fast)
DECLARE
  TYPE t_id_tab IS TABLE OF test_data.id%TYPE;
  v_ids   t_id_tab;

  v_start   NUMBER;
  v_end     NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;

  -- Bulk fetch
  SELECT id BULK COLLECT INTO v_ids FROM test_data;

  -- Bulk update
  FORALL i IN v_ids.FIRST .. v_ids.LAST
    UPDATE test_data SET value = value || ' again' WHERE id = v_ids(i);

  COMMIT;

  v_end := DBMS_UTILITY.GET_TIME;
  DBMS_OUTPUT.PUT_LINE('BULK COLLECT + FORALL time (secs): ' || TO_CHAR((v_end - v_start)/100));
END;
/


