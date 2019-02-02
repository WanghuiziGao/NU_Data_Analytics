-- Week 3 Homework
-- 1. Using set operations, find the employee ID’s of those employees who are not working on any projects.
SELECT emp_id 
FROM employees
MINUS
SELECT emp_id 
FROM workon;

-- 2. Using set operations and sub-query, find the names of those employees who are not working on any projects.
SELECT emp_id 
FROM employees
MINUS
SELECT emp_id 
FROM employees e
WHERE EXISTS
(SELECT *
FROM workon w
WHERE w.emp_id = e.emp_id);

-- 3. Using set operations, find the names of employees who work on both the Eagle and Super Jet projects.
SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
INTERSECT
SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet';

-- 4. Using set operations, find the names of employees who work on either the Eagle or the Super Jet projects.
SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
UNION
SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet';

-- 5. Using non-correlated sub-query, find the names of employees who work on both the Eagle and Super Jet projects.
SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT e.emp_id
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
INTERSECT
SELECT e.emp_id
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet');

SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
AND emp_name IN
(SELECT e.emp_name
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet');

-- 6. Using correlated sub-query, find the names of employees who work on both the Eagle and Super Jet projects.
SELECT emp_name
FROM employees e
WHERE EXISTS
(SELECT emp_name
FROM workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
INTERSECT
SELECT emp_name
FROM workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet');

-- 7. Using sub-query, find the names of employees who work on both the Eagle and Super Jet projects and have a rate greater or equal to 80.
SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT e.emp_id
FROM employees e, workon w, projects p, rate r
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND e.rate_category = r.rate_category
AND p.project_name = 'Eagle'
AND r.rate >= 80
INTERSECT
SELECT e.emp_id
FROM employees e, workon w, projects p, rate r
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND e.rate_category = r.rate_category
AND p.project_name = 'Super Jet'
AND r.rate >= 80);

SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT e.emp_id
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
INTERSECT
SELECT e.emp_id
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Super Jet'
INTERSECT
SELECT e.emp_id
FROM employees e, rate r
WHERE e.rate_category = r.rate_category
AND r.rate >= 80);

WITH emp_project_rate AS
(SELECT e.emp_id, e.emp_name, p.project_name, r.rate
FROM employees e, workon w, projects p, rate r
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND e.rate_category = r.rate_category)
SELECT emp_name
FROM emp_project_rate
WHERE project_name = 'Eagle'
AND rate >= 80
INTERSECT
SELECT emp_name
FROM emp_project_rate
WHERE project_name = 'Super Jet'
AND rate >= 80;















