CREATE OR REPLACE PROCEDURE sp_log_error (
    p_program_unit IN VARCHAR2,
    p_error_msg    IN VARCHAR2
) AS
BEGIN
    INSERT INTO error_log (
        program_unit,
        error_message,
        user_name
    ) VALUES (
        p_program_unit,
        p_error_msg,
        USER
    );
    COMMIT;
END sp_log_error;
/
