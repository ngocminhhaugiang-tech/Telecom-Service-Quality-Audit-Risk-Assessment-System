# 📊 Telecom Customer Churn Analysis & Risk Mitigation Pipeline

## 📋 Project Overview
This project delivers an end-to-end Data Analytics pipeline designed to analyze customer quality failure (churn) for a major Telecom enterprise. Moving beyond basic descriptive reporting, the project implements a full analytical lifecycle: **Descriptive $\rightarrow$ Diagnostic $\rightarrow$ Predictive $\rightarrow$ Prescriptive Framework** using **PostgreSQL** for data engineering/advanced querying and **Power BI** for executive dashboarding.

The dataset comprises **7,043 customer records** integrated from 6 distinct operational data sources.

---

## 🚀 Key Business Metrics (KPIs)
* **Total Customer Base:** 7,043 active and historical records
* **Customer Failure Rate (Churn Rate):** 26.54%.
* **Monthly Financial Loss:** \$139,131 per month in lost recurring revenue.
* **Revenue Impact Rate:** 30.50%. 
  *> **Critical Insight:** The Revenue Impact Rate exceeds the Customer Churn Rate by 3.96 percentage points, indicating that high-value premium accounts are disproportionately leaving the ecosystem.*

---

## 🛠️ Tech Stack & Architecture
* **Data Integration & Pipeline:** PostgreSQL (Views, CTEs, Window Functions, Custom Risk Scoring Heuristics).
* **Data Visualization & Analytics:** Power BI Desktop (Interactive Multi-page Executive Dashboards)
* **Framework:** Data Quality Auditing & Operational Priority List (OPL) Execution


---

## 📂 Database Pipeline & Query Architecture (PostgreSQL)

The SQL scripts are structured into **5 distinct chapters**, reflecting the analytical depth of the project:

### 🔹 Chapter 1: Executive Overview
* Consolidates high-level corporate KPIs: Total Customers, Customer Churn Rate, Monthly Revenue Loss, and Revenue Failure Ratio.
* Quantifies revenue leakage across macro Churn Categories (Competitor, Attitude, Dissatisfaction, Price, Other).
* Segments historical data into CLTV quartiles using `NTILE(4)` to map customer value distribution.

### 🔹 Chapter 2: Demographic Risk Segmentation ("Who is leaving?")
* Analyzes churn risk variance across demographic cohorts (Gender, Age Groups, Family Structures).
* **Key Discovery:** Senior (65+) customers exhibit a massive 42.25% (Female) and 41.11% (Male) churn rate despite paying premium rates of \$80+/month.
* Evaluates geographic density (`population_size`) to differentiate Urban vs. Rural retention dynamics.

### 🔹 Chapter 3: Root Cause Diagnostics & Driver Analysis
* Isolates product and contract anomalies driving customer defection.
* **Key Discovery:** Fiber Optic customers without protective security add-ons represent the single highest-risk zone, suffering a **58.33% churn rate** (nearly 2x the baseline).
* Maps out the Pareto distribution of the Top 15 churn reasons, identifying competitor device and price offers as primary drivers.

### 🔹 Chapter 4: Predictive Risk Alerts
* Focuses strictly on active, retained customers (`churn_value = 0`) to predict future churn vectors.
* Implements rule-based risk scoring to classify active customers into four tiers: *Critical, High Risk, Hidden Risk, Stable*.
* Quantifies **\$57,567.6/month** in active revenue currently exposed to immediate risk.

### 🔹 Chapter 5: Corrective Action Priority & Operational Playbook (OPL)
* Monetizes historical and active data by translating metrics into an **Annualized Revenue at Risk** format.
* Dynamically generates an **Operational Priority List (OPL)** tracking active critical-risk customers ranked by Churn Score and CLTV for the proactive retention team.
---

telco-customer-churn-pipeline/
├── data/                             # Thư mục chứa toàn bộ dữ liệu dự án
│   └── raw/                          # Nơi lưu 6-7 file CSV gốc ban đầu
│       ├── Telco_customer_churn_demographics.csv
│       ├── Telco_customer_churn_services.csv
│       ├── Telco_customer_churn_status.csv
│       └── ...
├── sql/                              # Thư mục chứa toàn bộ mã nguồn PostgreSQL
│   ├── 01_data_integration.sql       # Script tạo bảng (DDL) và import dữ liệu ban đầu
│   ├── 02_data_cleaning.sql          # Script dọn dẹp, chuẩn hóa dữ liệu thành bảng cleaned
│   ├── 03_executive_overview.sql     # Script phân tích cho Chương 1
│   ├── 04_demographic_analysis.sql   # Script phân tích cho Chương 2
│   ├── 05_root_cause_diagnostics.sql # Script phân tích cho Chương 3
│   ├── 06_predictive_risk_alerts.sql # Script phân tích cho Chương 4
│   └── 07_corrective_actions.sql     # Script phân tích cho Chương 5
├── Dashboard_report.pdf              # Dashboard phân tích 5 chương
├── Telecom_analysis_report.pdf       # File báo cáo quá trình phân tích
└── README.md                         # File giới thiệu tổng quan dự án

---

## 📊 Dashboard Insights (Power BI)

The interactive dashboard consists of 5 dedicated analytics pages aligned with the SQL architecture:

1. **Executive Overview:** Provides immediate visibility into corporate revenue leakage. Highlights that competitor pressure accounts for **46.38% (\$64,529)** of total monthly loss.
2. **Customer Demographics & Cohort Segmentation:** Visualizes family structures as a natural retention lock-in (customers with dependents display a mere 3-5% churn rate).
3. **Root Cause Diagnostics & Driver Analysis:** Proves that contract type, not tenure length, is the decisive retention factor. Month-to-Month contracts suffer a 57.06% dropout cliff in the first 6 months.
4. **Predictive Risk Alerts:** Features the *Customer Survival Curve* proving that 2-Year contracts maintain near-100% retention in early stages.
5. **Corrective Action Priority & OPL:** Displays a financial risk optimization playbook simulating savings from structural bundling changes.

---

## 🎯 Prescriptive Strategy & OPL Playbook

Based on the data pipelines, three immediate data-driven actions were prescribed:

* **REC 1 (Critical Priority):** Automatically bundle *Online Security + Tech Support* into all Fiber Optic packages. This is projected to drop the 58.33% failure rate down to 32.38%.
* **REC 2 (High Priority):** Launch automated contract upgrade campaigns triggered precisely at **Month 2** of tenure for Month-to-Month subscribers to bypass the 6-month dropout cliff.
* **REC 3 (Medium Priority):** Replace the net-negative **Offer E** framework (52.92% churn within 3.7 months) with the high-retention **Offer A** framework (6.73% churn, 70 months average tenure).

---

## 🛠️ How to Setup and Run
1. **Database Initialization:** Run the DDL scripts in `/sql/data_integration.sql` to create tables and set up Primary/Foreign Key constraints.
2. **Data Ingestion:** Import the raw CSV files into PostgreSQL using pgAdmin Import/Export tool or the provided `COPY` script.
3. **Run Analytics:** Execute `/sql/chapter_1_to_5_queries.sql` to generate analytical views and populate data structures.
4. **Dashboard View:** Open `/bi/Telecom_Churn_Analytics.pbix` in Power BI Desktop and update the PostgreSQL data source credentials to refresh the visualizations.
