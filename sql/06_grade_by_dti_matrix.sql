-- 06_grade_by_dti_matrix.sql
-- Default rate (%) for each grade x DTI band. Shows whether DTI still
-- separates risk once the grade is known. Cells with fewer than 50 loans are
-- left blank so small samples don't read as signal.
WITH cells AS (
    SELECT grade, dti_band, COUNT(*) AS n, AVG(is_default) AS dr
    FROM loans
    GROUP BY grade, dti_band
)
SELECT
    grade,
    ROUND(100.0 * MAX(CASE WHEN dti_band LIKE '1.%' AND n >= 50 THEN dr END), 1) AS "0-5%",
    ROUND(100.0 * MAX(CASE WHEN dti_band LIKE '2.%' AND n >= 50 THEN dr END), 1) AS "5-10%",
    ROUND(100.0 * MAX(CASE WHEN dti_band LIKE '3.%' AND n >= 50 THEN dr END), 1) AS "10-15%",
    ROUND(100.0 * MAX(CASE WHEN dti_band LIKE '4.%' AND n >= 50 THEN dr END), 1) AS "15-20%",
    ROUND(100.0 * MAX(CASE WHEN dti_band LIKE '5.%' AND n >= 50 THEN dr END), 1) AS "20%+",
    SUM(n)                                                                         AS loans
FROM cells
GROUP BY grade
ORDER BY grade;
