--Lab 7 - Prelab Script
--Task 1
CREATE OR REPLACE TRIGGER new_ata_agent_bir
BEFORE
INSERT
ON ata_agent
FOR EACH ROW

BEGIN
    :NEW.date_of_hire := SYSDATE;
END;
/

--Task 2
CREATE OR REPLACE TRIGGER new_ata_performance_air
AFTER
INSERT
ON ata_performance
FOR EACH ROW

BEGIN
    UPDATE ata_contract
    SET fee = fee + 25
    WHERE contract_number = :NEW.contract_number;
END;
/

--Task 3
CREATE OR REPLACE TRIGGER ata_contract_bur
BEFORE
UPDATE
OF contract_number
ON ata_contract
FOR EACH ROW

BEGIN
    :NEW.contract_number := :OLD.contract_number;
END;
/