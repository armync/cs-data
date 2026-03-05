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