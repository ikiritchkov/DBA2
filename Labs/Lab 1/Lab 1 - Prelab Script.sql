--Lab 1 - Prelab

--Task 2
DESCRIBE mm_member;

--Task 3
INSERT INTO mm_member (member_id, last, first)
	VALUES (15, 'Kiritchkov', 'Iliya');

--TASK 4
UPDATE mm_member
SET credit_card = '666666666666'
WHERE last = 'Kiritchkov' AND first = 'Iliya';

--TASK 5
DELETE mm_member
WHERE last = 'Kiritchkov' AND first = 'Iliya';

--TASK 6
COMMIT;

--TASK 7
SELECT movie_title, rental_id, last 
FROM mm_movie mov
JOIN mm_rental ren ON (mov.movie_id = ren.movie_id)
JOIN mm_member mem ON (ren.member_id = mem.member_id);

--TASK 8
SELECT movie_title, rental_id, last
FROM mm_movie mov, mm_rental ren, mm_member mem
WHERE mov.movie_id = ren.movie_id AND ren.member_id = mem.member_id;

--TASK 9
CREATE TABLE MY_TABLE 
	(MY_NUMBER number, 
	MY_DATE date, 
	MY_STRING VARCHAR2(5));
