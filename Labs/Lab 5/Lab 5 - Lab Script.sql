--Lab 5 Script

DECLARE
    k_job_president     CONSTANT        CHAR(9) := 'PRESIDENT';
    k_job_manager       CONSTANT        CHAR(7) := 'MANAGER';

    k_percent_50        CONSTANT        NUMBER(2,1) := 0.5;
    k_percent_25        CONSTANT        NUMBER(3,2) := 0.25;
    k_percent_22        CONSTANT        NUMBER(3,2) := 0.22;
    k_percent_10        CONSTANT        NUMBER(2,1) := 0.1;

    k_dollar_100        CONSTANT        NUMBER(3) := 100;

    v_sal_president                     emp.sal%TYPE;
    v_sal_company                       emp.sal%TYPE;
    v_sal_emp                           emp.sal%TYPE;

    v_comm_emp                          emp.comm%TYPE;

    v_job_manager                       emp.job%TYPE;

    ex_no_manager                       EXCEPTION;

    CURSOR c_emp IS 
        SELECT empno, job, sal, deptno, comm
        FROM emp;

BEGIN
    SELECT sal
    INTO v_sal_president
    FROM emp
    WHERE job = k_job_president;

    SELECT AVG(sal)
    INTO v_sal_company
    FROM emp;

    FOR r_emp IN c_emp LOOP

        BEGIN
            v_sal_emp := r_emp.sal;
            v_comm_emp := r_emp.comm;

            DBMS_OUTPUT.PUT_LINE(r_emp.empno || ' salary: ' || v_sal_emp);
            DBMS_OUTPUT.PUT_LINE(r_emp.empno || ' commission: ' || v_comm_emp);

            v_job_manager := NULL;
            
            IF r_emp.job != k_job_president THEN

                IF v_sal_emp > v_sal_president THEN
                   IF v_sal_emp - v_sal_emp * k_percent_50 < v_sal_president - v_sal_president * k_percent_25 THEN
                        v_sal_emp := v_sal_emp - v_sal_emp * k_percent_50;
                    ELSE 
                        v_sal_emp := v_sal_president - v_sal_president * k_percent_25;
                    END IF;
                END IF;

                IF v_sal_emp < k_dollar_100 THEN
                    IF v_sal_emp + v_sal_emp * k_percent_10 <= v_sal_company THEN
                        v_sal_emp := v_sal_emp + v_sal_emp * k_percent_10;
                    END IF;
                END IF;

                IF v_comm_emp IS NOT NULL THEN
                    IF v_comm_emp > 0 THEN
                        IF v_comm_emp > v_sal_emp * k_percent_22 THEN
                            
                            SELECT MIN(comm)
                            INTO v_comm_emp
                            FROM emp
                            WHERE comm > 0 AND deptno = r_emp.deptno;

                        END IF;
                    END IF;
                END IF;

                UPDATE emp
                SET comm = v_comm_emp, sal = v_sal_emp
                WHERE empno = r_emp.empno;

                SELECT job
                INTO v_job_manager
                FROM emp
                WHERE deptno = r_emp.deptno AND
                    job = k_job_manager;
                
                IF v_job_manager IS NULL THEN
                    RAISE ex_no_manager;
                END IF;
            END IF;

            EXCEPTION
                WHEN ex_no_manager THEN
                    rollback;
                    DBMS_OUTPUT.PUT_LINE(r_emp.empno || ' has no manager!');
                WHEN OTHERS THEN
                    rollback;
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;

        COMMIT;

    END LOOP;
END;
/
