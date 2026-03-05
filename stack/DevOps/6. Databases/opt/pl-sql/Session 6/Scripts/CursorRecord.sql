/*********** Exemplu practic: Cursor with %ROWTYPE Record  ***********/
SET SERVEROUTPUT ON;
DECLARE
  -- Declare a cursor
  CURSOR emp_cursor IS
    SELECT employee_id AS id, first_name AS NAME, salary FROM employees;

  -- Declare a record variable using %ROWTYPE
  emp_rec emp_cursor%ROWTYPE;

BEGIN
  -- Open the cursor
  OPEN emp_cursor;

  -- Fetch loop
  LOOP
    FETCH emp_cursor INTO emp_rec;
    EXIT WHEN emp_cursor%NOTFOUND;

    -- Use the record fields
    DBMS_OUTPUT.PUT_LINE('ID: ' || emp_rec.id ||
                         ', Name: ' || emp_rec.NAME ||
                         ', Salary: ' || emp_rec.salary);
  END LOOP;

  -- Close the cursor
  CLOSE emp_cursor;
END;
/

/*********** Exemplu practic: Cursor with FOR  ***********/
SET SERVEROUTPUT ON;
BEGIN
   FOR emp_rec IN (SELECT employee_id AS id, first_name AS NAME, salary FROM employees)
   LOOP
    -- Use the record fields
    DBMS_OUTPUT.PUT_LINE('ID: ' || emp_rec.id ||
                         ', Name: ' || emp_rec.NAME ||
                         ', Salary: ' || emp_rec.salary);
  END LOOP;
END;