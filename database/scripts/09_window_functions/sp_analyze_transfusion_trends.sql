CREATE OR REPLACE PROCEDURE sp_analyze_transfusion_trends AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Daily Transfusion Trends (Last 30 Days) ===');
    
    FOR rec IN (
        SELECT transfusion_date,
               daily_count,
               LAG(daily_count, 1) OVER (ORDER BY transfusion_date) AS previous_day,
               LEAD(daily_count, 1) OVER (ORDER BY transfusion_date) AS next_day,
               AVG(daily_count) OVER (
                   ORDER BY transfusion_date
                   ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
               ) AS seven_day_avg
        FROM (
            SELECT TRUNC(transfusion_date) AS transfusion_date,
                   COUNT(*) AS daily_count
            FROM transfusions
            WHERE transfusion_date >= SYSDATE - 30
            GROUP BY TRUNC(transfusion_date)
        )
        ORDER BY transfusion_date DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(rec.transfusion_date, 'YYYY-MM-DD') || ' | ' ||
            'Count: ' || rec.daily_count || ' | ' ||
            'Prev: ' || NVL(TO_CHAR(rec.previous_day), 'N/A') || ' | ' ||
            '7-Day Avg: ' || ROUND(rec.seven_day_avg, 2)
        );
    END LOOP;
END sp_analyze_transfusion_trends;
/