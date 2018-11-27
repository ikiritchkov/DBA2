--Lab 7 - Lab Script
--Task 1

CREATE OR REPLACE TRIGGER prevent_when_available_bir
BEFORE
INSERT
ON wgl_reserve_list
FOR EACH ROW

DECLARE
    k_on_shelf          CONSTANT            wgl_accession_register.status%TYPE := 'OS';
    v_status                                wgl_accession_register.status%TYPE;

BEGIN

    SELECT status
    INTO v_status
    FROM wgl_accession_register
    JOIN wgl_branch ON (wgl_accession_register.branch_number = wgl_branch.branch_number)
    WHERE wgl_branch.branch_number = :NEW.branch_reserved_at
    AND wgl_accession_register.isbn = :NEW.isbn;

    IF v_status = k_on_shelf THEN
        RAISE_APPLICATION_ERROR(-20999, 'Book is available on the shelf at this branch');
    ELSE
        :NEW.date_reserved := SYSDATE;
    END IF;

END;
/

--Task 2
CREATE OR REPLACE TRIGGER new_wgl_loan_bir
BEFORE
INSERT
ON wgl_loan
FOR EACH ROW

DECLARE
    v_loan_period                   wgl_accession_register.loan_period%TYPE;

BEGIN
    SELECT loan_period
    INTO v_loan_period
    FROM wgl_accession_register
    WHERE accession_number = :NEW.accession_number;

    :NEW.loan_number := wgl_loan_seq.NEXTVAL;
    :NEW.loan_date := SYSDATE;
    :NEW.due_date := :NEW.loan_date + v_loan_period;

    UPDATE wgl_accession_register
    SET due_date = :NEW.due_date
    WHERE accession_number = :NEW.accession_number;

    UPDATE wgl_patron
    SET books_on_loan = books_on_loan + 1
    WHERE patron_number = :NEW.patron_number;

END;
/

--Task 3
CREATE OR REPLACE TRIGGER new_iccc_registration_bir
BEFORE
INSERT
ON course_registration
FOR EACH ROW

BEGIN
    :NEW.grade := null;

END;
/

--Task 4
CREATE OR REPLACE TRIGGER new_iccc_registration_air
AFTER
INSERT
ON course_registration
FOR EACH ROW

DECLARE
    v_capacity                      class_section.capacity%TYPE;
    v_enrolment                     class_section.enrolment%TYPE;
    v_instructor_id                 class_section.instructor_id%TYPE;
    v_new_section_code              class_section.section_code%TYPE;
    v_existing_section_code         class_section.section_code%TYPE;
    v_new_section_incr              NUMBER := 0;
    v_unique_section                BOOLEAN := false;

BEGIN
    -- Increase section enrolment
    UPDATE class_section
    SET enrolment = enrolment + 1
    WHERE course_code = :NEW.course_code
    AND section_code = :NEW.section
    AND semester = :NEW.semester
    AND year = :NEW.year;

    SELECT capacity, enrolment, instructor_id
    INTO v_capacity, v_enrolment, v_instructor_id
    FROM class_section
    WHERE course_code = :NEW.course_code
    AND section_code = :NEW.section
    AND semester = :NEW.semester
    AND year = :NEW.year;

    -- Create a new class section if section is now full
    IF v_capacity = v_enrolment THEN

        -- Continue incrementing the section code until a unique code is found
        WHILE (v_unique_section = FALSE) LOOP
            v_new_section_incr := v_new_section_incr + 1;
            v_new_section_code := substr(:NEW.section, 1, 2) || CHR(ASCII(SUBSTR(:NEW.section, 3, 1)) + v_new_section_incr);

            BEGIN
                SELECT section_code
                INTO v_existing_section_code
                FROM class_section
                WHERE course_code = :NEW.course_code
                AND section_code = v_new_section_code
                AND semester = :NEW.semester
                AND year = :NEW.year;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_unique_section := TRUE;
            END;
        END LOOP;

        INSERT INTO class_section
        VALUES (:NEW.course_code, v_new_section_code, :NEW.semester, :NEW.year, v_instructor_id, v_capacity, 0);
    END IF;
END;
/

--Task 5
CREATE OR REPLACE TRIGGER new_reg_student_incr_ais
AFTER
INSERT
ON course_registration

DECLARE

v_existing_year                     iccc_statistics.year%TYPE;
v_current_year                      iccc_statistics.year%TYPE;

