/*********** Exemplu practic: performance  ***********/
--of row-by-row processing vs. bulk processing using BULK COLLECT + FORALL 
SET SERVEROUTPUT ON
--Create a Test Table and Populate Data
-- Drop and recreate test table
DROP TABLE test_data PURGE;

CREATE TABLE test_data (
  id     NUMBER PRIMARY KEY,
  value  VARCHAR2(100)
);

-- Insert 500,000 test rows
BEGIN
  FOR i IN 1 .. 500000 LOOP
    INSERT INTO test_data VALUES (i, 'Row ' || i);
  END LOOP;
  COMMIT;
END;
/

--Example 1: Row-by-Row Processing (Slow)
SET SERVEROUTPUT ON
DECLARE
  v_start   NUMBER;
  v_end     NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;

  FOR rec IN (SELECT id FROM test_data) LOOP
    UPDATE test_data 
    SET value = value || ' updated' 
    WHERE id = rec.id;
  END LOOP;

  COMMIT;

  v_end := DBMS_UTILITY.GET_TIME;
  DBMS_OUTPUT.PUT_LINE('Row-by-row time (secs): ' || TO_CHAR((v_end - v_start)/100));
END;
/

-- Example 2: BULK COLLECT + FORALL (Fast)
DECLARE
  TYPE t_id_tab IS TABLE OF test_data.id%TYPE;
  v_ids   t_id_tab;

  v_start   NUMBER;
  v_end     NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;

  -- Bulk fetch
  SELECT id BULK COLLECT INTO v_ids FROM test_data;

  -- Bulk update
  FORALL i IN v_ids.FIRST .. v_ids.LAST
    UPDATE test_data SET value = value || ' again' WHERE id = v_ids(i);

  COMMIT;

  v_end := DBMS_UTILITY.GET_TIME;
  DBMS_OUTPUT.PUT_LINE('BULK COLLECT + FORALL time (secs): ' || TO_CHAR((v_end - v_start)/100));
END;
/


