--STEP 1:

CREATE TABLE employee (
  fname    varchar(15) not null, 
  minit    varchar(1),
  lname    varchar(15) not null,
  ssn      char(9),
  bdate    date,
  address  varchar(50),
  sex      char,
  salary   decimal(10,2),
  Super_ssn char(9),
  dno      char(4),
  primary key (ssn));


CREATE TABLE department (
  dname        varchar(25) not null,
  dnumber      char(4),
  Mgr_ssn       char(9) not null, 
  Mgr_start_date date,
  primary key (dnumber));


CREATE TABLE dept_locations (
  dnumber   char(4),
  dlocation varchar(15), 
  primary key (dnumber,dlocation));


CREATE TABLE project (
  pname      varchar(25) not null,
  pnumber    char(4),
  plocation  varchar(15),
  dnum       char(4) not null,
  primary key (pnumber),
  unique (pname));


CREATE TABLE works_on (
  essn   char(9),
  pno    char(4),
  hours  decimal(4,1),
  primary key (essn,pno));


CREATE TABLE dependent (
  essn           char(9),
  dependent_name varchar(15),
  sex            char,
  bdate          date,
  relationship   varchar(8),
  primary key (essn,dependent_name));


--STEP #2:

INSERT INTO employee VALUES
  ('John','B','Smith','123456789',TO_DATE('09-JAN-1965','DD-MON-YYYY'),'731 Fondren, Houston, TX','M',30000,333445555,5);
INSERT INTO employee VALUES 
  ('Franklin','T','Wong','333445555',TO_DATE('08-DEC-1955','DD-MON-YYYY'),'638 Voss, Houston, TX','M',40000,'888665555',5);
INSERT INTO employee VALUES 
  ('Alicia','J','Zelaya','999887777',TO_DATE('19-JUL-1968','DD-MON-YYYY'),'3321 Castle, Spring, TX','F',25000,'987654321',4);
INSERT INTO employee VALUES 
  ('Jennifer','S','Wallace','987654321',TO_DATE('20-JUN-1941','DD-MON-YYYY'),'291 Berry, Bellaire, TX','F',43000,'888665555',4);
INSERT INTO employee VALUES 
  ('Ramesh','K','Narayan','666884444',TO_DATE('15-SEP-1962','DD-MON-YYYY'),'975 Fire Oak, Humble, TX','M',38000,'333445555',5);
INSERT INTO employee VALUES 
  ('Joyce','A','English','453453453',TO_DATE('31-JUL-1972','DD-MON-YYYY'),'5631 Rice, Houston, TX','F',25000,'333445555',5);
INSERT INTO employee VALUES 
  ('Ahmad','V','Jabbar','987987987',TO_DATE('29-MAR-1969','DD-MON-YYYY'),'980 Dallas, Houston, TX','M',25000,'987654321',4);
INSERT INTO employee VALUES 
  ('James','E','Borg','888665555',TO_DATE('10-NOV-1937','DD-MON-YYYY'),'450 Stone, Houston, TX','M',55000,null,1);


--
INSERT INTO department VALUES ('Research', 5, '333445555', TO_DATE('22-MAY-1988','DD-MON-YYYY'));
INSERT INTO department VALUES ('Administration', 4, '987654321', TO_DATE('01-JAN-1995','DD-MON-YYYY'));
INSERT INTO department VALUES ('Headquarters', 1, '888665555', TO_DATE('19-JUN-1981','DD-MON-YYYY'));


--
INSERT INTO project VALUES ('ProductX',1,'Bellaire',5);
INSERT INTO project VALUES ('ProductY',2,'Sugarland',5);
INSERT INTO project VALUES ('ProductZ',3,'Houston',5);
INSERT INTO project VALUES ('Computerization',10,'Stafford',4);
INSERT INTO project VALUES ('Reorganization',20,'Houston',1);
INSERT INTO project VALUES ('Newbenefits',30,'Stafford',4);


--
INSERT INTO dept_locations VALUES (1,'Houston');
INSERT INTO dept_locations VALUES (4,'Stafford');
INSERT INTO dept_locations VALUES (5,'Bellaire');
INSERT INTO dept_locations VALUES (5,'Sugarland');
INSERT INTO dept_locations VALUES (5,'Houston');