BEGIN
    -- Get the current year 
    SELECT EXTRACT (YEAR FROM SYSDATE)
    INTO v_current_year
    FROM DUAL;
    
    -- Verify that the year row exists
    SELECT year
    INTO v_existing_year
    FROM iccc_statistics
    WHERE year = v_current_year;

    -- Update student count if year exists
    UPDATE iccc_statistics
    SET student_count = student_count + 1
    WHERE year = v_existing_year;

EXCEPTION
    WHEN OTHERS THEN
    INSERT INTO iccc_statistics
    VALUES(v_current_year, 1);
END;
/

--Task 6
CREATE OR REPLACE TRIGGER massive_insert_compound
FOR INSERT ON course_registration
COMPOUND TRIGGER

    BEFORE EACH ROW IS
        BEGIN
            -- Set final grade to null
            :NEW.grade := null;

    END BEFORE EACH ROW;

    AFTER EACH ROW IS
        v_capacity                      class_section.capacity%TYPE;
        v_enrolment                     class_section.enrolment%TYPE;
        v_instructor_id                 class_section.instructor_id%TYPE;
        v_new_section_code              class_section.section_code%TYPE;
        v_existing_section_code         class_section.section_code%TYPE;
        v_new_section_incr              NUMBER := 0;
        v_unique_section                BOOLEAN := false;

    BEGIN

        -- Increase section enrolment
        UPDATE class_section
        SET enrolment = enrolment + 1
        WHERE course_code = :NEW.course_code
        AND section_code = :NEW.section
        AND semester = :NEW.semester
        AND year = :NEW.year;

        SELECT capacity, enrolment, instructor_id
        INTO v_capacity, v_enrolment, v_instructor_id
        FROM class_section
        WHERE course_code = :NEW.course_code
        AND section_code = :NEW.section
        AND semester = :NEW.semester
        AND year = :NEW.year;

        -- Create a new class section if section is now full
        IF v_capacity = v_enrolment THEN

            -- Continue incrementing the section code until a unique code is found
            WHILE (v_unique_section = FALSE) LOOP
                v_new_section_incr := v_new_section_incr + 1;
                v_new_section_code := substr(:NEW.section, 1, 2) || CHR(ASCII(SUBSTR(:NEW.section, 3, 1)) + v_new_section_incr);

                BEGIN
                    SELECT section_code
                    INTO v_existing_section_code
                    FROM class_section
                    WHERE course_code = :NEW.course_code
                    AND section_code = v_new_section_code
                    AND semester = :NEW.semester
                    AND year = :NEW.year;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_unique_section := TRUE;
                END;
            END LOOP;

            INSERT INTO class_section
            VALUES (:NEW.course_code, v_new_section_code, :NEW.semester, :NEW.year, v_instructor_id, v_capacity, 0);
        END IF;

    END AFTER EACH ROW;

    AFTER STATEMENT IS

        v_existing_year                     iccc_statistics.year%TYPE;
        v_current_year                      iccc_statistics.year%TYPE;

    BEGIN

            -- Get the current year 
            SELECT EXTRACT (YEAR FROM SYSDATE)
            INTO v_current_year
            FROM DUAL;

            BEGIN        
                -- Verify that the year row exists
                SELECT year
                INTO v_existing_year
                FROM iccc_statistics
                WHERE year = v_current_year;

                -- Update student count if year exists
                UPDATE iccc_statistics
                SET student_count = student_count + 1
                WHERE year = v_existing_year;

            EXCEPTION
                WHEN OTHERS THEN
                INSERT INTO iccc_statistics
                VALUES(v_current_year, 1);
            END;
    END AFTER STATEMENT;
END;
/

--Task 7
-- Task 3 Triggering Statements 
INSERT INTO course_registration
(student_id, course_code, section, semester, year, grade)
VALUES
('000612345', 'ACCT210', '1FB', '1', '2014', 95);

INSERT INTO course_registration
(student_id, course_code, section, semester, year)
VALUES
('000612345', 'CMPP230', '1FB', '1', '2014');

-- Task 4 Triggering Statements
INSERT INTO course_registration
(student_id, course_code, section, semester, year)
VALUES
('002502060', 'MATH235', '1FA', '2', '2014');

INSERT INTO course_registration
(student_id, course_code, section, semes ter, year)
VALUES
('002502060', 'COMP202', '1FA', '2', '2013');

-- Task 5 Triggering Statements
INSERT INTO course_registration
(student_id, course_code, section, semester, year)
VALUES
('000600189', 'CSYS325', '2FB', '2', '2014');

INSERT INTO course_registration
(student_id, course_code, section, semester, year)
VALUES
('000600189', 'ENGL201', '1WA', '1', '2014');

-- These triggering statements can be used in the compound trigger as well 
-- because all of the triggers are based on an INSERT statement ON the 
-- course_registration table.