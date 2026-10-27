-- 04_default_by_income_band.sql
-- Does higher income mean lower default risk?
SELECT
    SUBSTR(income_band, 4)                              AS income_range,
    COUNT(*)                                            AS loans,
    ROUND(100.0 * AVG(is_default), 1)                   AS default_rate_pct,
    ROUND(AVG(loan_amnt), 0)                            AS avg_loan_amnt,
    ROUND(100.0 * AVG(loan_to_income), 1)               AS avg_loan_to_income_pct,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct
FROM loans
GROUP BY income_band
ORDER BY income_band;
