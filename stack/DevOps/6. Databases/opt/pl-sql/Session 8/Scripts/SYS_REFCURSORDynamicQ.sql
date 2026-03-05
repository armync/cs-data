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

