/*****************************************************************************
** Authors:         Omar Villanueva \^_^/ Iliya Kiritchkov                  **
** Creation Date:   On Saturday, Oct 13, 2018 at Omar's house               **
** Description:     This system follows a double entry accounting.          **
**                  It takes transactions from NEW_TRANSACTIONS and         **
**                  insertes them into TRANSACTION_DETAIL and               **
**                  TRANSACTION_HISTORY tables. As well as calculating      **
**                  the appropriate account balance in the ACCOUNT table.   **
*****************************************************************************/

SET SERVEROUTPUT ON

DECLARE 
    -- Test Variables
    k_creditType      CONSTANT CHAR(1) := 'C';
    k_debitType       CONSTANT CHAR(1) := 'D';
    v_validTrans      BOOLEAN;
    v_count           NUMBER;
    v_credits         NUMBER;
    v_debits          NUMBER;

    -- Program Variables
    v_transNo         NUMBER := 0;    
    v_errorMsg        VARCHAR2(50);
    v_dfTransType     CHAR(1);
    v_transAmount     NUMBER;

    -- Program Cursors 
    CURSOR c_transactions IS 
        SELECT *
        FROM new_transactions;

    CURSOR c_trans IS 
        SELECT *
        FROM new_transactions
        WHERE v_transNo = transaction_no;

BEGIN 
    FOR r_transactions IN c_transactions LOOP 
        -- Skips repeated transaction_no and processes null values 
        IF (nvl(r_transactions.transaction_no,-1) != v_transNo) THEN
            -- Update new transaction number and set it to -1 if null 
            v_transNo := nvl(r_transactions.transaction_no,-1);
            -- Reset all test variables
            v_validTrans := TRUE;
            v_credits := 0;
            v_debits := 0;
            v_count := 0;

            -- Test if transaction_no has a null value
            IF (v_transNo > 0) THEN 
            -- Test for multiple data errors 
                FOR r_trans IN c_trans LOOP                              
                    -- Test if the account_no exists in the account table
                    SELECT count(*) INTO v_count FROM account
                    WHERE account_no = r_trans.account_no;
                    IF (v_count > 0) THEN
                        -- Test if transaction amount is bigger than 0
                        IF (r_trans.transaction_Amount > 0) THEN
                            --- FUTURE TESTS IMPLENTATIONS --------
                            --- FUTURE TESTS IMPLENTATIONS --------
                              
                            -- Test if debits and credits match part 1 
                            IF (r_trans.transaction_type = k_creditType) THEN 
                                v_credits := v_credits + r_trans.transaction_Amount;
                            ELSIF (r_trans.transaction_type = k_debitType) THEN 
                                v_debits :=  v_debits + r_trans.transaction_Amount;
                            ELSE 
                                v_validTrans := false;
                                v_errorMsg  := 'Invalid transaction type';
                            END IF;

                        ELSE 
                            v_validTrans := false;
                            v_errorMsg  := 'Negative value for a transaction amount';
                        END IF;
                    ELSE 
                        v_validTrans := false;
                        v_errorMsg  := 'Invalid account number';
                    END IF;
              END LOOP;
            ELSE 
                v_validTrans := false;
                v_errorMsg  := 'NULL transaction number';
            END IF; 
           -- Test if debits and credits match part 2
            IF (v_validTrans = true and v_debits != v_credits) THEN
                v_validTrans := false;
                v_errorMsg  := 'Debits and credits are not equal';
            END IF;   

        -- If every single test passed, the database will be updated
            IF (v_validTrans = true)  THEN
                -- Populate transaction_history 
                INSERT INTO transaction_history
                VALUES (r_transactions.transaction_no,
                        r_transactions.transaction_date,
                        r_transactions.description);
                
                FOR r_trans IN c_trans LOOP 
                    -- Get default_trans_type to populate balance 
                    SELECT default_trans_type
                        INTO v_dfTransType
                        FROM account_type 
                        JOIN account ac USING(account_type_code)
                        WHERE ac.account_no = r_trans.account_no;

                    -- If account_type == default type add
                    IF (v_dfTransType = r_trans.transaction_type) THEN  
                        v_transAmount := r_trans.transaction_amount;  

                    -- If account_type != default type substract
                    ELSE 
                        v_transAmount := -1*r_trans.transaction_amount;
                    END IF;

                    -- Update the acount balance                   
                    UPDATE account 
                        SET account_balance = account_balance + v_transAmount
                        WHERE account_no = r_trans.account_no;
                
                    -- Populate transaction_detail
                    INSERT INTO transaction_detail
                    VALUES( r_trans.account_no,
                            r_trans.transaction_no,
                            r_trans.transaction_type,
                            r_trans.transaction_amount);

                    -- Delete transaction record from new_transactions
                    DELETE FROM new_transactions
                    	WHERE account_no = r_trans.account_no 
                        AND transaction_no = r_trans.transaction_no;
			
		    COMMIT;
                END LOOP;
            ELSE 
                INSERT INTO WKIS_ERROR_LOG
                VALUES( r_transactions.transaction_no,
                        r_transactions.transaction_date,
                        r_transactions.description,
                        v_errorMsg);
                DBMS_OUTPUT.PUT_LINE(v_errorMsg);
            END IF;
        END IF;
    END LOOP;
END;
/
