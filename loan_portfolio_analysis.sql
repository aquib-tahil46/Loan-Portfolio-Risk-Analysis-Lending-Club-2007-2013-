-- ================================================
-- LOAN PORTFOLIO RISK ANALYSIS PROJECT
-- Author: Aquib Tahil
-- Date: 2026
-- Dataset: Lending Club Loan Data (2007-2015)
-- Source: Kaggle — ka-ka-shi / wordsforthewise
-- Total Records: 2,260,668 (raw) | Sample: 100,000
-- Tools: MySQL 8.0 + Tableau Public
-- ================================================

-- ================================================
-- SECTION 1: DATABASE SETUP
-- ================================================

CREATE DATABASE IF NOT EXISTS lending_club;
USE lending_club;

-- Disable strict mode to allow CSV import with empty values
SET GLOBAL sql_mode = '';
SET SESSION sql_mode = '';
SET GLOBAL local_infile = 1;

-- ================================================
-- SECTION 2: RAW TABLE CREATION
-- All columns stored as TEXT to handle mixed/empty values from CSV
-- ================================================

DROP TABLE IF EXISTS loan_raw;

CREATE TABLE loan_raw (
    id TEXT, member_id TEXT, loan_amnt TEXT, funded_amnt TEXT,
    funded_amnt_inv TEXT, term TEXT, int_rate TEXT, installment TEXT,
    grade TEXT, sub_grade TEXT, emp_title TEXT, emp_length TEXT,
    home_ownership TEXT, annual_inc TEXT, verification_status TEXT,
    issue_d TEXT, loan_status TEXT, pymnt_plan TEXT, url TEXT,
    purpose TEXT, title TEXT, zip_code TEXT, addr_state TEXT,
    dti TEXT, delinq_2yrs TEXT, earliest_cr_line TEXT,
    inq_last_6mths TEXT, mths_since_last_delinq TEXT,
    mths_since_last_record TEXT, open_acc TEXT, pub_rec TEXT,
    revol_bal TEXT, revol_util TEXT, total_acc TEXT,
    initial_list_status TEXT, out_prncp TEXT, out_prncp_inv TEXT,
    total_pymnt TEXT, total_pymnt_inv TEXT, total_rec_prncp TEXT,
    total_rec_int TEXT, total_rec_late_fee TEXT, recoveries TEXT,
    collection_recovery_fee TEXT, last_pymnt_d TEXT,
    last_pymnt_amnt TEXT, next_pymnt_d TEXT, last_credit_pull_d TEXT,
    collections_12_mths_ex_med TEXT, mths_since_last_major_derog TEXT,
    policy_code TEXT, application_type TEXT, annual_inc_joint TEXT,
    dti_joint TEXT, verification_status_joint TEXT,
    acc_now_delinq TEXT, tot_coll_amt TEXT, tot_cur_bal TEXT,
    open_acc_6m TEXT, open_il_6m TEXT, open_il_12m TEXT,
    open_il_24m TEXT, mths_since_rcnt_il TEXT, total_bal_il TEXT,
    il_util TEXT, open_rv_12m TEXT, open_rv_24m TEXT,
    max_bal_bc TEXT, all_util TEXT, total_rev_hi_lim TEXT,
    inq_fi TEXT, total_cu_bal TEXT, inq_last_12m TEXT,
    acc_open_past_24mths TEXT, avg_cur_bal TEXT, bc_open_to_buy TEXT,
    bc_util TEXT, chargeoff_within_12_mths TEXT, delinq_amnt TEXT,
    mo_sin_old_il_acct TEXT, mo_sin_old_rev_tl_op TEXT,
    mo_sin_rcnt_rev_tl_op TEXT, mo_sin_rcnt_tl TEXT,
    mort_acc TEXT, mths_since_recent_bc TEXT,
    mths_since_recent_bc_dlq TEXT, mths_since_recent_inq TEXT,
    mths_since_recent_revol_delinq TEXT, num_accts_ever_120_pd TEXT,
    num_actv_bc_tl TEXT, num_actv_rev_tl TEXT, num_bc_sats TEXT,
    num_bc_tl TEXT, num_il_tl TEXT, num_op_rev_tl TEXT,
    num_rev_accts TEXT, num_rev_tl_bal_gt_0 TEXT,
    num_sats TEXT, num_tl_120dpd_2m TEXT, num_tl_30dpd TEXT,
    num_tl_90g_dpd_24m TEXT, num_tl_op_past_12m TEXT,
    pct_tl_nvr_dlq TEXT, percent_bc_gt_75 TEXT,
    pub_rec_bankruptcies TEXT, tax_liens TEXT,
    tot_hi_cred_lim TEXT, total_bal_ex_mort TEXT,
    total_bc_limit TEXT, total_il_high_credit_limit TEXT
);

