
/*
    Assertain that the user currently logged into the database has the
    EXECUTE privilege for the UTL_FILE package. 
    Returns 'Y' if the user has the privilege, 'N' if the user does not.
*/
CREATE OR REPLACE FUNCTION func_verify_privs
RETURN CHAR IS

    k_permission_yes            CONSTANT            CHAR(1) := 'Y';
    k_permission_no             CONSTANT            CHAR(1) := 'N';
    k_utl_file_table            CONSTANT            CHAR(8) := 'UTL_FILE';
    k_privilege_exec            CONSTANT            user_tab_privs.privilege%TYPE := 'EXECUTE';

    v_user                                          VARCHAR(100);
    v_privilege_actual                              user_tab_privs.privilege%TYPE;
    v_function_response                             CHAR(1);

BEGIN

    -- Find the username of the currently logged in user.
    SELECT user
    INTO v_user
    FROM dual;

    -- Find the privilege granted to the user for the UTL_FILE package.
    SELECT privilege
    INTO v_privilege_actual
    FROM user_tab_privs
    WHERE table_name = k_utl_file_table
    AND grantee = v_user;

    -- Compare the privilege that the user has to the privilege required.
    IF v_privilege_actual = k_privilege_exec THEN
        v_function_response := k_permission_yes;
    ELSE 
        v_function_response := k_permission_no;
    END IF;

    RETURN v_function_response;
END;
/


/*
    Before every new entry is added to the payroll_load table, 
    insert two records into the new_transactions table as per Double Entry
    Accounting standards. If either of the transactions caused an Exception,
    sets the status of the entry going into payroll_load as Bad, otherwise as
    Good.
*/
CREATE OR REPLACE TRIGGER new_payroll_entry_air
BEFORE
INSERT
ON payroll_load
FOR EACH ROW

DECLARE
    k_payroll_desc              CONSTANT        new_transactions.description%TYPE := 'Payroll for Employee ';
    k_accounts_payable          CONSTANT        new_transactions.account_no%TYPE := 2050;
    k_payroll_expense           CONSTANT        new_transactions.account_no%TYPE := 4045;
    k_credit                    CONSTANT        new_transactions.transaction_type%TYPE := 'C';
    k_debit                     CONSTANT        new_transactions.transaction_type%TYPE := 'D';
    k_payroll_status_good       CONSTANT        payroll_load.status%TYPE := 'G';
    k_payroll_status_bad        CONSTANT        payroll_load.status%TYPE := 'B';

BEGIN

    -- Insert transaction as a CREDIT for accounts payable.
    INSERT INTO new_transactions (transaction_no, transaction_date, description,
        account_no, transaction_type, transaction_amount)
    VALUES (wkis_seq.NEXTVAL, :NEW.payroll_date, k_payroll_desc || :NEW.employee_id,
        k_accounts_payable,  k_credit, :NEW.amount);


    -- Insert transaction as a DEBIT for payroll expense.
    INSERT INTO new_transactions (transaction_no, transaction_date, description,
        account_no, transaction_type, transaction_amount)
    VALUES(wkis_seq.CURRVAL, :NEW.payroll_date, k_payroll_desc || :NEW.employee_id,
        k_payroll_expense, k_debit, :NEW.amount);

    -- If the transactions were inserted correctly then set status to Good.
    :NEW.status := k_payroll_status_good;

    -- If the transactions were not inserted correctly then set status to Bad.
    EXCEPTION
        WHEN others THEN
            :NEW.status := k_payroll_status_bad;
END;
/


