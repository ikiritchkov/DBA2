--Lab 1

--Task 2
CREATE SEQUENCE seq_movie_id
START WITH 20
INCREMENT BY 5;

--TASK 3
SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME = UPPER('seq_movie_id');

--TASK 4
SELECT seq_movie_id.NEXTVAL
FROM dual;

--TASK 5
INSERT INTO mm_movie
VALUES (seq_movie_id.NEXTVAL, 'The Predator', 1, 10, 2);

--TASK 6
CREATE VIEW VW_MOVIE_RENTAL AS
SELECT movie_title, rental_id, last 
FROM mm_movie mov
JOIN mm_rental ren ON (mov.movie_id = ren.movie_id)
JOIN mm_member mem ON (ren.member_id = mem.member_id);

--TASK 7
SELECT * FROM vw_movie_rental;

--TASK 8
CREATE PUBLIC SYNONYM m_type
FOR cprg307.mm_movie_type;

