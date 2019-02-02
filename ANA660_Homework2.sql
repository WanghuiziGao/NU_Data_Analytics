-- Week2 Homework
-- 1. Use non-correlated sub-query, find the names of employees who are not working on any projects.
SELECT e.emp_name
FROM employees e
WHERE e.emp_id NOT IN
(SELECT DISTINCT w.emp_id 
FROM workon w);

-- 2. Use correlated sub-query, find the names of employees who are not working on any projects.
SELECT emp_name
FROM employees e
WHERE NOT EXISTS
(SELECT 'X'
FROM workon
WHERE emp_id = e.emp_id);

-- 3. Use non-correlated sub-query, find the names of the employees who work on projects that are located in the same city where the employees are located.
SELECT e.emp_id, e.emp_name, e.emp_city, p.project_name, p.project_city
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_city = e.emp_city;

SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT e.emp_id
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_city = e.emp_city);

-- 4. Use correlated sub-query, find the names of the employees who work on projects that are located in the same city where the employees are located.
SELECT emp_name
FROM employees e
WHERE EXISTS
(SELECT 'X'
FROM projects p JOIN workon w
ON p.project_number = w.project_number
WHERE project_city = e.emp_city);

-- 5. Use sub-query, find the names of the employees with the highest rate.
SELECT emp_name
FROM employees e, rate r
WHERE e.rate_category = r.rate_category
AND rate = 
(SELECT MAX(rate)
FROM employees e, rate r
WHERE e.rate_category = r.rate_category);

-- 6. Use sub-query and the ALL operator, find the names of the employees with the highest rate.
SELECT emp_name
FROM employees e, rate r
WHERE e.rate_category = r.rate_category
AND rate >= ALL
(SELECT rate
FROM employees e, rate r
WHERE e.rate_category = r.rate_category);

-- 7. Use inline views and sub-query, find the names of employees with the highest rate.
SELECT emp_name
FROM 
(SELECT *
FROM employees e, rate r
WHERE e.rate_category = r.rate_category
ORDER BY rate DESC)
WHERE ROWNUM = 1;

SELECT emp_name
FROM 
(SELECT *
FROM employees e, rate r
WHERE e.rate_category = r.rate_category)
WHERE rate = 
(SELECT MAX(rate)
FROM employees e, rate r
WHERE e.rate_category = r.rate_category);

-- 8. Use self-join, find the names of the employees who work on more than one project.
SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT DISTINCT w1.emp_id
FROM workon w1, workon w2
WHERE w1.emp_id = w2.emp_id
AND w1.project_number <> w2.project_number);

-- 9. Use non-correlated sub-query, find the names of the employees who work on more than one project.
SELECT e.emp_name, COUNT(w.project_number) COUNT_PROJECT
FROM employees e, workon w
WHERE w.emp_id = e.emp_id
GROUP BY e.emp_name, w.emp_id
HAVING COUNT(w.project_number) > 1
ORDER BY e.emp_name DESC;

SELECT emp_name
FROM employees
WHERE emp_id IN
(SELECT emp_id
FROM workon
GROUP BY emp_id
HAVING COUNT(project_number) > 1);

-- 10. Use correlated sub-query, find the names of the employees who work on more than one project.
SELECT emp_name
FROM employees e
WHERE 1 <
(SELECT COUNT(project_number)
FROM workon
WHERE emp_id = e.emp_id);



