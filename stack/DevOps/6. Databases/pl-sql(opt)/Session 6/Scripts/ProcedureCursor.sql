/*********** Exemplu practic: Ref Cursor   ***********/
DECLARE
  TYPE ref_cursor_type IS REF CURSOR;
  emp_cursor ref_cursor_type;
  v_name employees.first_name%TYPE;
BEGIN
  OPEN emp_cursor FOR   SELECT  first_name FROM employees  WHERE department_id=10;

  LOOP
    FETCH emp_cursor INTO v_name;
    EXIT WHEN emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_name);
  END LOOP;

  CLOSE emp_cursor;
END;
/
/*********** Exemplu practic: Procedure Returning CURSOR  ***********/
CREATE OR REPLACE PROCEDURE get_employees(p_dept_id IN NUMBER, 
                                            p_cursor OUT SYS_REFCURSOR) 
AS
BEGIN
  OPEN p_cursor FOR
    SELECT employee_id, first_name, salary 
    FROM employees 
    WHERE department_id = p_dept_id;
END;
/

--Apelam procedura
DECLARE
    v_cursor SYS_REFCURSOR;
    TYPE emp_record_type IS RECORD(ID employees.employee_id%TYPE, 
                first_name employees.first_name%TYPE,
                salary employees.salary%TYPE);
   
   emp_rec emp_record_type;         
BEGIN
  get_employees(30,v_cursor);
  

  -- Fetch loop
  LOOP
  FETCH v_cursor INTO emp_rec;
  EXIT WHEN v_cursor%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE('ID: ' || emp_rec.id ||
                         ', Name: ' || emp_rec.first_name ||
                         ', Salary: ' || emp_rec.salary);
  END LOOP;
  CLOSE v_cursor; 
END;



/*********** Exemplu practic: Procedure Returning CURSOR  ***********/
CREATE OR REPLACE PROCEDURE get_employees_by_dept(
  p_dept_id IN employees.department_id%TYPE
)
AS
v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT employee_id, first_name
    FROM employees
    WHERE department_id = p_dept_id;
    DBMS_SQL.RETURN_RESULT(v_cursor); --doar din Oracle 12c
END;
/
--apelam procedura
exec get_employees_by_dept(20);
