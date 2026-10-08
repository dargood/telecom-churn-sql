-- 01_clean_data.sql
-- Builds telco_clean from raw_telco_churn with proper data types.
-- Decision: 11 blank total_charges values (tenure = 0) become NULL, not 0.

CREATE TABLE telco_clean AS
SELECT
    TRIM(customer_id)                       AS customer_id,
    gender,
    (senior_citizen = '1')                  AS senior_citizen,
    (partner = 'Yes')                       AS partner,
    (dependents = 'Yes')                    AS dependents,
    tenure::INTEGER                         AS tenure,
    (phone_service = 'Yes')                 AS phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    contract,
    (paperless_billing = 'Yes')             AS paperless_billing,
    payment_method,
    monthly_charges::NUMERIC(8,2)           AS monthly_charges,
    NULLIF(TRIM(total_charges), '')::NUMERIC(10,2) AS total_charges,
    (churn = 'Yes')                         AS churn
FROM raw_telco_churn;

ALTER TABLE telco_clean ADD PRIMARY KEY (customer_id);