--Lab 4 Script
--Task 3
						-------
--Author@@@@ 					-------
--!!@%!%!@$%#^$#&$%^$#				-------
--!@#%%!@%@!					-------
-------------------------------------------------------
-------------------------------------------------------
DECLARE
	k_job_pres	CONSTANT	CHAR(9) := 'PRESIDENT';
	k_10_percent	CONSTANT	NUMBER(2,1) := 0.1;	
	k_22_percent	CONSTANT	NUMBER(3,2) := 0.22;
	k_25_percent	CONSTANT	NUMBER(3,2) := 0.25;
	k_50_percent	CONSTANT	NUMBER(2,1) := 0.5;
	k_100_dollars	CONSTANT	NUMBER(3) := 100;
	v_sal_temp1			NUMBER;
	v_sal_temp2			NUMBER;
	v_sal_temp3			NUMBER;
	v_sal_emp			NUMBER;
	v_com_emp			NUMBER;

	v_sal_pres			NUMBER;
	v_sal_avg			NUMBER;
	v_com_low			NUMBER;

	CURSOR c_emp IS
		SELECT empno, job, sal, comm, deptno
		FROM emp;
	
BEGIN
	SELECT sal
	INTO v_sal_pres
	FROM emp
	WHERE job = k_job_pres;

	SELECT AVG(sal)
	INTO v_sal_avg
	FROM emp;
	
	FOR r_emp IN c_emp LOOP
		v_sal_emp := r_emp.sal;
		v_com_emp := r_emp.comm;

		--Employee is not the President
		IF (r_emp.job <> k_job_pres) THEN
		
			--Employee salary is higher than the President's salary
			IF (r_emp.sal > v_sal_pres) THEN
				v_sal_temp1 := r_emp.sal - r_emp.sal * k_50_percent;
				v_sal_temp2 := v_sal_pres - v_sal_pres * k_25_percent;

				IF (v_sal_temp1 < v_sal_temp2) THEN
					v_sal_emp := v_sal_temp1;
				ELSE
					v_sal_emp := v_sal_temp2;		
				END IF;
			END IF;
		
			--Employee salary less than 100 dollars
			IF (v_sal_emp < k_100_dollars) THEN
				v_sal_temp3 := v_sal_emp + v_sal_emp * k_10_percent;

				IF (v_sal_temp3 < v_sal_avg) THEN
					v_sal_emp := v_sal_temp3;
				END IF;
			END IF;

			--Employee commission is greater than 22% of salary
			--Subtracting a constant from itself to get 0
			IF (r_emp.comm > v_sal_emp * k_22_percent) THEN

				SELECT MIN(comm)
				INTO v_com_low
				FROM emp
				WHERE deptno = r_emp.deptno AND comm > k_100_dollars - k_100_dollars;
				
				v_com_emp := v_com_low;
			END IF;

			UPDATE emp
			SET sal = v_sal_emp, comm = v_com_emp
			WHERE empno = r_emp.empno;
		END IF;
		
		COMMIT;
	END LOOP;	
END;
/
