--Lab 6 - Lab Script
--Task 2

-- Return the difference in hours between two dates.
-- Throws exception when the start date occurs after the second date.
CREATE OR REPLACE FUNCTION func_hours_between
(f_start DATE, f_end DATE) 
RETURN NUMBER IS

    k_days_to_hours                 NUMBER := 24;
    v_difference                    NUMBER;

    BEGIN
        v_difference := (f_end - f_start) * k_days_to_hours;
        IF v_difference < 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'End date before start date');
        END IF;

        RETURN v_difference;
    END;
/

-- Return the fee rate for an event.
CREATE OR REPLACE FUNCTION func_event_fee_rate
(f_event ata_contract.event_type%TYPE) 
RETURN NUMBER IS

    k_ev_concert                ata_contract.event_type%TYPE := 'CONCERT';
    k_ev_childrens              ata_contract.event_type%TYPE := 'CHILDRENS PARTY';
    k_ev_wedding                ata_contract.event_type%TYPE := 'WEDDING';
    k_ev_divorce                ata_contract.event_type%TYPE := 'DIVORCE PARTY';

    k_fee_concert               ata_contract.fee%TYPE := 1000;
    k_fee_childrens             ata_contract.fee%TYPE := 335;
    k_fee_wedding               ata_contract.fee%TYPE := 300;
    k_fee_divorce               ata_contract.fee%TYPE := 170;
    k_fee_other                 ata_contract.fee%TYPE := 100;

    v_event                     ata_contract.event_type%TYPE := UPPER(f_event);
    v_ev_fee                    NUMBER;

    BEGIN

        CASE v_event 
            WHEN k_ev_concert THEN
                v_ev_fee := k_fee_concert;
            WHEN k_ev_childrens THEN
                v_ev_fee := k_fee_childrens;
            WHEN k_ev_wedding THEN
                v_ev_fee := k_fee_wedding;
            WHEN k_ev_divorce THEN
                v_ev_fee := k_fee_divorce;
            ELSE
                v_ev_fee := k_fee_other;
        END CASE;
        
        RETURN v_ev_fee;
    END;
/

-- Returns the subtotal for an event.
-- Throws an exception when the subtotal is negative.
CREATE OR REPLACE FUNCTION func_calc_fee_subtotal
(f_hours NUMBER, f_rate NUMBER) 
RETURN NUMBER IS

    v_subtotal                      NUMBER;

    BEGIN
        v_subtotal := f_hours * f_rate;

        IF v_subtotal < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Negative number');
        END IF;

        RETURN v_subtotal;

    END;
/

-- Return additional fee if the date is a monday or friday.
CREATE OR REPLACE FUNCTION func_additional_fee
(f_performance_date DATE) 
RETURN NUMBER IS

    k_day_friday                    CHAR(6) := 'FRIDAY';
    k_day_monday                    CHAR(6) := 'MONDAY';
    k_fee_mon_fri                   ata_contract.fee%TYPE := 100;
    k_fee_not_mon_fri               ata_contract.fee%TYPE := 0;

    v_fee                           ata_contract.fee%TYPE;
    v_date                          VARCHAR2(30) := UPPER(TO_CHAR(f_performance_date, 'FmDay'));

    BEGIN

        CASE v_date
            WHEN k_day_friday THEN
                v_fee := k_fee_mon_fri;
            WHEN k_day_monday THEN
                v_fee := k_fee_mon_fri;
            ELSE 
                v_fee := k_fee_not_mon_fri;
        END CASE;

        DBMS_OUTPUT.PUT_LINE(v_date);
        DBMS_OUTPUT.PUT_LINE(v_fee);

        RETURN v_fee;
    END;
/

-- Return total fee which is the sum of the subtotal and the additional fee.
-- Throws an exception when the calculated total is negative.
CREATE OR REPLACE FUNCTION func_calc_fee_total
(f_base_fee ata_contract.fee%TYPE, f_add_fee ata_contract.fee%TYPE)
RETURN ata_contract.fee%TYPE IS

    v_total                         ata_contract.fee%TYPE;

    BEGIN
        v_total := f_base_fee + f_add_fee;

        IF v_total < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Negative number');
        END IF;

        RETURN v_total;

    END;
/

-- Updates the fee for a contract.
CREATE OR REPLACE PROCEDURE proc_update_contract_fee
(p_contract_number ata_contract.contract_number%TYPE, p_fee ata_contract.fee%TYPE) IS

    BEGIN

        UPDATE ata_contract
        SET fee = p_fee
        WHERE contract_number = p_contract_number;

    END;
/

-- Update the fee for each contract in ata_contract table.
DECLARE

    v_contract_number                   ata_contract.contract_number%TYPE;
    v_contract_total_fee                ata_contract.fee%TYPE;

    v_performance_length                NUMBER;
    v_event_fee_rate                    NUMBER;
    v_subtotal                          NUMBER;
    v_additional_fee                    NUMBER;
    v_performance_total                 NUMBER;

    CURSOR c_contract IS
        SELECT contract_number, event_type
        FROM ata_contract;

    CURSOR c_performance IS
        SELECT performance_date, start_time, stop_time
        FROM ata_performance
        WHERE contract_number = v_contract_number;

BEGIN
    FOR r_contract IN c_contract LOOP

        v_contract_number := r_contract.contract_number;

        v_event_fee_rate := 0;
        v_contract_total_fee := 0;

        FOR r_performance IN c_performance LOOP

            BEGIN

                -- Reset all performance variables
                v_performance_length := 0;
                v_event_fee_rate := 0;
                v_subtotal := 0;
                v_additional_fee := 0;
                v_performance_total := 0;

                SELECT func_hours_between(r_performance.start_time, r_performance.stop_time)
                INTO v_performance_length
                FROM DUAL;

                SELECT func_event_fee_rate(r_contract.event_type)
                INTO v_event_fee_rate
                FROM DUAL;

                SELECT func_calc_fee_subtotal(v_performance_length, v_event_fee_rate)
                INTO v_subtotal
                FROM DUAL;

                SELECT func_additional_fee(r_performance.performance_date)
                INTO v_additional_fee
                FROM DUAL;

                SELECT func_calc_fee_total(v_subtotal, v_additional_fee)
                INTO v_performance_total
                FROM DUAL;

                v_contract_total_fee := v_contract_total_fee + v_performance_total;

            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);

            END;
        END LOOP;
        
        proc_update_contract_fee(r_contract.contract_number, v_contract_total_fee);

    END LOOP;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/