/* drop tables */
drop table workon;
drop table projects;
drop table employees;
drop table rate;

/* create tables */
create table projects
(
project_number NUMBER primary key,
project_name   varchar2(30) UNIQUE NOT NULL,
project_city   varchar2(20) NOT NULL
);

create table rate
(
rate_category  varchar2(10) primary key,
rate           NUMBER NOT NULL
);

create table employees
(
emp_id         NUMBER primary key,
emp_name       varchar2(30) NOT NULL,
rate_category  varchar2(10) CONSTRAINT fk_ratecategory REFERENCES rate(rate_category) ON DELETE CASCADE,
emp_city       varchar2(20) NOT NULL
);

create table workon
(
project_number NUMBER CONSTRAINT fk_projectnumber REFERENCES projects(project_number) ON DELETE CASCADE,
emp_id         NUMBER CONSTRAINT fk_empid         REFERENCES employees(emp_id)        ON DELETE CASCADE,
CONSTRAINT pk_workon primary key (project_number, emp_id)
);

commit;

/* loading data into tables */
insert into projects values (1,'Eagle',    'NY');
insert into projects values (2,'Super Jet','LA');

insert into rate values ('A',100);
insert into rate values ('B',80);
insert into rate values ('C',60);
insert into rate values ('D',50);

insert into employees values (10,'Smith',  'B','NY');
insert into employees values (11,'eSmith', 'C','SF');
insert into employees values (20,'Smithe', 'C','LA');
insert into employees values (15,'eSmithe','D','SD');

insert into workon values (1,10);
insert into workon values (1,11);
insert into workon values (2,10);
insert into workon values (2,20);
insert into workon values (2,11);

commit;

/* check tables and data */
SELECT * FROM projects;
SELECT * FROM rate;
SELECT * FROM employees;
SELECT * FROM workon;

/* assignment questions */
-- 1. Find the names of employees who work on the Eagle project and has a rate greater than 70.
SELECT e.emp_id, e.emp_name, p.project_name, r.rate  
FROM employees e, rate r, workon w, projects p
WHERE e.rate_category = r.rate_category
AND e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle'
AND r.rate > 70;

-- 2. Find the names of the projects that have employees with rates greater or equal to 80.
SELECT p.project_number, p.project_name, e.emp_name, r.rate
FROM employees e, rate r, workon w, projects p
WHERE e.rate_category = r.rate_category
AND e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND r.rate >= 80;

-- 3. Find the names of the employees who work on projects that are located in the same city where the employees are located.
SELECT e.emp_id, e.emp_name, e.emp_city, p.project_name, p.project_city
FROM employees e, workon w, projects p
WHERE e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_city = e.emp_city

-- 4. Find the names of employees who are not working on any projects.
SELECT e.emp_id, e.emp_name
FROM employees e
WHERE e.emp_id NOT IN
(SELECT DISTINCT w.emp_id 
FROM workon w);

-- 5. Find the average rate of the employees who work on project Eagle.
SELECT AVG(r.rate)  
FROM employees e, rate r, workon w, projects p
WHERE e.rate_category = r.rate_category
AND e.emp_id = w.emp_id
AND w.project_number = p.project_number
AND p.project_name = 'Eagle';

-- 6. Find the names of the employees who work on more than one project. Display the results in descending order.
SELECT e.emp_name, COUNT(w.project_number) COUNT_PROJECT
FROM employees e, workon w
WHERE w.emp_id = e.emp_id
GROUP BY e.emp_name, w.emp_id
HAVING COUNT(w.project_number) > 1
ORDER BY e.emp_name DESC;








