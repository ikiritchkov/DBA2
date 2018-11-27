--Lab 4
--Prelab Tasks
--Task 1

--ALTER TABLE ata_entertainer
--ADD more_than_one NUMBER;

DECLARE
	CURSOR c_ent IS
		SELECT entertainer_id, more_than_one
		FROM ata_entertainer
		FOR UPDATE;
	
	TYPE	type_ent IS RECORD (
			id ata_entertainer.entertainer_id%TYPE,
			more_than_one ata_entertainer.more_than_one%TYPE);
	r_ent	type_ent;
	v_count	NUMBER;
	v_temp	NUMBER;
	
BEGIN
	OPEN c_ent;
	
	LOOP
		FETCH c_ent INTO r_ent;
		EXIT WHEN c_ent%NOTFOUND;
		
		SELECT COUNT(entertainer_id)
		INTO v_count
		FROM ata_entertainers_style
		WHERE entertainer_id = r_ent.id;
		
		IF v_count > 1 THEN
			v_temp := v_count;
		ELSE 
			v_temp := NULL;
		END IF;
		
		UPDATE ata_entertainer
		SET more_than_one = v_temp
		WHERE CURRENT OF c_ent;
	END LOOP;

	COMMIT;
END;
/

--Task 2

DECLARE
	CURSOR c_ent IS
		SELECT entertainer_id, more_than_one
		FROM ata_entertainer;
	v_count	NUMBER;
	v_temp NUMBER;
BEGIN
	FOR r_ent IN c_ent LOOP

	SELECT COUNT(entertainer_id)
	INTO v_count
	FROM ata_entertainers_style
	WHERE ata_entertainers_style.entertainer_id = r_ent.entertainer_id;

	CASE
	WHEN v_count > 1
		THEN v_temp := v_count;
	ELSE
		v_temp := NULL;
	END CASE;

	UPDATE ata_entertainer
	SET more_than_one = v_temp
	WHERE entertainer_id = r_ent.entertainer_id;

	END LOOP;

	COMMIT;
END;
/