--
INSERT INTO dependent VALUES ('333445555','Alice','F',TO_DATE('05-APR-86','DD-MON-YY'),'Daughter');
INSERT INTO dependent VALUES ('333445555','Theodore','M',TO_DATE('25-OCT-83','DD-MON-YY'),'Son');
INSERT INTO dependent VALUES ('333445555','Joy','F',TO_DATE('03-MAY-58','DD-MON-YY'),'Spouse');
INSERT INTO dependent VALUES ('987654321','Abner','M',TO_DATE('28-FEB-42','DD-MON-YY'),'Spouse');
INSERT INTO dependent VALUES ('123456789','Michael','M',TO_DATE('01-JAN-78','DD-MON-YY'),'Son');
INSERT INTO dependent VALUES ('123456789','Alice','F', TO_DATE('31-DEC-88','DD-MON-YY'),'Daughter');
INSERT INTO dependent VALUES ('123456789','Elizabeth','F',TO_DATE('05-MAY-67','DD-MON-YY'),'Spouse');


--
INSERT INTO works_on VALUES ('123456789',1, 32.5);
INSERT INTO works_on VALUES ('123456789',2,  7.5);
INSERT INTO works_on VALUES ('666884444',3, 40.0);
INSERT INTO works_on VALUES ('453453453',1, 20.0);
INSERT INTO works_on VALUES ('453453453',2, 20.0);
INSERT INTO works_on VALUES ('333445555',2, 10.0);
INSERT INTO works_on VALUES ('333445555',3, 10.0);
INSERT INTO works_on VALUES ('333445555',10,10.0);
INSERT INTO works_on VALUES ('333445555',20,10.0);
INSERT INTO works_on VALUES ('999887777',30,30.0);
INSERT INTO works_on VALUES ('999887777',10,10.0);
INSERT INTO works_on VALUES ('987987987',10,35.0);
INSERT INTO works_on VALUES ('987987987',30, 5.0);
INSERT INTO works_on VALUES ('987654321',30,20.0);
INSERT INTO works_on VALUES ('987654321',20,15.0);
INSERT INTO works_on VALUES ('888665555',20,null);

--STEP #3

ALTER TABLE EMPLOYEE
ADD CONSTRAINT employee_superssn_fk FOREIGN KEY (Super_ssn)
	REFERENCES employee (ssn);

ALTER TABLE EMPLOYEE
ADD CONSTRAINT employee_dno_fk FOREIGN KEY (Dno)
	REFERENCES department (dnumber);


ALTER TABLE department
ADD CONSTRAINT department_mgrssn_fk FOREIGN KEY (Mgr_ssn)
	REFERENCES employee (ssn);


ALTER TABLE dept_locations
ADD CONSTRAINT deptlocations_dnumber_fk foreign key (dnumber) 
references department(dnumber);


ALTER TABLE project
ADD CONSTRAINT project_dnum_fk foreign key (dnum) 
references department(dnumber);


ALTER TABLE works_on
ADD CONSTRAINT workson_essn_fk foreign key (essn) 
references employee(ssn);


ALTER TABLE works_on
ADD CONSTRAINT workson_pno_fk  foreign key (pno) 
references project(pnumber);


ALTER TABLE dependent
ADD CONSTRAINT dependent_essn_fk foreign key (essn) 
references employee(ssn);


--STEP #4
-------

SELECT *
FROM EMPLOYEE;


--Question1:
select e.fname mgr_fname, e.lname mgr_lname, depd.dependent_name
from employee e, department depm, dependent depd
where e.ssn = depm.mgr_ssn
and e.ssn = depd.essn
and depm.dname = 'Research';

--Question2:
select d.dname, e.lname mgr_lname, p.pname
from employee e, department d, dept_locations dl, project p
where e.ssn = d.mgr_ssn
and d.dnumber = dl.dnumber
and dl.dnumber = p.dnum
and dl.dlocation = 'Stafford';

--Question3:
select e.fname employee_fname, e.lname employee_lname, d.dname, p.pname
from employee e, department d, works_on w, project p
where d.dnumber = e.dno
and e.ssn = w.essn
and w.pno = p.pnumber;




