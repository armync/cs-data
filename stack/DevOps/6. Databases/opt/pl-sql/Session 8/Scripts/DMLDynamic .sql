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