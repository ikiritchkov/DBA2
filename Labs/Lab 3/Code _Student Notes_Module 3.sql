-- Scalar variables
SET SERVEROUTPUT ON

DECLARE
  v_emp_surname		VARCHAR2(30);
  
BEGIN
  v_emp_surname := 'Jones';
  DBMS_OUTPUT.PUT_LINE(v_emp_surname);
  
END;
/


DECLARE
  v_emp_surname		VARCHAR2(30) := 'Jones';
  
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_emp_surname);
  
END;
/


-- Constants and NOT NULL variables
SET SERVEROUTPUT ON

DECLARE
  v_test1			VARCHAR2(2) NOT NULL := 'Hi';
  v_test2 CONSTANT	NUMBER := 4;
  v_current_date	DATE;
  v_flag			BOOLEAN := TRUE;
  
BEGIN
  v_current_date := TO_DATE('Jan 1, 2013', 'Mon dd, yyyy');
  
  DBMS_OUTPUT.PUT_LINE(v_test1 || ' ' || v_current_date);
  
END;
/

-- Custom record

DECLARE
  TYPE t_emp IS RECORD (
    empno			emp.empno%TYPE,
	ename			emp.ename%TYPE,
	annual_sal		emp.sal%TYPE,
	current_date	DATE);
	
  r_emp  t_emp;
  
 .
 .
 .
 
 BEGIN
   r_emp.ename := 'Fred';
 
 .
 .
 .
 
 END;
 /
 
-- %ROWTYPE record

DECLARE
	
  r_emp  emp%ROWTYPE;
  
 .
 .
 .
 
 BEGIN
   r_emp.ename := 'Fred';
 
 .
 .
 .
 
 END;
 / 

-- Table of records
DECLARE
  TYPE t_employees IS TABLE OF emp%ROWTYPE
    INDEX BY BINARY_INTEGER;
	
  tbl_employees  	t_employees;
  
  v_counter			NUMBER := 1;
  
.
.
.

BEGIN

.
.
.

  tbl_employees(v_counter).ename :='Fred';
  
  v_counter := v_counter + 1;
  
  tbl_employees(v_counter).ename := 'Sue';
  
  DBMS_OUTPUT.PUT_LINE(tbl_employees.COUNT);   
  
.
.
.

END;
/

-- Collection
SET SERVEROUTPUT ON

DECLARE
  TYPE t_name IS TABLE OF VARCHAR2(10)
    INDEX BY BINARY_INTEGER;
	
  tbl_name		  	t_name;
  
  v_counter			NUMBER := 1;
  
.
.
.

BEGIN

.
.
.

  tbl_name(v_counter) :='Fred';
  
  v_counter := v_counter + 1;
  
  tbl_name(v_counter) := 'Sue';
  
  DBMS_OUTPUT.PUT_LINE(tbl_name.COUNT);  
  
.
.
.

END;
/

-- Error correction practice

set serveroutput on

DECLARE

  v_emp_no   emp.empno%TYPE
  v_ename    VARCHAR3(20);
  

BEGIN

  v_empno = 6;

  v_ename := Fred;

  SELECT ename
    FROM emp
   WHERE empno = 7876;

  SELECT empno
    INTO v_empno
    FROM emp;

  SELECT job
    INTO v_job
    FROM emp
   WHERE empno = 9483;

END;
/
