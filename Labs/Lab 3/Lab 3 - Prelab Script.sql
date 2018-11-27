--Lab 3 - Prelab Script

--Task 1
SET SERVEROUTPUT ON

DECLARE
	v_hiredate			DATE := to_date('January 10, 2013', 'MONTH DD, YYYY');
	v_surname			VARCHAR2(30);
	v_firstname			VARCHAR2(30);
	k_salary	CONSTANT	NUMBER(5,2) := 100.25;
BEGIN
	v_firstname := 'Iliya';
	v_surname := 'Kiritchkov';
	
	DBMS_OUTPUT.PUT_LINE(v_hiredate);
	DBMS_OUTPUT.PUT_LINE(v_surname);
	DBMS_OUTPUT.PUT_LINE(v_firstname);
	DBMS_OUTPUT.PUT_LINE(k_salary);
END;
/

--Task 2
DECLARE 
	v_agent_id		VARCHAR2(7);
	v_last_name		VARCHAR2(25);
	v_first_name		VARCHAR2(25);
	v_date_of_hire		DATE;
	v_home_phone		VARCHAR2(10);
	v_business_phone	VARCHAR2(10);
BEGIN
	SELECT agent_id, last_name, first_name, date_of_hire, home_phone, business_phone
	INTO v_agent_id, v_last_name, v_first_name, v_date_of_hire, v_home_phone, v_business_phone
	FROM ata_agent
	WHERE agent_id = '0000002';

	DBMS_OUTPUT.PUT_LINE('Agent Id - ' || v_agent_id);
	DBMS_OUTPUT.PUT_LINE('Last Name - ' || v_last_name);
	DBMS_OUTPUT.PUT_LINE('First Name - ' || v_first_name);
	DBMS_OUTPUT.PUT_LINE('Date of Hire - ' || v_date_of_hire);
	DBMS_OUTPUT.PUT_LINE('Home Phone - ' || v_home_phone);
	DBMS_OUTPUT.PUT_LINE('Business Phone - ' || v_business_phone);
END;
/

--Task 3
DECLARE
	v_agent_id		ata_agent.agent_id%TYPE;
	v_last_name		ata_agent.last_name%TYPE;
	v_first_name		ata_agent.first_name%TYPE;
	v_date_of_hire		ata_agent.date_of_hire%TYPE;
	v_home_phone		ata_agent.home_phone%TYPE;
	v_business_phone	ata_agent.business_phone%TYPE;
BEGIN
	SELECT agent_id, last_name, first_name, date_of_hire, home_phone, business_phone
	INTO v_agent_id, v_last_name, v_first_name, v_date_of_hire, v_home_phone, v_business_phone
	FROM ata_agent
	WHERE agent_id = '0000002';

	DBMS_OUTPUT.PUT_LINE('Agent Id - ' || v_agent_id);
	DBMS_OUTPUT.PUT_LINE('Last Name - ' || v_last_name);
	DBMS_OUTPUT.PUT_LINE('First Name - ' || v_first_name);
	DBMS_OUTPUT.PUT_LINE('Date of Hire - ' || v_date_of_hire);
	DBMS_OUTPUT.PUT_LINE('Home Phone - ' || v_home_phone);
	DBMS_OUTPUT.PUT_LINE('Business Phone - ' || v_business_phone);
END;
/

--Task 4
DECLARE 
	TYPE type_agent IS RECORD( 
		v_agent_id 		ata_agent.agent_id%TYPE,
		v_last_name	 	ata_agent.last_name%TYPE,
		v_first_name		ata_agent.first_name%TYPE,
		v_date_of_hire		ata_agent.date_of_hire%TYPE,
		v_home_phone		ata_agent.home_phone%TYPE,
		v_business_phone	ata_agent.business_phone%TYPE);
	rec_agent type_agent;
BEGIN
	SELECT agent_id, last_name, first_name, date_of_hire, home_phone, business_phone
	INTO rec_agent
	FROM ata_agent
	WHERE agent_id = '0000002';

	DBMS_OUTPUT.PUT_LINE('Agent Id - ' || rec_agent.v_agent_id);
	DBMS_OUTPUT.PUT_LINE('Last Name - ' || rec_agent.v_last_name);
	DBMS_OUTPUT.PUT_LINE('First Name - ' || rec_agent.v_first_name);
	DBMS_OUTPUT.PUT_LINE('Date of Hire - ' || rec_agent.v_date_of_hire);
	DBMS_OUTPUT.PUT_LINE('Home Phone - ' || rec_agent.v_home_phone);
	DBMS_OUTPUT.PUT_LINE('Business Phone - ' || rec_agent.v_business_phone);
END;
/

--Task 5
DECLARE
	rec_agent ata_agent%ROWTYPE;
BEGIN
	SELECT *
	INTO rec_agent
	FROM ata_agent
	WHERE agent_id = '0000002';

	DBMS_OUTPUT.PUT_LINE('Agent Id - ' || rec_agent.agent_id);
	DBMS_OUTPUT.PUT_LINE('Last Name - ' || rec_agent.last_name);
	DBMS_OUTPUT.PUT_LINE('First Name - ' || rec_agent.first_name);
	DBMS_OUTPUT.PUT_LINE('Date of Hire - ' || rec_agent.date_of_hire);
	DBMS_OUTPUT.PUT_LINE('Home Phone - ' || rec_agent.home_phone);
	DBMS_OUTPUT.PUT_LINE('Business Phone - ' || rec_agent.business_phone);
END;
/
