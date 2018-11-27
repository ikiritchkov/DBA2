/*****************************************************************************
** Authors:         Omar Villanueva \^_^/ Iliya Kiritchkov                  **
** Creation Date:   2018                                                    **
** Description:     This system follows a double entry accounting.          **
**                  It takes transactions from NEW_TRANSACTIONS and         **
**                  insertes them into TRANSACTION_DETAIL and               **
**                  TRANSACTION_HISTORY tables. As well as calculating      **
**                  the appropriate account balance in the ACCOUNT table.   **
*****************************************************************************/

DECLARE 
    k_credit                CONSTANT            account_type.default_trans_type%TYPE := 'C';
    k_debit                 CONSTANT            account_type.default_trans_type%TYPE := 'D';

    v_transaction_no                            new_transactions.transaction_no%TYPE := -1;
    v_transaction_credits                       new_transactions.transaction_amount%TYPE;
    v_transaction_debits                        new_transactions.transaction_amount%TYPE;
    v_default_type                              account_type.default_trans_type%TYPE;

    v_account_count                             NUMBER;
    v_transaction_amount                        NUMBER;
    v_message                                   VARCHAR2(100);

-- Main cursor to select all transactions. Ordered by ascending transaction number.
    CURSOR c_transaction IS
        SELECT * 
        FROM NEW_TRANSACTIONS
        ORDER BY transaction_no; 

-- Secondary cursor to select all transactions for a specific transaction number. 
    CURSOR c_each_transaction IS
        SELECT *
        FROM NEW_TRANSACTIONS
        WHERE v_transaction_no = transaction_no;
        
BEGIN
    -- Outer loop to process each transaction. 
    FOR r_transaction IN c_transaction LOOP
        
        BEGIN
            -- Verify that the transaction number is not NULL.
            IF r_transaction.transaction_no IS NULL THEN
                RAISE_APPLICATION_ERROR(-20999, 'Transaction number is NULL');
            END IF;

            -- Verify that the transaction number is positive.
            IF r_transaction.transaction_no <= 0 THEN
                RAISE_APPLICATION_ERROR(-20998, 'Invalid transaction number');
            END IF;

            -- If the current transaction number is the same as the last transaction number, do not enter the loop.
            -- When the transaction numbers are the same, then all of those transactions have already been processed.
            IF r_transaction.transaction_no > v_transaction_no THEN
                v_transaction_no := r_transaction.transaction_no;

                -- Reset the total credits and debits for this transaction number.
                v_transaction_debits := 0;
                v_transaction_credits := 0;

                -- Populate the transaction history table with each transaction entry.
                INSERT INTO transaction_history
                VALUES (r_transaction.transaction_no, 
                        r_transaction.transaction_date, 
                        r_transaction.description);
                
                -- Process all transactions that match transaction number from the outer cursor loop.
                FOR r_each_transaction IN c_each_transaction LOOP

                    -- Verify that the account number exists.
                    SELECT COUNT(*)
                        INTO v_account_count
                        FROM account
                        WHERE account_no = r_each_transaction.account_no;
                    IF v_account_count = 0 THEN
                        RAISE_APPLICATION_ERROR(-20997, 'Invalid account number');
                    END IF;

                    -- Verify that the transaction amount positive.
                    IF r_each_transaction.transaction_amount <= 0 THEN
                        RAISE_APPLICATION_ERROR(-20996, 'Invalid transaction amount');
                    END IF;

                    -- Add the transaction amount to either the Debit total or the Credit total, depending on the transaction type. 
                    -- If the type is neither, then raise an exception.
                    IF r_each_transaction.transaction_type = k_debit THEN
                        v_transaction_debits := v_transaction_debits + r_each_transaction.transaction_amount;
                    ELSIF r_each_transaction.transaction_type = k_credit THEN
                        v_transaction_credits := v_transaction_credits + r_each_transaction.transaction_amount;
                    ELSE
                        RAISE_APPLICATION_ERROR(-20995, 'Invalid transaction type');
                    END IF;

                    -- Determine the default transaction type for the account.
                    SELECT default_trans_type
                        INTO v_default_type
                        FROM account_type
                        JOIN account USING (account_type_code)
                        WHERE account.account_no = r_each_transaction.account_no;
                    
                    -- If the default transaction type of the account matches the transaction type of the transaction, 
                    -- assign it as a positive transaction amount, otherwise assign it as a negative transaction amount.
                    IF r_each_transaction.transaction_type = v_default_type THEN
                        v_transaction_amount := r_each_transaction.transaction_amount;
                    ELSE 
                        v_transaction_amount := -1 * r_each_transaction.transaction_amount;
                    END IF;

                    -- Update the account balance.
                    UPDATE account
                        SET account_balance = account_balance + v_transaction_amount
                        WHERE account_no = r_each_transaction.account_no;

                    -- Update the transaction details.
                    INSERT INTO transaction_detail
                    VALUES (r_each_transaction.account_no, 
                            r_each_transaction.transaction_no, 
                            r_each_transaction.transaction_type, 
                            r_each_transaction.transaction_amount);
                
                -- Remove the transaction entry from new transactions.
                DELETE new_transactions
                WHERE transaction_no = r_each_transaction.transaction_no
                AND account_no = r_each_transaction.account_no ;

                END LOOP;

                -- Verify that the total credits and the total debits of the transaction are equal.
                IF v_transaction_credits <> v_transaction_debits THEN
                    RAISE_APPLICATION_ERROR(-20994, 'Credits and debits are not equal');
                END IF;

                -- If all entries in the transaction were clean and successful, commit all changes.
                COMMIT;
            END IF;

        EXCEPTION
        -- When a transaction does not succeed as a whole, undo all changes that were made for the transaction and update the wkis error log.
            WHEN OTHERS THEN
            v_message := SQLERRM;
                ROLLBACK;
                INSERT INTO wkis_error_log
                VALUES (r_transaction.transaction_no, 
                        r_transaction.transaction_date, 
                        r_transaction.description,
                        v_message);
                COMMIT;
        END;
    END LOOP;
END;
/
