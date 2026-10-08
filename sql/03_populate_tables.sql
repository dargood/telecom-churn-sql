-- 03_populate_tables.sql
-- Loads customers, services, accounts from telco_clean.
-- customers first: the other two tables reference it.

INSERT INTO customers (customer_id, gender, senior_citizen, partner, dependents)
SELECT customer_id, gender, senior_citizen, partner, dependents
FROM telco_clean;

INSERT INTO services (customer_id, phone_service, multiple_lines, internet_service,
                      online_security, online_backup, device_protection,
                      tech_support, streaming_tv, streaming_movies)
SELECT customer_id, phone_service, multiple_lines, internet_service,
       online_security, online_backup, device_protection,
       tech_support, streaming_tv, streaming_movies
FROM telco_clean;

INSERT INTO accounts (customer_id, tenure, contract, paperless_billing,
                      payment_method, monthly_charges, total_charges, churn)
SELECT customer_id, tenure, contract, paperless_billing,
       payment_method, monthly_charges, total_charges, churn
FROM telco_clean;