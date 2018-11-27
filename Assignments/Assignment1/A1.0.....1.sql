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
    k_debit                 CONSTANT            new_transactions.transaction_type%TYPE := 'D';
    k_credit                CONSTANT            new_transactions.transaction_type%TYPE := 'C';

    v_transaction_no                            new_transactions.transaction_no%TYPE := -1;
    v_transaction_count                         NUMBER;
    v_account_count                             v_transaction_count%TYPE;
    v_transaction_credits                       new_transactions.transaction_amount%TYPE;
    v_transaction_debits                        v_transaction_credits%TYPE;
    v_default_type                              new_transactions.transaction_type%TYPE;
    v_transaction_amount                        v_transaction_count%TYPE;
    v_message                                   VARCHAR2(100);

    CURSOR c_transaction IS
        SELECT * 
        FROM NEW_TRANSACTIONS
        ORDER BY transaction_no; 

    CURSOR c_each_transaction IS
        SELECT *
        FROM NEW_TRANSACTIONS
        WHERE v_transaction_no = transaction_no;
        
BEGIN
    FOR r_transaction IN c_transaction LOOP
        
        BEGIN
            --store current transaction
            IF r_transaction.transaction_no IS NULL THEN
                RAISE_APPLICATION_ERROR(-20999, 'Transaction number is null');
            END IF;

            IF r_transaction.transaction_no <= 0 THEN
                RAISE_APPLICATION_ERROR(-20998, 'Invalid transaction number');
            END IF;

            IF r_transaction.transaction_no > v_transaction_no THEN
                v_transaction_no := r_transaction.transaction_no;

                --Count number of same transaction numbers
                v_transaction_count := 0;
                v_transaction_debits := 0;
                v_transaction_credits := 0;

                --Populate transaction_history table
                INSERT INTO transaction_history
                VALUES (r_transaction.transaction_no, 
                        r_transaction.transaction_date, 
                        r_transaction.description);

                FOR r_each_transaction IN c_each_transaction LOOP
                    v_transaction_count := v_transaction_count + 1;

                    SELECT COUNT(*)
                        INTO v_account_count
                        FROM account
                        WHERE account_no = r_each_transaction.account_no;

                    --Is the account number valid
                    IF v_account_count = 0 THEN
                        RAISE_APPLICATION_ERROR(-20997, 'Invalid account number');
                    END IF;

                    --Is the transaction amount valid
                    IF r_each_transaction.transaction_amount <= 0 THEN
                        RAISE_APPLICATION_ERROR(-20996, 'Invalid transaction amount');
                    END IF;

                    IF r_each_transaction.transaction_type = k_debit THEN
                        v_transaction_debits := v_transaction_debits + r_each_transaction.transaction_amount;
                    ELSIF r_each_transaction.transaction_type = k_credit THEN
                        v_transaction_credits := v_transaction_credits + r_each_transaction.transaction_amount;
                    ELSE
                        RAISE_APPLICATION_ERROR(-20995, 'Invalid transaction type');
                    END IF;

                    SELECT default_trans_type
                        INTO v_default_type
                        FROM account_type
                        JOIN account USING (account_type_code)
                        WHERE account.account_no = r_each_transaction.account_no;

                    IF r_each_transaction.transaction_type = v_default_type THEN
                        v_transaction_amount := r_each_transaction.transaction_amount;
                    ELSE 
                        v_transaction_amount := -1 * r_each_transaction.transaction_amount;
                    END IF;

                    --Update the account balance
                    UPDATE account
                        SET account_balance = account_balance + v_transaction_amount
                        WHERE account_no = r_each_transaction.account_no;

                    --Update the transaction details
                    INSERT INTO transaction_detail
                    VALUES (r_each_transaction.account_no, 
                            r_each_transaction.transaction_no, 
                            r_each_transaction.transaction_type, 
                            r_each_transaction.transaction_amount);

                END LOOP;

                IF v_transaction_credits <> v_transaction_debits THEN
                    RAISE_APPLICATION_ERROR(-20994, 'Credits and debits are not equal');
                END IF;
                
                --Delete transaction from new_transactions table
                DELETE new_transactions
                WHERE transaction_no = r_transaction.transaction_no;

                COMMIT;


            END IF;

        EXCEPTION
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