-- ================================================
-- SECTION 3: DATA IMPORT
-- Using LOAD DATA LOCAL INFILE for large CSV (890K+ rows)
-- Forward slashes required in file path for MySQL
-- ================================================

LOAD DATA LOCAL INFILE 'C:/Users/AQUIB TAHIL/Downloads/loan.csv'
INTO TABLE loan_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify import
SELECT COUNT(*) AS total_raw_rows FROM loan_raw;
-- Expected: ~2,260,668 rows

-- ================================================
-- SECTION 4: DATA QUALITY CHECK
-- Checking NULLs and empty strings in key columns
-- ================================================

SELECT
    COUNT(*)                                                          AS total_rows,
    SUM(CASE WHEN loan_amnt  IS NULL OR loan_amnt  = '' THEN 1 ELSE 0 END) AS null_loan_amnt,
    SUM(CASE WHEN grade      IS NULL OR grade      = '' THEN 1 ELSE 0 END) AS null_grade,
    SUM(CASE WHEN loan_status IS NULL OR loan_status= '' THEN 1 ELSE 0 END) AS null_loan_status,
    SUM(CASE WHEN annual_inc IS NULL OR annual_inc = '' THEN 1 ELSE 0 END) AS null_annual_inc,
    SUM(CASE WHEN dti        IS NULL OR dti        = '' THEN 1 ELSE 0 END) AS null_dti,
    SUM(CASE WHEN int_rate   IS NULL OR int_rate   = '' THEN 1 ELSE 0 END) AS null_int_rate,
    SUM(CASE WHEN issue_d    IS NULL OR issue_d    = '' THEN 1 ELSE 0 END) AS null_issue_d,
    SUM(CASE WHEN total_pymnt IS NULL OR total_pymnt='' THEN 1 ELSE 0 END) AS null_total_pymnt,
    SUM(CASE WHEN out_prncp  IS NULL OR out_prncp  = '' THEN 1 ELSE 0 END) AS null_out_prncp
FROM loan_raw;
-- Result: Only 4 NULLs in annual_inc — data is 99.9% clean

-- ================================================
-- SECTION 5: CLEANED TABLE CREATION
-- Applies: NULLIF (empty string → NULL)
--          COALESCE (NULL → default value)
--          CAST (TEXT → proper numeric/date types)
--          STR_TO_DATE (Lending Club 'Dec-2015' format → DATE)
-- ================================================

