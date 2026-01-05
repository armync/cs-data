/* psql */

-- all employees and the department they belong to
SELECT string_agg(first_name || ' '  || last_name, ', ') AS employees_name, dp.department_name
FROM employees emp
JOIN departments dp
ON emp.department_id = dp.department_id
GROUP BY dp.department_name;

-- all employees and the department they belong to, regardless of whether they are part of a department or not
SELECT string_agg(first_name || ' '  || last_name, ', ') AS employees_name, dp.department_name
FROM employees emp
LEFT JOIN departments dp
ON emp.department_id = dp.department_id
GROUP BY dp.department_name;

-- the maximum salary per department
SELECT MAX(salary), dp.department_name
FROM employees emp
LEFT JOIN departments dp
ON dp.department_id = emp.department_id
GROUP BY dp.department_name
ORDER BY MAX(salary) DESC;

-- employees and their length of service in the company, ordered by seniority, with the most senior first
SELECT first_name, last_name, CURRENT_DATE - hire_date AS timespan
FROM employees
ORDER BY timespan DESC;

-- the names of managers and the number of employees reporting to each manager
SELECT CONCAT(e1.first_name, ' ', e1.last_name) as manager, COUNT(e1.employee_id)
FROM employees e1
JOIN employees e2
ON e1.employee_id = e2.manager_id
GROUP BY manager;

-- employees whose salary is between 2500 and 3000
SELECT DISTINCT first_name, last_name, salary
FROM employees
WHERE SALARY BETWEEN 2500 AND 3000;

-- employees whose salary is higher than the department average
SELECT CONCAT(e1.first_name, ' ',e1.last_name), e1.salary, d.department_id
FROM employees e1
JOIN departments d
ON e1.department_id = d.department_id
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY d.department_name, e1.salary DESC;

-- departments where the total salary amount is less than 25,000 or the average salary is less than 3,000
SELECT d.department_name, SUM(salary), AVG(salary)
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING SUM(salary) < 25000 OR AVG(salary) < 3000;

-- the list of employees who have at least one dependent
SELECT e.first_name, e.last_name, COUNT(d.dependent_id)
FROM employees e
RIGHT JOIN dependents d
ON e.employee_id = d.employee_id
GROUP BY (e.first_name, e.last_name);

-- all employees and, for each, the name of the manager they report to
SELECT e1.first_name, e1.last_name, CONCAT(e2.first_name,'',e2.last_name) manager
FROM employees e1
LEFT JOIN employees e2
ON e1.manager_id=e2.employee_id;