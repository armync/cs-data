/*********** Exemplu practic: FORALL + BULK_EXCEPTIONS  ***********/
SET SERVEROUTPUT ON
---Setup (Tabl si Date de testare)
CREATE TABLE test_employees (
  emp_id NUMBER PRIMARY KEY,
  name   VARCHAR2(50)
);

-- Insert test data
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO test_employees VALUES (i, 'Emp_' || i);
  END LOOP;
  COMMIT;
END;
/

select *
from test_employees;

SET SERVEROUTPUT ON
DECLARE
  TYPE emp_id_table IS TABLE OF NUMBER;
  v_emp_ids emp_id_table := emp_id_table(1, 2, 999, 3, 888, 4, 5,99999999); -- 999 and 888 don't exist

BEGIN
  -- Attempt to delete all listed employee IDs
  FORALL i IN v_emp_ids.FIRST .. v_emp_ids.LAST SAVE EXCEPTIONS
    DELETE FROM test_employees WHERE emp_id = v_emp_ids(i);

  DBMS_OUTPUT.PUT_LINE('All deletions attempted. Successful deletes: ' || SQL%ROWCOUNT);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Some deletions failed.');
    FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Error at index ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                           ' (emp_id = ' || v_emp_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || '): ' ||
                           'Error code = ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE);
    END LOOP;
END;
/