CREATE TABLE loan_clean AS
SELECT
    ROW_NUMBER() OVER ()                                          AS loan_id,
    -- Borrower fields
    COALESCE(NULLIF(annual_inc,  ''), '0')                        AS annual_inc,
    COALESCE(NULLIF(dti,         ''), '0')                        AS dti,
    COALESCE(NULLIF(emp_length,  ''), 'Unknown')                  AS emp_length,
    COALESCE(NULLIF(home_ownership,''),'OTHER')                   AS home_ownership,
    COALESCE(NULLIF(addr_state,  ''), 'XX')                       AS addr_state,
    COALESCE(NULLIF(open_acc,    ''), '0')                        AS open_acc,
    COALESCE(NULLIF(pub_rec,     ''), '0')                        AS pub_rec,
    COALESCE(NULLIF(revol_bal,   ''), '0')                        AS revol_bal,
    -- Product fields
    COALESCE(NULLIF(grade,       ''), 'G')                        AS grade,
    COALESCE(NULLIF(sub_grade,   ''), 'G5')                       AS sub_grade,
    COALESCE(NULLIF(int_rate,    ''), '0')                        AS int_rate,
    COALESCE(NULLIF(purpose,     ''), 'other')                    AS purpose,
    COALESCE(NULLIF(term,        ''), '36 months')                AS term,
    -- Loan master fields
    CAST(NULLIF(loan_amnt,   '') AS DECIMAL(12,2))                AS loan_amnt,
    CAST(NULLIF(funded_amnt, '') AS DECIMAL(12,2))                AS funded_amnt,
    COALESCE(NULLIF(loan_status, ''), 'Unknown')                  AS loan_status,
    -- Date conversion: 'Dec-2015' → DATE
    STR_TO_DATE(CONCAT('01-', issue_d),     '%d-%b-%Y')           AS issue_date,
    STR_TO_DATE(CONCAT('01-', last_pymnt_d),'%d-%b-%Y')           AS last_pymnt_date,
    -- Repayment fields
    CAST(NULLIF(installment,     '') AS DECIMAL(12,2))            AS installment,
    CAST(NULLIF(total_pymnt,     '') AS DECIMAL(12,2))            AS total_pymnt,
    CAST(NULLIF(total_rec_prncp, '') AS DECIMAL(12,2))            AS total_rec_prncp,
    CAST(NULLIF(total_rec_int,   '') AS DECIMAL(12,2))            AS total_rec_int,
    CAST(NULLIF(last_pymnt_amnt, '') AS DECIMAL(12,2))            AS last_pymnt_amnt,
    CAST(NULLIF(out_prncp,       '') AS DECIMAL(12,2))            AS out_prncp,
    CAST(NULLIF(recoveries,      '') AS DECIMAL(12,2))            AS recoveries
FROM loan_raw
WHERE NULLIF(loan_amnt,   '') IS NOT NULL
  AND NULLIF(grade,       '') IS NOT NULL
  AND NULLIF(loan_status, '') IS NOT NULL
  AND NULLIF(issue_d,     '') IS NOT NULL;

-- Verify cleaned table
SELECT COUNT(*) AS total_clean_rows FROM loan_clean;
SELECT * FROM loan_clean LIMIT 5;

-- ================================================
-- SECTION 6: STAR SCHEMA CREATION
-- 3-Table design: loan_sample (fact) +
--                 dim_borrower + dim_product
-- Ordered by issue_date for time-series integrity
-- ================================================

-- Performance settings for large table operations
SET GLOBAL net_read_timeout = 3600;
SET GLOBAL net_write_timeout = 3600;
SET GLOBAL wait_timeout      = 28800;

-- FACT TABLE: 100,000 rows ordered chronologically
DROP TABLE IF EXISTS loan_sample;
CREATE TABLE loan_sample AS
SELECT * FROM loan_clean
ORDER BY issue_date
LIMIT 100000;

-- DIMENSION TABLE 1: Borrower Profile
DROP TABLE IF EXISTS dim_borrower;
CREATE TABLE dim_borrower AS
SELECT
    loan_id                               AS borrower_id,
    CAST(annual_inc AS DECIMAL(14,2))     AS annual_inc,
    CAST(dti        AS DECIMAL(8,2))      AS dti,
    emp_length,
    home_ownership,
    addr_state,
    CAST(open_acc   AS UNSIGNED)          AS open_acc,
    CAST(pub_rec    AS UNSIGNED)          AS pub_rec,
    CAST(revol_bal  AS DECIMAL(14,2))     AS revol_bal
FROM loan_clean
ORDER BY issue_date
LIMIT 100000;

-- DIMENSION TABLE 2: Loan Product Info
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product AS
SELECT
    loan_id                                          AS product_id,
    grade,
    sub_grade,
    CAST(REPLACE(int_rate,'%','') AS DECIMAL(6,2))  AS int_rate,
    purpose,
    term
FROM loan_clean
ORDER BY issue_date
LIMIT 100000;

-- Add indexes for faster JOIN performance
ALTER TABLE loan_sample  ADD INDEX idx_loan_id     (loan_id);
ALTER TABLE dim_borrower ADD INDEX idx_borrower_id (borrower_id);
ALTER TABLE dim_product  ADD INDEX idx_product_id  (product_id);

-- Verify all 3 tables match
SELECT 'loan_sample'  AS table_name, COUNT(*) AS row_count FROM loan_sample  UNION ALL
SELECT 'dim_borrower' AS table_name, COUNT(*) AS row_count FROM dim_borrower UNION ALL
SELECT 'dim_product'  AS table_name, COUNT(*) AS row_count FROM dim_product;
-- Expected: All 3 show 100,000 rows

