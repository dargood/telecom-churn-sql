-- 05_dashboard_export.sql
-- Flat extract joining customers, services, accounts for Tableau.
-- Includes tenure_group so the dashboard doesn't need to rebuild it.

SELECT c.customer_id,
       c.gender,
       c.senior_citizen,
       c.partner,
       c.dependents,
       s.phone_service,
       s.multiple_lines,
       s.internet_service,
       s.online_security,
       s.online_backup,
       s.device_protection,
       s.tech_support,
       s.streaming_tv,
       s.streaming_movies,
       a.tenure,
       CASE
           WHEN a.tenure <= 12 THEN '1. 0-12 months'
           WHEN a.tenure <= 24 THEN '2. 13-24 months'
           WHEN a.tenure <= 48 THEN '3. 25-48 months'
           ELSE                     '4. 49-72 months'
       END AS tenure_group,
       a.contract,
       a.paperless_billing,
       a.payment_method,
       a.monthly_charges,
       a.total_charges,
       a.churn
FROM customers c
JOIN services s ON s.customer_id = c.customer_id
JOIN accounts a ON a.customer_id = c.customer_id
ORDER BY c.customer_id;