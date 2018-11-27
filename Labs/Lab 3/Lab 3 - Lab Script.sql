--Lab 3 - Script

--Task 3
SET SERVEROUTPUT ON

DECLARE
	v_pres_job	CONSTANT	CHAR(9):= 'PRESIDENT';
	v_25percent	CONSTANT	NUMBER(3,2):= 0.25;
	v_10percent	CONSTANT	NUMBER(2,1):= 0.1;
	v_onehundred	CONSTANT	NUMBER(3):= 100;

	v_pres_sal			emp.sal%TYPE;
	v_comp_avg_sal			emp.sal%TYPE;
BEGIN
	SELECT sal
	INTO v_pres_sal
	FROM emp
	WHERE job = v_pres_job;

	SELECT AVG(sal)
	INTO v_comp_avg_sal
	FROM emp;

	UPDATE emp
	SET sal = v_pres_sal - (v_pres_sal * v_25percent) 
	WHERE job != v_pres_job
	AND sal > v_pres_sal;

	UPDATE emp
	SET sal = sal + (sal * v_10percent)
	WHERE job != v_pres_job
	AND sal < v_onehundred
	AND v_comp_avg_sal > sal + (sal * v_10percent);

END;
/
