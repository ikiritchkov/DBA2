--Lab 5 Prelab Script
--Task 1

DECLARE
    k_contract_no       CONSTANT        ata_contract.contract_number%TYPE := 8;
    v_client_id                         ata_contract.client_id%TYPE;

BEGIN
    SELECT client_id
    INTO v_client_id
    FROM ata_contract
    WHERE contract_number = k_contract_no;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Contract number ' || k_contract_no || ' does not exist!');
END;
/

--Task 2
DECLARE
    k_client_id         CONSTANT        ata_contract.client_id%TYPE := '0000020';
    v_contract_fee                      ata_contract.fee%TYPE;

BEGIN
    SELECT fee
    INTO v_contract_fee
    FROM ata_contract
    WHERE client_id = k_client_id;

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Client ' || k_client_id || ' has more than one fee!');
END;
/

--Task 3
DECLARE
    k_500_dollars       CONSTANT        ata_contract.fee%TYPE := 500.00;
    k_eventtype_retire  CONSTANT        ata_contract.event_type%TYPE := 'Retirement Party';

    ex_eventtype_exists                 EXCEPTION;

BEGIN
    UPDATE ata_contract
    SET fee = fee + k_500_dollars
    WHERE event_type = k_eventtype_retire;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE ex_eventtype_exists;
    END IF;

EXCEPTION
    WHEN ex_eventtype_exists THEN
        DBMS_OUTPUT.PUT_LINE(k_eventtype_retire || ' event type does not exist!');
END;
/

--Task 4
DECLARE
    k_500_dollars       CONSTANT        ata_contract.fee%TYPE := 500.00;
    k_eventtype_retire  CONSTANT        ata_contract.event_type%TYPE := 'Retirement Party';

BEGIN
    UPDATE ata_contract
    SET fee = fee + k_500_dollars
    WHERE event_type = k_eventtype_retire;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, k_eventtype_retire || ' event type does not exist!');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/