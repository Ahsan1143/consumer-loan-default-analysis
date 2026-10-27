-- 02_portfolio_overview.sql
-- Headline view of the completed-loan book.
SELECT
    COUNT(*)                                            AS loans,
    ROUND(SUM(funded_amnt) / 1e6, 1)                    AS funded_musd,
    SUM(is_default)                                     AS defaults,
    ROUND(100.0 * AVG(is_default), 1)                   AS default_rate_pct,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct,
    ROUND(SUM(principal_loss) / 1e6, 1)                 AS principal_loss_musd,
    ROUND(100.0 * SUM(principal_loss) / SUM(funded_amnt), 2)
                                                        AS loss_rate_pct_of_funded,
    ROUND(100.0 * SUM(principal_loss)
          / SUM(CASE WHEN is_default = 1 THEN funded_amnt END), 1)
                                                        AS loss_severity_pct
FROM loans;
