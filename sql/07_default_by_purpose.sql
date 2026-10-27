-- 07_default_by_purpose.sql
-- Default rate by the borrower's stated loan purpose. Purposes with fewer than
-- 300 loans are grouped into 'other (small groups)'.
WITH purpose_sizes AS (
    SELECT purpose, COUNT(*) AS n FROM loans GROUP BY purpose
)
SELECT
    CASE WHEN p.n >= 300 THEN REPLACE(l.purpose, '_', ' ') ELSE 'other (small groups)' END
                                                         AS purpose,
    COUNT(*)                                             AS loans,
    ROUND(100.0 * AVG(l.is_default), 1)                  AS default_rate_pct,
    ROUND(AVG(l.int_rate), 2)                            AS avg_int_rate_pct
FROM loans l
JOIN purpose_sizes p ON p.purpose = l.purpose
GROUP BY 1
ORDER BY default_rate_pct DESC;
