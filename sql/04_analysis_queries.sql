-- 04_analysis_queries.sql
-- Telecom churn analysis. Each query answers one business question.

-- Q1: What is the overall churn rate?
SELECT COUNT(*)                                         AS total_customers,
       COUNT(*) FILTER (WHERE churn)                    AS churned_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE churn)
             / COUNT(*), 2)                             AS churn_rate_pct
FROM accounts;

-- Q2: How does churn differ by contract type?
SELECT a.contract,
       COUNT(*)                                         AS customers,
       COUNT(*) FILTER (WHERE a.churn)                  AS churned,
       ROUND(100.0 * COUNT(*) FILTER (WHERE a.churn)
             / COUNT(*), 2)                             AS churn_rate_pct
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY a.contract
ORDER BY churn_rate_pct DESC;

-- Q3: How does churn differ by internet service type?
SELECT s.internet_service,
       COUNT(*)                                         AS customers,
       COUNT(*) FILTER (WHERE a.churn)                  AS churned,
       ROUND(100.0 * COUNT(*) FILTER (WHERE a.churn)
             / COUNT(*), 2)                             AS churn_rate_pct
FROM customers c
JOIN services s ON s.customer_id = c.customer_id
JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY s.internet_service
ORDER BY churn_rate_pct DESC;

-- Q4: How much monthly recurring revenue is lost to churn?
SELECT SUM(monthly_charges)                                   AS total_monthly_revenue,
       SUM(monthly_charges) FILTER (WHERE churn)              AS monthly_revenue_churned,
       ROUND(100.0 * SUM(monthly_charges) FILTER (WHERE churn)
             / SUM(monthly_charges), 2)                       AS pct_revenue_churned,
       ROUND(AVG(monthly_charges) FILTER (WHERE churn), 2)    AS avg_monthly_churned,
       ROUND(AVG(monthly_charges) FILTER (WHERE NOT churn), 2) AS avg_monthly_retained
FROM accounts;

-- Q5: Which payment methods churn at a higher rate than the overall average?
SELECT payment_method,
       COUNT(*)                                          AS customers,
       COUNT(*) FILTER (WHERE churn)                     AS churned,
       ROUND(100.0 * COUNT(*) FILTER (WHERE churn)
             / COUNT(*), 2)                              AS churn_rate_pct,
       (SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE churn)
                     / COUNT(*), 2)
        FROM accounts)                                   AS overall_rate_pct
FROM accounts
GROUP BY payment_method
HAVING 100.0 * COUNT(*) FILTER (WHERE churn) / COUNT(*)
       > (SELECT 100.0 * COUNT(*) FILTER (WHERE churn) / COUNT(*)
          FROM accounts)
ORDER BY churn_rate_pct DESC;

-- Q6: Do online security and tech support reduce churn?
-- Internet customers only: customers with no internet can't buy either add-on.
SELECT CASE
           WHEN s.online_security = 'Yes' AND s.tech_support = 'Yes' THEN 'Both'
           WHEN s.online_security = 'Yes'                            THEN 'Security only'
           WHEN s.tech_support = 'Yes'                               THEN 'Tech support only'
           ELSE 'Neither'
       END                                               AS protection_level,
       COUNT(*)                                          AS customers,
       COUNT(*) FILTER (WHERE a.churn)                   AS churned,
       ROUND(100.0 * COUNT(*) FILTER (WHERE a.churn)
             / COUNT(*), 2)                              AS churn_rate_pct
FROM customers c
JOIN services s ON s.customer_id = c.customer_id
JOIN accounts a ON a.customer_id = c.customer_id
WHERE s.internet_service <> 'No'
GROUP BY 1
ORDER BY churn_rate_pct DESC;

-- Q7: Which tenure groups churn the most?
SELECT CASE
           WHEN tenure <= 12 THEN '1. 0-12 months'
           WHEN tenure <= 24 THEN '2. 13-24 months'
           WHEN tenure <= 48 THEN '3. 25-48 months'
           ELSE                   '4. 49-72 months'
       END                                               AS tenure_group,
       COUNT(*)                                          AS customers,
       COUNT(*) FILTER (WHERE churn)                     AS churned,
       ROUND(100.0 * COUNT(*) FILTER (WHERE churn)
             / COUNT(*), 2)                              AS churn_rate_pct
FROM accounts
GROUP BY 1
ORDER BY 1;

-- Q8: Which active, high-spending customers show the main churn risk signals?
WITH avg_bill AS (
    SELECT AVG(monthly_charges) AS avg_monthly
    FROM accounts
),
at_risk AS (
    SELECT c.customer_id,
           a.tenure,
           a.monthly_charges
    FROM customers c
    JOIN services s ON s.customer_id = c.customer_id
    JOIN accounts a ON a.customer_id = c.customer_id
    CROSS JOIN avg_bill
    WHERE NOT a.churn
      AND a.contract = 'Month-to-month'
      AND s.internet_service <> 'No'
      AND s.online_security = 'No'
      AND s.tech_support = 'No'
      AND a.monthly_charges > avg_bill.avg_monthly
)
SELECT COUNT(*)                          AS at_risk_customers,
       ROUND(SUM(monthly_charges), 2)    AS monthly_revenue_at_risk,
       ROUND(AVG(monthly_charges), 2)    AS avg_monthly_charge,
       ROUND(AVG(tenure), 1)             AS avg_tenure_months
FROM at_risk;

-- Q9: Top 3 lifetime spenders within each contract type, and their churn status.
WITH ranked AS (
    SELECT c.customer_id,
           a.contract,
           a.tenure,
           a.total_charges,
           a.churn,
           RANK() OVER (
               PARTITION BY a.contract
               ORDER BY a.total_charges DESC NULLS LAST
           ) AS spend_rank
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
)
SELECT contract,
       spend_rank,
       customer_id,
       tenure,
       total_charges,
       churn
FROM ranked
WHERE spend_rank <= 3
ORDER BY contract, spend_rank;

-- Q10: How does each tenure cohort's churn rate compare to the overall rate,
-- and how much does it change from the previous cohort?
WITH cohorts AS (
    SELECT CASE
               WHEN tenure <= 12 THEN '1. 0-12 months'
               WHEN tenure <= 24 THEN '2. 13-24 months'
               WHEN tenure <= 48 THEN '3. 25-48 months'
               ELSE                   '4. 49-72 months'
           END                              AS tenure_group,
           COUNT(*)                         AS customers,
           COUNT(*) FILTER (WHERE churn)    AS churned
    FROM accounts
    GROUP BY 1
)
SELECT tenure_group,
       customers,
       churned,
       ROUND(100.0 * churned / customers, 2)                          AS churn_rate_pct,
       ROUND(100.0 * SUM(churned) OVER () / SUM(customers) OVER (), 2) AS overall_rate_pct,
       ROUND(100.0 * churned / customers
             - 100.0 * SUM(churned) OVER () / SUM(customers) OVER (), 2) AS diff_vs_overall_pts,
       ROUND(100.0 * churned / customers
             - LAG(100.0 * churned / customers) OVER (ORDER BY tenure_group), 2) AS change_vs_prev_pts
FROM cohorts
ORDER BY tenure_group;