--  Sample employee database 
--  See changelog table for details
--  Copyright (C) 2007,2008, MySQL AB
--  
--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
-- This work is licensed under the 
-- Creative Commons Attribution-Share Alike 3.0 Unported License. 
-- To view a copy of this license, visit 
-- http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
-- Creative Commons, 171 Second Street, Suite 300, San Francisco, 
-- California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.
-- 

DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;
USE employees;

SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries, 
                     employees, 
                     departments;

/*!50503 set default_storage_engine = InnoDB */;
/*!50503 select CONCAT('storage engine: ', @@default_storage_engine) as INFO */;

CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,    
    hire_date   DATE            NOT NULL,
    PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),
    UNIQUE  KEY (dept_name)
);

INSERT INTO departments (dept_no, dept_name) VALUES
('d001', 'Marketing'),
('d002', 'Finance'),
('d003', 'Human Resources'),
('d004', 'Production');

CREATE TABLE dept_manager (
   emp_no       INT             NOT NULL,
   dept_no      CHAR(4)         NOT NULL,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
   PRIMARY KEY (emp_no,dept_no)
); 

CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE titles (
    emp_no      INT             NOT NULL,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,title, from_date)
) 
; 

CREATE TABLE salaries (
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
) 
; 

CREATE OR REPLACE VIEW dept_emp_latest_date AS
    SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
    FROM dept_emp
    GROUP BY emp_no;

# shows only the current department for each employee
CREATE OR REPLACE VIEW current_dept_emp AS
    SELECT l.emp_no, dept_no, l.from_date, l.to_date
    FROM dept_emp d
        INNER JOIN dept_emp_latest_date l
        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;

flush /*!50503 binary */ logs;

SELECT 'LOADING employees' as 'INFO';

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES
(10001, '1953-09-02', 'Georgi', 'Facello', 'M', '1986-06-26'),
(10002, '1964-06-02', 'Bezalel', 'Simmel', 'F', '1985-11-21');

SELECT 'LOADING dept_emp' as 'INFO';
INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date) VALUES
(10001, 'd001', '1986-06-26', '9999-01-01'),
(10002, 'd002', '1985-11-21', '9999-01-01');

SELECT 'LOADING dept_manager' as 'INFO';
INSERT INTO dept_manager (emp_no, dept_no, from_date, to_date) VALUES
(10001, 'd001', '1986-06-26', '9999-01-01'),
(10002, 'd002', '1985-11-21', '9999-01-01');

SELECT 'LOADING titles' as 'INFO';
INSERT INTO titles (emp_no, title, from_date, to_date) VALUES
(10001, 'Senior Engineer', '1986-06-26', '9999-01-01'),
(10002, 'Staff', '1985-11-21', '9999-01-01');

SELECT 'LOADING salaries' as 'INFO';
INSERT INTO salaries (emp_no, salary, from_date, to_date) VALUES
(10001, 60117, '1986-06-26', '1987-06-25'),
(10001, 62102, '1987-06-26', '1988-06-25'),
(10001, 66096, '1988-06-26', '1989-06-25'),
(10001, 71053, '1989-06-26', '1990-06-25'),
(10001, 76084, '1990-06-26', '1991-06-25'),
(10001, 81015, '1991-06-26', '1992-06-25'),
(10001, 86047, '1992-06-26', '1993-06-25'),
(10001, 91080, '1993-06-26', '1994-06-25'),
(10001, 96113, '1994-06-26', '1995-06-25'),
(10001, 101146, '1995-06-26', '1996-06-25'),
(10001, 106179, '1996-06-26', '1997-06-25'),
(10001, 111212, '1997-06-26', '1998-06-25'),
(10001, 116245, '1998-06-26', '1999-06-25'),
(10001, 121278, '1999-06-26', '2000-06-25'),
(10001, 126311, '2000-06-26', '2001-06-25'),
(10001, 131344, '2001-06-26', '2002-06-25'),
(10001, 136377, '2002-06-26', '2003-06-25'),
(10001, 141410, '2003-06-26', '2004-06-25'),
(10001, 146443, '2004-06-26', '2005-06-25'),
(10001, 151476, '2005-06-26', '2006-06-25'),
(10001, 156509, '2006-06-26', '2007-06-25'),
(10001, 161542, '2007-06-26', '2008-06-25'),
(10001, 166575, '2008-06-26', '2009-06-25'),
(10001, 171608, '2009-06-26', '2010-06-25'),
(10001, 176641, '2010-06-26', '2011-06-25'),
(10001, 181674, '2011-06-26', '2012-06-25'),
(10001, 186707, '2012-06-26', '9999-01-01'),
(10002, 58706, '1985-11-21', '1986-11-20'),
(10002, 62350, '1986-11-21', '1987-11-20'),
(10002, 66094, '1987-11-21', '1988-11-20'),
(10002, 69838, '1988-11-21', '1989-11-20'),
(10002, 73582, '1989-11-21', '1990-11-20'),
(10002, 77326, '1990-11-21', '1991-11-20'),
(10002, 81070, '1991-11-21', '1992-11-20'),
(10002, 84814, '1992-11-21', '1993-11-20'),
(10002, 88558, '1993-11-21', '1994-11-20'),
(10002, 92302, '1994-11-21', '1995-11-20'),
(10002, 96046, '1995-11-21', '1996-11-20'),
(10002, 99790, '1996-11-21', '1997-11-20'),
(10002, 103534, '1997-11-21', '1998-11-20'),
(10002, 106178, '1998-11-21', '1999-11-20'),
(10002, 108822, '1999-11-21', '2000-11-20'),
(10002, 111466, '2000-11-21', '2001-11-20'),
(10002, 114110, '2001-11-21', '2002-11-20'),
(10002, 116754, '2002-11-21', '2003-11-20'),
(10002, 119398, '2003-11-21', '2004-11-20'),
(10002, 122042, '2004-11-21', '2005-11-20'),
(10002, 124686, '2005-11-21', '2006-11-20'),
(10002, 127330, '2006-11-21', '2007-11-20'),
(10002, 129974, '2007-11-21', '2008-11-20'),
(10002, 132618, '2008-11-21', '2009-11-20'),
(10002, 135262, '2009-11-21', '2010-11-20'),
(10002, 137906, '2010-11-21', '2011-11-20'),
(10002, 140550, '2011-11-21', '2012-11-20'),
(10002, 143194, '2012-11-21', '9999-01-01');

select timediff(
    (select update_time from information_schema.tables where table_schema='employees' and table_name='salaries'),
    (select create_time from information_schema.tables where table_schema='employees' and table_name='employees')
) as data_load_time_diff;
customer