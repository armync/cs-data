/*********** Exemplu practic: BULK + RETURNING  ***********/
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