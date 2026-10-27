-- 03_default_by_grade.sql
-- Default rate, pricing and losses by Lending Club grade (A = lowest risk).
-- Window functions add each grade's share of the book and the running share.
WITH by_grade AS (
    SELECT
        grade,
        COUNT(*)                                        AS loans,
        SUM(funded_amnt)                                AS funded,
        SUM(is_default)                                 AS defaults,
        AVG(is_default)                                 AS default_rate,
        AVG(int_rate)                                   AS avg_int_rate,
        SUM(principal_loss)                             AS principal_loss
    FROM loans
    GROUP BY grade
)
SELECT
    grade,
    loans,
    ROUND(100.0 * loans / SUM(loans) OVER (), 1)        AS share_of_loans_pct,
    ROUND(100.0 * SUM(loans) OVER (ORDER BY grade) / SUM(loans) OVER (), 1)
                                                        AS cumulative_share_pct,
    defaults,
    ROUND(100.0 * default_rate, 1)                      AS default_rate_pct,
    ROUND(avg_int_rate, 2)                              AS avg_int_rate_pct,
    ROUND(100.0 * principal_loss / funded, 2)           AS loss_rate_pct_of_funded,
    ROUND(default_rate / FIRST_VALUE(default_rate) OVER (ORDER BY grade), 1)
                                                        AS default_rate_vs_grade_a
FROM by_grade
ORDER BY grade;
