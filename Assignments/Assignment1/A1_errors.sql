
-- wrong account number
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payroll paid', 1333, 'C', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll paid', 1250, 'C', 10000);

-- wrong type
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payroll paid', 2050, 'C', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll paid', 1250, 'D', 10000);


INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll paid', 2580, 'P', 10000);


-- wrong amount 
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Royalty revenue', 2050, 'C', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', -100);


INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 10000);

-- debits do not match  
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Royalty revenue', 2050, 'C', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 300);


INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 1020);

-- Null value 
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Royalty revenue', 2050, 'C', 15000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 5000);

INSERT INTO new_transactions
VALUES
(null, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 10000);
