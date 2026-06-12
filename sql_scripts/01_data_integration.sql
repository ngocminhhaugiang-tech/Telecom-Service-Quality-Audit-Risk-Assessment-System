-- 1. Bảng Dân số (Population)
CREATE TABLE population (
    id INT,
    zip_code VARCHAR(20) PRIMARY KEY,
    population_count INT
);

-- 2. Bảng Nhân khẩu học (Demographics) - Bảng chứa thông tin gốc của khách hàng
CREATE TABLE demographics (
    customer_id VARCHAR(50) PRIMARY KEY,
    count INT,
    gender VARCHAR(10),
    age INT,
    under_30 VARCHAR(5),
    senior_citizen VARCHAR(5),
    married VARCHAR(5),
    dependents VARCHAR(5),
    number_of_dependents INT
);

-- 3. Bảng Vị trí (Location)
CREATE TABLE location (
    location_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    count INT,
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    lat_long VARCHAR(100),
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    CONSTRAINT fk_location_customer FOREIGN KEY (customer_id) REFERENCES demographics(customer_id),
    CONSTRAINT fk_location_population FOREIGN KEY (zip_code) REFERENCES population(zip_code)
);

-- 4. Bảng Dịch vụ khách hàng (Services)
CREATE TABLE services (
    service_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    count INT,
    quarter VARCHAR(10),
    referred_a_friend VARCHAR(5),
    number_of_referrals INT,
    tenure_in_months INT,
    offer VARCHAR(50),
    phone_service VARCHAR(5),
    avg_monthly_long_distance_charges NUMERIC(10, 2),
    multiple_lines VARCHAR(5),
    internet_service VARCHAR(5),
    internet_type VARCHAR(50),
    avg_monthly_gb_download INT,
    online_security VARCHAR(5),
    online_backup VARCHAR(5),
    device_protection_plan VARCHAR(5),
    premium_tech_support VARCHAR(5),
    streaming_tv VARCHAR(5),
    streaming_movies VARCHAR(5),
    streaming_music VARCHAR(5),
    unlimited_data VARCHAR(5),
    contract VARCHAR(50),
    paperless_billing VARCHAR(5),
    payment_method VARCHAR(50),
    monthly_charge NUMERIC(10, 2),
    total_charges NUMERIC(10, 2),
    total_refunds NUMERIC(10, 2),
    total_extra_data_charges NUMERIC(10, 2),
    total_long_distance_charges NUMERIC(10, 2),
    total_revenue NUMERIC(10, 2),
    CONSTRAINT fk_services_customer FOREIGN KEY (customer_id) REFERENCES demographics(customer_id)
);

-- 5. Bảng Trạng thái Churn (Status)
CREATE TABLE status (
    status_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    count INT,
    quarter VARCHAR(10),
    satisfaction_score INT,
    customer_status VARCHAR(20),
    churn_label VARCHAR(5),
    churn_value INT,
    churn_score INT,
    cltv INT,
    churn_category VARCHAR(100),
    churn_reason TEXT,
    CONSTRAINT fk_status_customer FOREIGN KEY (customer_id) REFERENCES demographics(customer_id)
);
------ Bảng tổng hợp thông tin từ 5 bảng trên để dễ dàng cho việc truy vấn -------------------------------------
CREATE OR REPLACE VIEW vw_churn_master AS
WITH cltv_threshold AS (
    -- Tính ngưỡng 0.75 một lần duy nhất
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cltv) as p75 
    FROM status
)
SELECT
    c.customer_id,
    d.gender, d.age, d.under_30, d.senior_citizen, d.married, d.dependents,
    COALESCE(d.number_of_dependents, 0) AS number_of_dependents,
    l.city, l.state, l.zip_code, l.latitude, l.longitude,
    p.population_size,
    sv.contract, sv.tenure_in_months, sv.offer, sv.phone_service, 
    sv.multiple_lines, sv.internet_service, sv.internet_type, sv.avg_monthly_gb_download,
    sv.online_security, sv.online_backup, sv.device_protection_plan, 
    sv.premium_tech_support, sv.streaming_tv, sv.streaming_movies, sv.streaming_music,
    sv.unlimited_data, sv.paperless_billing, sv.payment_method, sv.monthly_charge,
    st.churn_label, st.churn_value, st.churn_score, st.churn_category, 
    st.churn_reason, st.cltv, st.satisfaction_score, st.customer_status, st.quarter,

    -- ── Phân đoạn thời gian ──────────────────────────────────────────
    CASE
        WHEN sv.tenure_in_months BETWEEN 0 AND 6 THEN '0-6 months'
        WHEN sv.tenure_in_months BETWEEN 7 AND 12 THEN '7-12 months'
        WHEN sv.tenure_in_months BETWEEN 13 AND 18 THEN '13-18 months'
        WHEN sv.tenure_in_months BETWEEN 19 AND 24 THEN '19-24 months'
        WHEN sv.tenure_in_months BETWEEN 25 AND 30 THEN '25-30 months'
        WHEN sv.tenure_in_months BETWEEN 31 AND 36 THEN '31-36 months'
        ELSE '36+ months' 
    END AS segment_tenure,

    -- ── Đếm dịch vụ ────────────────────────────────────────────────
    (CASE WHEN sv.online_security = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.online_backup = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.device_protection_plan = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.premium_tech_support = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.streaming_tv = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.streaming_movies = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN sv.streaming_music = 'Yes' THEN 1 ELSE 0 END) AS addon_count,

    -- ── Phân loại rủi ro (Retention Priority) ─────────────────────
    CASE
        WHEN st.churn_score >= 70 AND st.cltv >= t.p75 THEN 'Critical'
        WHEN st.churn_score >= 70 AND st.cltv <  t.p75 THEN 'High Risk'
        WHEN st.churn_score < 70  AND st.cltv >= t.p75 THEN 'Hidden Risk'
        ELSE 'Stable'
    END AS retention_priority								  

FROM telco_customer_churn c
CROSS JOIN cltv_threshold t -- Kết hợp ngưỡng đã tính vào View
LEFT JOIN demographics d ON TRIM(c.customer_id) = TRIM(d.customer_id)
LEFT JOIN location     l ON TRIM(c.customer_id) = TRIM(l.customer_id)
LEFT JOIN status       st ON TRIM(c.customer_id) = TRIM(st.customer_id)
LEFT JOIN services     sv ON TRIM(c.customer_id) = TRIM(sv.customer_id)
LEFT JOIN population   p ON TRIM(l.zip_code)    = TRIM(p.zip_code);

SELECT * FROM vw_churn_master
