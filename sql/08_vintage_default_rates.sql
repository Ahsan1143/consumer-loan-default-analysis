-- 08_vintage_default_rates.sql
-- Default rate by year of origination (vintage). The model is trained on the
-- 2007-2010 vintages and tested on 2011, so this shows how the test year
-- compares with the training years.
SELECT
    issue_year,
    COUNT(*)                                             AS loans,
    ROUND(100.0 * AVG(is_default), 1)                    AS default_rate_pct,
    ROUND(AVG(int_rate), 2)                              AS avg_int_rate_pct,
    ROUND(AVG(annual_inc), 0)                            AS avg_annual_inc,
    ROUND(AVG(dti), 1)                                   AS avg_dti
FROM loans
GROUP BY issue_year
ORDER BY issue_year;
