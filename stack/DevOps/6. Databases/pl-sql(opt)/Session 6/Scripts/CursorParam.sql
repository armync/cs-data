/*********** Exemplu practic: Cursor With Parameter  ***********/
DECLARE
  -- Declare the parameterized cursor
  CURSOR emp_cursor (p_dept_id NUMBER) IS
    SELECT employee_id, first_name FROM employees
    WHERE department_id = p_dept_id;

  -- Variables to hold fetched values
  v_emp_id employees.employee_id%TYPE;
  v_name   employees.first_name%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Department ID:10');
  -- Open the cursor with a specific department ID
  OPEN emp_cursor(10);

  -- Fetch loop
  LOOP
    FETCH emp_cursor INTO v_emp_id, v_name;
    EXIT WHEN emp_cursor%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_id || ' - Name: ' || v_name);
  END LOOP;

  CLOSE emp_cursor;
  
  DBMS_OUTPUT.PUT_LINE('Department ID:20');
    -- Open the cursor with a specific department ID
  OPEN emp_cursor(20);

  -- Fetch loop
  LOOP
    FETCH emp_cursor INTO v_emp_id, v_name;
    EXIT WHEN emp_cursor%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_id || ' - Name: ' || v_name);
  END LOOP;

  CLOSE emp_cursor;
END;
/