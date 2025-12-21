create or replace FUNCTION fn_check_operation_allowed (
    p_operation_date IN DATE DEFAULT SYSDATE,
    p_denial_reason OUT VARCHAR2
) RETURN BOOLEAN
AS
    v_day_of_week VARCHAR2(3);
    v_day_number NUMBER;
    v_is_holiday NUMBER;
    v_holiday_name VARCHAR2(100);
    v_next_month_end DATE;
BEGIN
    -- Get day of week (uppercase 3-letter format: MON, TUE, etc.)
    v_day_of_week := TO_CHAR(p_operation_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_day_number := TO_NUMBER(TO_CHAR(p_operation_date, 'D')); -- 1=Sunday, 7=Saturday

    -- Check if it's a weekday (Monday-Friday)
    -- In Oracle, with D format: 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
    IF v_day_number BETWEEN 2 AND 6 THEN
        p_denial_reason := 'Operation denied: Cannot perform DML operations on weekdays (' || v_day_of_week || ')';
        RETURN FALSE;
    END IF;

    -- Calculate next month's end date for holiday checking
    v_next_month_end := LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), 1));

    -- Check if today is a public holiday (within upcoming month)
    BEGIN
        SELECT COUNT(*), MAX(holiday_name)
        INTO v_is_holiday, v_holiday_name
        FROM public_holidays
        WHERE TRUNC(holiday_date) = TRUNC(p_operation_date)
        AND is_active = 'Y'
        AND holiday_date BETWEEN TRUNC(SYSDATE) AND v_next_month_end;

        IF v_is_holiday > 0 THEN
            p_denial_reason := 'Operation denied: Cannot perform DML operations on public holiday (' || v_holiday_name || ')';
            RETURN FALSE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Not a holiday, continue
    END;

    -- If we reach here, operation is allowed (weekend and not a holiday)
    p_denial_reason := NULL;
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        p_denial_reason := 'Error checking operation permission: ' || SQLERRM;
        RETURN FALSE;
END fn_check_operation_allowed;
