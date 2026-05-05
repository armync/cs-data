-- Creating the dimension table
CREATE TABLE dim_employees (
  emp_sk        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  employee_id   NUMBER,
  first_name    VARCHAR2(50),
  last_name     VARCHAR2(50),
  email         VARCHAR2(100),
  hire_date     DATE,
  job_id        VARCHAR2(10),
  start_date    DATE,
  end_date      DATE,
  is_current    CHAR(1) CHECK (is_current IN ('Y', 'N'))
);

-- Setting up CDC for Employees
-- Creating the change set
BEGIN
  DBMS_CDC_PUBLISH.CREATE_CHANGE_SET(
    change_set_name     => 'cs_employees',
    description         => 'Change set for HR.EMPLOYEES',
    change_source_name  => 'HOTLOG_SOURCE',
    stop_on_ddl         => 'Y'
  );
END;
/

-- Creating the change table
BEGIN
  DBMS_CDC_PUBLISH.CREATE_CHANGE_TABLE(
    owner               => 'HR',
    change_table_name   => 'ct_employees',
    change_set_name     => 'cs_employees',
    source_schema       => 'HR',
    source_table        => 'EMPLOYEES',
    column_type_list    => 'EMPLOYEE_ID NUMBER, FIRST_NAME VARCHAR2(20), LAST_NAME VARCHAR2(25), EMAIL VARCHAR2(25), HIRE_DATE DATE, JOB_ID VARCHAR2(10)',
    capture_values      => 'both',
    rs_id               => 'Y',
    row_id              => 'N',
    user_id             => 'N',
    timestamp           => 'Y',
    object_id           => 'N',
    source_colmap       => 'Y',
    target_colmap       => 'Y'
  );
END;
/

-- Enabling the changle table
BEGIN
  DBMS_CDC_PUBLISH.ENABLE_CHANGE_TABLE(
    owner               => 'HR',
    change_table_name   => 'ct_employees'
  );
END;
/

-- Creating the CDC subscription
BEGIN
  DBMS_CDC_SUBSCRIBE.CREATE_SUBSCRIPTION(
    change_set_name     => 'cs_employees',
    description         => 'Subscription for HR.EMPLOYEES changes',
    subscription_name   => 'sub_employees'
  );

  DBMS_CDC_SUBSCRIBE.SUBSCRIBE(
    subscription_name   => 'sub_employees',
    source_schema       => 'HR',
    source_table        => 'EMPLOYEES',
    column_list         => 'EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID',
    change_table_name   => 'ct_employees'
  );

  DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION(
    subscription_name => 'sub_employees'
  );
END;
/

-- Simulating changes
UPDATE hr.employees
SET job_id = 'AC_ACCOUNT'
WHERE employee_id = 100;
COMMIT;

-- SCD2 logic
DECLARE
  CURSOR c IS
    SELECT * FROM HR.ct_employees
    WHERE subscription_name = 'sub_employees';

BEGIN
  FOR rec IN c LOOP
    IF rec.dml_type = 'I' THEN
      INSERT INTO dim_employees (
        employee_id, first_name, last_name, email, hire_date, job_id,
        start_date, end_date, is_current
      ) VALUES (
        rec.employee_id, rec.first_name, rec.last_name, rec.email, rec.hire_date, rec.job_id,
        SYSDATE, NULL, 'Y'
      );

    ELSIF rec.dml_type = 'U' THEN
      -- Expire current record
      UPDATE dim_employees
      SET end_date = SYSDATE, is_current = 'N'
      WHERE employee_id = rec.employee_id AND is_current = 'Y';

      -- Insert new version
      INSERT INTO dim_employees (
        employee_id, first_name, last_name, email, hire_date, job_id,
        start_date, end_date, is_current
      ) VALUES (
        rec.employee_id, rec.first_name, rec.last_name, rec.email, rec.hire_date, rec.job_id,
        SYSDATE, NULL, 'Y'
      );
    END IF;
  END LOOP;
END;
/

-- Query to see the changes history
SELECT * FROM dim_employees ORDER BY employee_id, start_date;