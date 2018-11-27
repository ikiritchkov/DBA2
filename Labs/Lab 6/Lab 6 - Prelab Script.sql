--Lab 6 Prelab Script
--Task 1

CREATE OR REPLACE PROCEDURE proc_new_contract
    (p_entertainer_id ata_contract.entertainer_id%TYPE,
    p_client_id ata_contract.contract_id%TYPE,
    p_event_type ata_contract.event_type%TYPE,
    p_fee ata_contract.fee%TYPE) IS

    BEGIN
        INSERT INTO ata_contract
        VALUES (seq_contract_number.NEXTVAL,
                p_entertainer_id,
                p_client_id,
                p_event_type,
                p_fee);
    END;
/

--Task 2
CREATE OR REPLACE FUNCTION func_length_of
    (line VARCHAR2) RETURN NUMBER IS

    BEGIN
        RETURN LENGTH(line);
    END;
/

--Task 3
CREATE OR REPLACE FUNCTION func_contract_fee
    (f_contract_number ata_contract.contract_number%TYPE) 
    RETURN ata_contract.fee%TYPE IS

    v_fee           ata_contract.fee%TYPE;

    BEGIN
        SELECT fee
        INTO v_fee
        FROM ata_contract
        WHERE contract_number = f_contract_number;

        RETURN v_fee;
    END;
/