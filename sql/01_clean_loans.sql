-- =============================================================================
-- 01_clean_loans.sql
-- Builds the analysis table `loans` from the raw staging table `loans_raw`.
--
-- Population: 36-month loans that met Lending Club's credit policy and reached
-- a final outcome (Fully Paid or Charged Off). Every 36-month loan in the file
-- had matured by the data cut-off (mid-2015), so no outcome is missing.
-- 60-month loans are excluded: about a third were still open at the cut-off,
-- and the ones that had closed are skewed toward defaults and early payoffs,
-- which would overstate their default rate.
--
-- Target: is_default = 1 when the loan was Charged Off.
--
-- Leakage control: only fields known at origination are kept as model
-- features. Repayment fields (total_rec_prncp, recoveries) are kept ONLY to
-- measure losses on defaulted loans and are never used as predictors.
-- =============================================================================

DROP TABLE IF EXISTS loans;

CREATE TABLE loans AS
WITH typed AS (
    SELECT
        CAST(id AS INTEGER)                                    AS loan_id,
        CAST(loan_amnt AS REAL)                                AS loan_amnt,
        CAST(funded_amnt AS REAL)                              AS funded_amnt,
        CAST(TRIM(REPLACE(term, 'months', '')) AS INTEGER)     AS term_months,
        CAST(REPLACE(TRIM(int_rate), '%', '') AS REAL)         AS int_rate,
        CAST(installment AS REAL)                              AS installment,
        grade,
        sub_grade,
        CASE
            WHEN emp_length = '< 1 year'  THEN 0
            WHEN emp_length = '10+ years' THEN 10
            WHEN emp_length IS NULL OR emp_length = 'n/a' THEN NULL
            ELSE CAST(REPLACE(REPLACE(emp_length, ' years', ''), ' year', '') AS INTEGER)
        END                                                    AS emp_length_yrs,
        CASE WHEN home_ownership IN ('RENT', 'MORTGAGE', 'OWN')
             THEN home_ownership ELSE 'OTHER' END              AS home_ownership,
        CAST(annual_inc AS REAL)                               AS annual_inc,
        CASE WHEN verification_status = 'not verified'
             THEN 'Not verified' ELSE 'Verified' END           AS income_verified,
        issue_d,
        CAST(SUBSTR(issue_d, 5, 4) AS INTEGER)                 AS issue_year,
        -- 'Jan'..'Dec' -> 1..12 using the position in a 36-char month string
        (INSTR('JanFebMarAprMayJunJulAugSepOctNovDec', SUBSTR(issue_d, 1, 3)) + 2) / 3
                                                               AS issue_month,
        CAST(SUBSTR(earliest_cr_line, 5, 4) AS INTEGER)        AS cr_year,
        (INSTR('JanFebMarAprMayJunJulAugSepOctNovDec', SUBSTR(earliest_cr_line, 1, 3)) + 2) / 3
                                                               AS cr_month,
        purpose,
        addr_state,
        CAST(dti AS REAL)                                      AS dti,
        CAST(delinq_2yrs AS INTEGER)                           AS delinq_2yrs,
        CAST(inq_last_6mths AS INTEGER)                        AS inq_last_6mths,
        CAST(pub_rec AS INTEGER)                               AS pub_rec,
        CAST(open_acc AS INTEGER)                              AS open_acc,
        CAST(total_acc AS INTEGER)                             AS total_acc,
        CAST(revol_bal AS REAL)                                AS revol_bal,
        CAST(REPLACE(TRIM(revol_util), '%', '') AS REAL)       AS revol_util,
        loan_status,
        CAST(total_rec_prncp AS REAL)                          AS total_rec_prncp,
        CAST(recoveries AS REAL)                               AS recoveries
    FROM loans_raw
    WHERE loan_status IN ('Fully Paid', 'Charged Off')
      AND TRIM(term) = '36 months'
)
SELECT
    loan_id,
    loan_amnt,
    funded_amnt,
    term_months,
    int_rate,
    installment,
    grade,
    sub_grade,
    emp_length_yrs,
    home_ownership,
    annual_inc,
    income_verified,
    issue_d,
    issue_year,
    purpose,
    addr_state,
    dti,
    delinq_2yrs,
    inq_last_6mths,
    pub_rec,
    open_acc,
    total_acc,
    revol_bal,
    revol_util,
    ROUND((issue_year + (issue_month - 1) / 12.0) - (cr_year + (cr_month - 1) / 12.0), 2)
                                                         AS credit_history_yrs,
    ROUND(loan_amnt / NULLIF(annual_inc, 0), 4)          AS loan_to_income,
    -- Banded versions for reporting
    CASE
        WHEN annual_inc <  25000 THEN '1. <$25K'
        WHEN annual_inc <  50000 THEN '2. $25-50K'
        WHEN annual_inc <  75000 THEN '3. $50-75K'
        WHEN annual_inc < 100000 THEN '4. $75-100K'
        WHEN annual_inc < 150000 THEN '5. $100-150K'
        ELSE                          '6. $150K+'
    END                                                  AS income_band,
    CASE
        WHEN dti <  5 THEN '1. 0-5%'
        WHEN dti < 10 THEN '2. 5-10%'
        WHEN dti < 15 THEN '3. 10-15%'
        WHEN dti < 20 THEN '4. 15-20%'
        ELSE               '5. 20%+'
    END                                                  AS dti_band,
    CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END AS is_default,
    -- Outcome-only field (NOT a model feature): net principal lost on a default
    CASE WHEN loan_status = 'Charged Off'
         THEN MAX(funded_amnt - total_rec_prncp - recoveries, 0) ELSE 0 END
                                                         AS principal_loss
FROM typed
WHERE annual_inc IS NOT NULL;

CREATE INDEX idx_loans_grade ON loans (grade);
CREATE INDEX idx_loans_year  ON loans (issue_year);
