/*********** Exemplu practic: Safe Dynamic SQL with Table + Column + Filter  ***********/
--Table Setup Example
CREATE TABLE employees_demo (
  emp_id    NUMBER,
  emp_name  VARCHAR2(50),
  dept_id   NUMBER
);

CREATE OR REPLACE PROCEDURE safe_filtered_count (
  p_table_name  IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_filter_value IN VARCHAR2
) IS
  v_sql    VARCHAR2(1000);
  v_count  NUMBER;
BEGIN
  -- 1. Check table exists in current schema
  DECLARE
    v_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X' INTO v_dummy
    FROM user_tables
    WHERE table_name = UPPER(p_table_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid table name.');
  END;

  -- 2. Check column exists in that table
  DECLARE
    v_col_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_col_count
    FROM user_tab_columns
    WHERE table_name = UPPER(p_table_name)
      AND column_name = UPPER(p_column_name);

    IF v_col_count = 0 THEN
     NULL;
      RAISE_APPLICATION_ERROR(-20002, 'Invalid column name.');
    END IF;
  END;
   
  -- 3. Build SQL safely
  v_sql := 'SELECT COUNT(*) FROM ' ||
            DBMS_ASSERT.SQL_OBJECT_NAME(UPPER(p_table_name)) ||
           ' WHERE ' ||
            DBMS_ASSERT.ENQUOTE_NAME(UPPER(p_column_name), FALSE) ||
           ' = :1';
  --the query         
  DBMS_OUTPUT.PUT_LINE(v_sql);
  
  -- 4. Execute SQL safely with bind variable
  EXECUTE IMMEDIATE v_sql INTO v_count USING p_filter_value;

  -- 5. Show result
  DBMS_OUTPUT.PUT_LINE('Matching rows: ' || v_count);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


exec safe_filtered_count('employees_demo','dept_id','20');



