/*********** Exemplu practic: Dynamic SQL with Table Name  ***********/
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE safe_count_rows(p_table_name IN VARCHAR2) IS
  v_sql    VARCHAR2(1000);
  v_count  NUMBER;
BEGIN
  -- Step 1: Validate that the table exists
 /* DECLARE
    v_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X' INTO v_dummy
    FROM user_tables
    WHERE table_name = UPPER(p_table_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid table name.');
  END;*/
   v_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
  -- Step 2: Use DBMS_ASSERT to sanitize object name
  --v_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SQL_OBJECT_NAME(UPPER(p_table_name));
  DBMS_OUTPUT.PUT_LINE(v_sql);
  -- Step 3: Execute the query safely
  EXECUTE IMMEDIATE v_sql INTO v_count;

  -- Output result
  DBMS_OUTPUT.PUT_LINE('Row count in table ' || p_table_name || ': ' || v_count);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

--🚫 If You Didn't Do This...If someone passed:
exec safe_count_rows(' EMPLOYEES_DEMO ''; DROP TABLE EMPLOYEES_DEMO; --''' );

-- Fully Working Injection-Friendly Procedure (DO NOT USE IN REAL APPS)
CREATE OR REPLACE PROCEDURE vulnerable_proc(p_sql IN VARCHAR2) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(p_sql);
  EXECUTE IMMEDIATE p_sql;
END;

---call procedure
vulnerable_proc(' DROP TABLE EMPLOYEES_DEMO --');


SELECT *
FROM EMPLOYEES_DEMO;


