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