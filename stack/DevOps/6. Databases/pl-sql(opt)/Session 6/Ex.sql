/*********** Exemplu practic: Explicit Cursor in Action  ***********/
DECLARE
  -- Declare the cursor
  CURSOR emp_cursor IS
    SELECT employee_id, first_name, salary FROM employees;

  -- Variables to hold fetched values
  v_emp_id   employees.employee_id%TYPE;
  v_name     employees.first_name%TYPE;
  v_salary   employees.salary%TYPE;

BEGIN
  -- Open the cursor
  OPEN emp_cursor;

  -- Fetch rows one-by-one in a loop
  LOOP
    FETCH emp_cursor INTO v_emp_id, v_name, v_salary;
    EXIT WHEN emp_cursor%NOTFOUND;

    -- Process each row
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_id || ' | Name: ' || v_name || ' | Salary: ' || v_salary);
  END LOOP;

  -- Close the cursor
  CLOSE emp_cursor;
END;
/