-- 05_default_by_dti_band.sql
-- Default rate by debt-to-income ratio (monthly debt payments / monthly income,
-- excluding the new Lending Club loan).
SELECT
    SUBSTR(dti_band, 4)                                 AS dti_range,
    COUNT(*)                                            AS loans,
    ROUND(100.0 * AVG(is_default), 1)                   AS default_rate_pct,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct,
    ROUND(AVG(revol_util), 1)                           AS avg_revol_util_pct
FROM loans
GROUP BY dti_band
ORDER BY dti_band;
