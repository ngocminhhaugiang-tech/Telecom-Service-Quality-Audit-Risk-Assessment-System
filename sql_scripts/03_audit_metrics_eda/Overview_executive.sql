--------------------------------------------------------------------------------
-- CHƯƠNG 1: EXECUTIVE OVERVIEW (TỔNG QUAN ĐIỀU HÀNH)
--------------------------------------------------------------------------------

-- 1. KPI Tổng quan: Tỷ lệ Churn vs Tỷ lệ Thất thoát Doanh thu
SELECT 
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN churn_value = 1 THEN 1 END) AS total_customer_churn,
    ROUND(COUNT(CASE WHEN churn_value = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    
    -- Thất thoát doanh thu định kỳ hàng tháng (MRR Lost)
    ROUND(SUM(CASE WHEN churn_value = 1 THEN monthly_charge ELSE 0 END), 2) AS monthly_revenue_loss,
    -- % Doanh thu bị mất do khách hàng rời bỏ
    ROUND(
        SUM(CASE WHEN churn_value = 1 THEN monthly_charge ELSE 0 END) * 100.0 / NULLIF(SUM(monthly_charge), 0), 2
    ) AS revenue_loss_ratio_pct
FROM telco_customer_cleaned;


-- 2. Phân tích tổn thất theo nhóm nguyên nhân (Churn Category)
SELECT 
    churn_category,
    COUNT(*) AS total_customers_lost,
    -- Tính tổng số tiền bốc hơi hàng tháng của từng nhóm lý do
    ROUND(SUM(monthly_charge), 2) AS lost_monthly_revenue,
    -- Tính tỷ trọng thiệt hại của lý do đó trên tổng số tiền mất do Churn
    ROUND(
        (SUM(monthly_charge) / SUM(SUM(monthly_charge)) OVER()) * 100, 2
    ) AS revenue_loss_contribution_pct
FROM telco_customer_cleaned
WHERE churn_value = 1 -- Chỉ lọc ra những người đã thực sự rời đi
GROUP BY churn_category
ORDER BY lost_monthly_revenue DESC;


-- 3. Phân khúc khách hàng: So sánh nhóm Rời bỏ (Churned) vs Ở lại (Retained)
SELECT
    CASE WHEN churn_value = 1 THEN 'Churned' ELSE 'Retained' END AS customer_group,
    COUNT(*) AS total_customers,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    ROUND(AVG(monthly_charge), 2) AS avg_monthly_charges,
    ROUND(MIN(cltv), 0) AS min_cltv,
    ROUND(MAX(cltv), 0) AS max_cltv,
    SUM(cltv) AS total_cltv,
    -- % tỷ trọng giá trị vòng đời khách hàng đóng góp cho hệ thống
    ROUND(SUM(cltv) * 100.0 / SUM(SUM(cltv)) OVER(), 2) AS cltv_share_pct
FROM telco_customer_cleaned
GROUP BY churn_value
ORDER BY churn_value DESC;


-- 4. Tỷ lệ Churn theo 4 phân khúc giá trị khách hàng (CLTV Segments)
WITH cltv_rank AS (
    SELECT *,
           NTILE(4) OVER(ORDER BY cltv) AS grp
    FROM telco_customer_cleaned
)
SELECT
    grp AS segment_id,
    CASE
        WHEN grp = 1 THEN 'LOW CLTV'
        WHEN grp = 2 THEN 'MEDIUM CLTV'
        WHEN grp = 3 THEN 'HIGH CLTV'
        ELSE 'VIP (MAX CLTV)'
    END AS cltv_segment,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN churn_value = 1 THEN 1 END) AS churned_customers,
    -- Tỷ lệ rời bỏ của riêng từng nhóm
    ROUND(SUM(CASE WHEN churn_value = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM cltv_rank
GROUP BY grp
ORDER BY grp; -- Sắp xếp theo thứ tự phân khúc từ thấp đến cao để dễ theo dõi xu hướng