/*
    Procedure to be performed at month's end. This will zero out all of the temporary 
    Revenue and Expense accounts by inserting transactions into the new_transactions table
    based on the account_balance of each account. The inserted transactions follow the 
    Double Entry Accounting system.
*/
CREATE OR REPLACE PROCEDURE proc_month_end
IS

    k_owner_equity_account      CONSTANT        new_transactions.account_no%TYPE := 5555;
    k_revenue_type              CONSTANT        account.account_type_code%TYPE := 'RE';
    k_expense_type              CONSTANT        account.account_type_code%TYPE := 'EX';
    k_description               CONSTANT        new_transactions.description%TYPE := 'Month End for Account ';
    k_credit                    CONSTANT        new_transactions.transaction_type%TYPE := 'C';
    k_debit                     CONSTANT        new_transactions.transaction_type%TYPE := 'D';

    CURSOR c_rev_accounts IS
        SELECT account_no, account_name, account_balance
        FROM account
        WHERE account_type_code = k_revenue_type;

    CURSOR c_exp_accounts IS
        SELECT account_no, account_name, account_balance
        FROM account
        WHERE account_type_code = k_expense_type;

BEGIN

    -- Go through every Revenue account.
    FOR r_rev_accounts IN c_rev_accounts LOOP

        -- Insert transaction to Zero Out the Revenue account as a DEBIT.
        INSERT INTO new_transactions (transaction_no, transaction_date, description,
            account_no, transaction_type, transaction_amount)
        VALUES(wkis_seq.NEXTVAL, SYSDATE, k_description || r_rev_accounts.account_name, 
            r_rev_accounts.account_no, k_debit, r_rev_accounts.account_balance); 

        -- Insert transaction to Zero Out the Revenue account as a CREDIT to the Owner's Equity account.
        INSERT INTO new_transactions (transaction_no, transaction_date, description,
            account_no, transaction_type, transaction_amount)
        VALUES(wkis_seq.CURRVAL, SYSDATE, k_description || r_rev_accounts.account_name,
            k_owner_equity_account, k_credit, r_rev_accounts.account_balance);

    END LOOP;

    -- Go through every Expense account.
    FOR r_exp_accounts IN c_exp_accounts LOOP

        -- Insert transaction to Zero Out the Expense account as a CREDIT.
        INSERT INTO new_transactions (transaction_no, transaction_date, description,
            account_no, transaction_type, transaction_amount)
        VALUES(wkis_seq.NEXTVAL, SYSDATE, k_description || r_exp_accounts.account_name,
            r_exp_accounts.account_no, k_credit, r_exp_accounts.account_balance);

        -- Insert transaction to Zero Out the Expense account as a DEBIT to the Owner's Equity account.   
        INSERT INTO new_transactions (transaction_no, transaction_date, description,
            account_no, transaction_type, transaction_amount)
        VALUES(wkis_seq.CURRVAL, SYSDATE, k_description || r_exp_accounts.account_name,
            k_owner_equity_account, k_debit, r_exp_accounts.account_balance);

    END LOOP;
END;
/

/*
    Procedure to export all records in the new_transactions table to an external file.
    File must already exist before executing this method. 
*/
CREATE OR REPLACE PROCEDURE export_new_transactions
(p_location varchar2, p_filename varchar2) IS

    k_write_access_mode         CONSTANT        CHAR(1) := 'w';
    k_delimiter                 CONSTANT        CHAR(1) := ',';

    v_file_type                                 UTL_FILE.FILE_TYPE;
    v_to_write_transaction                      VARCHAR2(1024);

    CURSOR c_new_transactions IS
        SELECT *
        FROM new_transactions;

BEGIN

    -- Open the file provided and store the file_type for the subsequent file operations.
    v_file_type :=  UTL_FILE.FOPEN(UPPER(p_location), p_filename, k_write_access_mode);


    FOR r_new_transactions IN c_new_transactions LOOP

        -- Clear the text stored in the new line to export.
        v_to_write_transaction := '';

        -- Construct line for exporting.
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.transaction_no + k_delimiter;
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.transaction_date + k_delimiter;
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.description + k_delimiter;
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.account_no + k_delimiter;
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.transaction_type + k_delimiter;
        v_to_write_transaction := v_to_write_transaction + r_new_transactions.transaction_amount;

        -- Write completed line to the file. This method adds a line terminator to the end of each line.
        UTL_FILE.PUT_LINE(v_file_type, v_to_write_transaction);

    END LOOP;

    -- Close the file each record in the new_transactions table has been written to the file.
    UTL_FILE.FCLOSE(v_file_type);

END;
/
