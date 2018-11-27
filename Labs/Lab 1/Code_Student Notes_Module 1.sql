-- Sequence with all of the clauses
CREATE SEQUENCE seq_complete
START WITH 5
INCREMENT BY 10
NOMAXVALUE
NOCYCLE
CACHE 20;

-- Equivalent to:
CREATE SEQUENCE seq_complete
START WITH 5
INCREMENT BY 10;


-- Simplest sequence to create
CREATE SEQUENCE seq_simple;

-- Using a sequence
SELECT seq_simple.NEXTVAL
  FROM dual;
  
SELECT seq_simple.CURRVAL
  FROM dual;
  

INSERT INTO emp
(empno, deptno, ename)
VALUES
(seq_simple.NEXTVAL, 10, 'Fred');


-- Simple view
CREATE OR REPLACE VIEW vw_simple AS
  SELECT empno, ename, hiredate
    FROM emp;
	
-- Complex view
CREATE OR REPLACE VIEW vw_complex1 AS
  SELECT ename, dname
    FROM emp e, dept d
   WHERE e.deptno = d.deptno;
   
CREATE OR REPLACE VIEW vw_complex2 AS
  SELECT deptno, COUNT(*) how_many
    FROM emp
   GROUP BY deptno;
   
 
-- Data dictionary views
SELECT table_name
  FROM user_tables
 ORDER BY table_name;
 
SELECT view_name, text
  FROM user_views;
  
SELECT sequence_name
  FROM user_sequences;
  
  