-- ================================================
-- SECTION 7: DATA CLEANING — PURPOSE COLUMN
-- Standardising free-text purpose values to
-- known Lending Club categories
-- ================================================

SET SQL_SAFE_UPDATES = 0;

UPDATE loan_sample
SET purpose = 'other'
WHERE purpose NOT IN (
    'debt_consolidation','credit_card','home_improvement',
    'other','major_purchase','small_business','car',
    'medical','moving','vacation','house',
    'wedding','renewable_energy','educational'
);

UPDATE dim_product
SET purpose = 'other'
WHERE purpose NOT IN (
    'debt_consolidation','credit_card','home_improvement',
    'other','major_purchase','small_business','car',
    'medical','moving','vacation','house',
    'wedding','renewable_energy','educational'
);

-- Verify distinct purpose values
SELECT purpose, COUNT(*) AS loan_count
FROM dim_product
GROUP BY purpose
ORDER BY loan_count DESC;

-- ================================================
-- SECTION 8: ANALYTICAL QUERIES
-- Techniques: 3-Table JOIN, CTE, Window Functions
--             (RANK, LAG, Running Total), Subquery
-- ================================================

-- -----------------------------------------------
-- QUERY 1: 3-Table JOIN — Loan Summary by Grade & Purpose
-- Business Question: Which grade-purpose combination
-- drives the most volume and income?
-- -----------------------------------------------

SELECT
    dp.grade,
    dp.purpose,
    COUNT(lc.loan_id)                                       AS total_loans,
    ROUND(AVG(dp.int_rate), 2)                              AS avg_interest_rate,
    ROUND(AVG(CAST(db.annual_inc AS DECIMAL(14,2))), 0)    AS avg_borrower_income,
    ROUND(SUM(lc.loan_amnt), 0)                             AS total_disbursed
FROM loan_sample lc
JOIN dim_borrower db ON lc.loan_id = db.borrower_id
JOIN dim_product  dp ON lc.loan_id = dp.product_id
GROUP BY dp.grade, dp.purpose
ORDER BY dp.grade, total_disbursed DESC
LIMIT 100;

-- -----------------------------------------------
-- QUERY 2: CTE — NPA Rate by Grade
-- Business Question: Which grades carry the highest
-- default risk as a percentage of total loans?
-- -----------------------------------------------

WITH npa_by_grade AS (
    SELECT
        grade,
        COUNT(loan_id)                                             AS total_loans,
        SUM(CASE WHEN loan_status IN ('Charged Off','Default')
                 THEN 1 ELSE 0 END)                               AS defaulted_loans
    FROM loan_sample
    GROUP BY grade
)
SELECT
    grade,
    total_loans,
    defaulted_loans,
    ROUND(defaulted_loans * 100.0 / total_loans, 2)               AS npa_rate_pct
FROM npa_by_grade
ORDER BY grade;

-- -----------------------------------------------
-- QUERY 3: Window Function — Running Total by Month
-- Business Question: How has cumulative disbursement
-- grown over the portfolio lifetime?
-- -----------------------------------------------

SELECT
    DATE_FORMAT(issue_date, '%Y-%m')                              AS issue_month,
    COUNT(loan_id)                                                AS monthly_loans,
    ROUND(SUM(loan_amnt), 0)                                      AS monthly_disbursed,
    ROUND(SUM(SUM(loan_amnt)) OVER (
          ORDER BY DATE_FORMAT(issue_date, '%Y-%m')), 0)          AS cumulative_disbursed
FROM loan_sample
WHERE issue_date IS NOT NULL
GROUP BY issue_month
ORDER BY issue_month;

-- -----------------------------------------------
-- QUERY 4: Window Function — RANK by Income Within Grade
-- Business Question: Who are the highest-income
-- borrowers within each risk grade?
-- -----------------------------------------------

SELECT
    loan_id,
    grade,
    loan_amnt,
    loan_status,
    CAST(annual_inc AS DECIMAL(14,2))                             AS annual_inc,
    RANK() OVER (
        PARTITION BY grade
        ORDER BY CAST(annual_inc AS DECIMAL(14,2)) DESC)          AS income_rank_in_grade
