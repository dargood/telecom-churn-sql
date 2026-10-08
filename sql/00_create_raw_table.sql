-- 00_create_raw_table.sql
-- Staging table for the raw CSV. All columns are TEXT so the import
-- never fails on bad values. Cleaning happens in 01_clean_data.sql.

CREATE TABLE raw_telco_churn (
    customer_id        TEXT,
    gender             TEXT,
    senior_citizen     TEXT,
    partner            TEXT,
    dependents         TEXT,
    tenure             TEXT,
    phone_service      TEXT,
    multiple_lines     TEXT,
    internet_service   TEXT,
    online_security    TEXT,
    online_backup      TEXT,
    device_protection  TEXT,
    tech_support       TEXT,
    streaming_tv       TEXT,
    streaming_movies   TEXT,
    contract           TEXT,
    paperless_billing  TEXT,
    payment_method     TEXT,
    monthly_charges    TEXT,
    total_charges      TEXT,
    churn              TEXT
);