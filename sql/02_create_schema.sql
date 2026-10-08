-- 02_create_schema.sql
-- Three-table schema split from telco_clean. All one-to-one on customer_id.

CREATE TABLE customers (
    customer_id     TEXT PRIMARY KEY,
    gender          TEXT NOT NULL,
    senior_citizen  BOOLEAN NOT NULL,
    partner         BOOLEAN NOT NULL,
    dependents      BOOLEAN NOT NULL
);

CREATE TABLE services (
    customer_id        TEXT PRIMARY KEY REFERENCES customers (customer_id),
    phone_service      BOOLEAN NOT NULL,
    multiple_lines     TEXT NOT NULL,
    internet_service   TEXT NOT NULL,
    online_security    TEXT NOT NULL,
    online_backup      TEXT NOT NULL,
    device_protection  TEXT NOT NULL,
    tech_support       TEXT NOT NULL,
    streaming_tv       TEXT NOT NULL,
    streaming_movies   TEXT NOT NULL
);

CREATE TABLE accounts (
    customer_id        TEXT PRIMARY KEY REFERENCES customers (customer_id),
    tenure             INTEGER NOT NULL,
    contract           TEXT NOT NULL,
    paperless_billing  BOOLEAN NOT NULL,
    payment_method     TEXT NOT NULL,
    monthly_charges    NUMERIC(8,2) NOT NULL,
    total_charges      NUMERIC(10,2),
    churn              BOOLEAN NOT NULL
);