FROM loan_sample
LIMIT 200;

-- -----------------------------------------------
-- QUERY 5: Window Function — LAG — MoM NPA Change
-- Business Question: Is the monthly default amount
-- increasing or decreasing over time?
-- -----------------------------------------------

WITH monthly_npa AS (
    SELECT
        DATE_FORMAT(issue_date, '%Y-%m')                          AS month,
        SUM(CASE WHEN loan_status IN ('Charged Off','Default')
                 THEN loan_amnt ELSE 0 END)                       AS npa_amount
    FROM loan_sample
    WHERE issue_date IS NOT NULL
    GROUP BY month
)
SELECT
    month,
    npa_amount,
    LAG(npa_amount) OVER (ORDER BY month)                         AS prev_month_npa,
    ROUND(
        (npa_amount - LAG(npa_amount) OVER (ORDER BY month))
        * 100.0 /
        NULLIF(LAG(npa_amount) OVER (ORDER BY month), 0)
    , 2)                                                          AS mom_change_pct
FROM monthly_npa
ORDER BY month;

-- -----------------------------------------------
-- QUERY 6: Subquery — High Value Bad Loans vs Portfolio Avg
-- Business Question: Which defaulted loans are
-- above the portfolio average loan amount?
-- -----------------------------------------------

SELECT
    loan_id,
    grade,
    loan_status,
    loan_amnt,
    CAST(annual_inc AS DECIMAL(14,2))                             AS annual_inc,
    CAST(int_rate   AS DECIMAL(6,2))                              AS int_rate
FROM loan_sample
WHERE loan_status IN (
    'Charged Off',
    'Late (31-120 days)',
    'Late (16-30 days)',
    'In Grace Period'
)
AND loan_amnt > (
    SELECT AVG(loan_amnt)
    FROM loan_sample
)
ORDER BY loan_amnt DESC
LIMIT 200;

-- -----------------------------------------------
-- QUERY 7: CTE — Risk Category Classification
-- Business Question: What is the total exposure
-- and average loan by risk tier?
-- -----------------------------------------------

WITH risk_buckets AS (
    SELECT
        loan_id,
        loan_amnt,
        loan_status,
        CASE
            WHEN loan_status = 'Fully Paid' THEN 'Low Risk'
            WHEN loan_status = 'Current'    THEN 'Medium Risk'
            ELSE                                 'High Risk'
        END                                                       AS risk_category
    FROM loan_sample
)
SELECT
    risk_category,
    COUNT(loan_id)                                                AS total_loans,
    ROUND(AVG(loan_amnt), 0)                                      AS avg_loan_amount,
    ROUND(SUM(loan_amnt), 0)                                      AS total_exposure
FROM risk_buckets
GROUP BY risk_category
ORDER BY total_loans DESC;

-- -----------------------------------------------
-- QUERY 8: JOIN + Aggregation — Recovery Rate by Grade
-- Business Question: How much of defaulted loan
-- value is recovered per grade?
-- -----------------------------------------------

SELECT
    grade,
    COUNT(loan_id)                                                AS defaulted_loans,
    ROUND(SUM(loan_amnt),  0)                                     AS total_defaulted_amt,
    ROUND(SUM(recoveries), 0)                                     AS total_recovered,
    ROUND(SUM(recoveries) * 100.0 /
          NULLIF(SUM(loan_amnt), 0), 2)                           AS recovery_rate_pct
FROM loan_sample
WHERE loan_status IN ('Charged Off', 'Default')
GROUP BY grade
ORDER BY grade;

-- ================================================
-- END OF PROJECT
-- ================================================
-- Summary:
-- Tables Created  : loan_raw, loan_clean,
--                   loan_sample, dim_borrower, dim_product
-- Records Analysed: 100,000 (chronological sample)
-- Queries Written : 8 (JOIN, CTE x2, Window x3, Subquery)
-- Key Findings    :
--   1. Grade G has 27% NPA — highest default risk
--   2. Grade G recovery rate < 3% — near-total loss
--   3. Portfolio grew 10x from 2007 to 2013
--   4. Mid Income x Grade B = largest volume segment
--   5. 84.6% loans fully paid — portfolio is healthy overall
-- ================================================
