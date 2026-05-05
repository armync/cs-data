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