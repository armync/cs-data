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