/*********** Exemplu practic: Audit Trigger -Logs changes on the employees table ***********/
--------------------------------------------------------
--  DDL for  Audit Table AUDIT_LOG
--------------------------------------------------------

CREATE TABLE "HR"."AUDIT_LOG" 
   (	"EMPLOYEE_ID" NUMBER(6,0), 
        "OLD_SALARY" NUMBER(8,2), 
        "NEW_SALARY" NUMBER(8,2), 
        "CHANGE_DATE" DATE
   ) 
/*********** Exemplu practic: Audit Trigger -Logs changes on the employees table ***********/
CREATE OR REPLACE TRIGGER trg_audit_salary
AFTER UPDATE  OF salary ON employees
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (employee_id, old_salary, new_salary, change_date)
  VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/
/*Daca e necesar de golit tabelul**/
--TRUNCATE TABLE audit_log;

SELECT    *
FROM  audit_log;

-- Modificam datele
UPDATE employees
SET  salary = 16000
WHERE employee_id = 150;
COMMIT;

--vefificam Auditul
SELECT    *
FROM  audit_log;

--------------------------------------------------------
--  DDL for  Audit Table EVALUATIONS_LOG
--------------------------------------------------------
CREATE TABLE EVALUATIONS_LOG ( 
	log_date DATE,
    action VARCHAR2(50));
    
/*********** Exemplu practic: Audit Trigger -Logs any changes on the employees table  ***********/
--avem si INSERT si UPDATE si DELETE
CREATE OR REPLACE TRIGGER EVAL_CHANGE_TRIGGER
  AFTER INSERT OR UPDATE OR DELETE  ON EMPLOYEES
DECLARE
  log_action  EVALUATIONS_LOG.action%TYPE;
BEGIN
  IF INSERTING THEN
    log_action := 'Insert';
  ELSIF UPDATING THEN
    log_action := 'Update';
  ELSIF DELETING THEN
    log_action := 'Delete';
  ELSE
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  END IF;

  INSERT INTO EVALUATIONS_LOG (log_date, action)
    VALUES (SYSDATE, log_action);
END;


/*********** Exemplu practic: System Trigger Example ***********/
CREATE OR REPLACE TRIGGER trg_on_logon
AFTER LOGON ON DATABASE
BEGIN
  INSERT INTO log_table (username, login_time)
  VALUES (USER, SYSDATE);
END;
/

--------------------------------------------------------
--  DDL for  Audit Table EVALUATIONS_LOG
--------------------------------------------------------
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE department_id = 30;

/*********** Exemplu practic: INSTEAD OF Trigger Example (For Views)  ***********/
CREATE OR REPLACE TRIGGER trg_update_view
INSTEAD OF UPDATE ON emp_view
FOR EACH ROW
BEGIN
  UPDATE employees
  SET salary = :NEW.salary
  WHERE employee_id = :OLD.employee_id;
END;
/

--verificam stare curenta
select *
from emp_view;


-- Modificam datele
UPDATE emp_view
SET  salary = 16000
WHERE employee_id = 115;
COMMIT;

--verificam date modificate
select *
from emp_view;