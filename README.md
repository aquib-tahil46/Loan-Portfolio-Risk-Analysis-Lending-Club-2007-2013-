# 🏦 Loan Portfolio Risk Analysis — Lending Club (2007–2013)

![Tableau](https://img.shields.io/badge/Tableau-Public-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Status](https://img.shields.io/badge/Status-Completed-green)

## 📌 Project Overview
An end-to-end loan portfolio risk analysis built on 100,000 Lending Club 
loans (2007–2013), combining advanced SQL analytics with interactive 
Tableau dashboards to surface credit risk, recovery trends, and 
borrower segmentation insights.
---

## 🎯 Business Questions Answered
- Which loan grades carry the highest NPA risk?
- How has portfolio growth trended across risk bands?
- What is the recovery rate for defaulted loans by grade?
- How do borrower income bands correlate with loan size and grade?
- Which grade-purpose combinations drive maximum disbursement?
---

## 🗄️ Database Schema (Star Schema — MySQL)
loan_clean (staging)
│
├── loan_sample (fact — 100K rows)
├── dim_borrower (borrower profile)
└── dim_product  (loan product info)
### Table Details
| Table | Rows | Key Columns |
|---|---|---|
| loan_sample | 100,000 | loan_id, loan_amnt, loan_status, issue_date, recoveries |
| dim_borrower | 100,000 | borrower_id, annual_inc, dti, home_ownership, addr_state |
| dim_product | 100,000 | product_id, grade, sub_grade, int_rate, purpose, term |

---

## 🔍 SQL Techniques Used

| Query | Technique |
|---|---|
| Loan summary by grade & purpose | 3-table JOIN |
| NPA rate by grade | CTE |
| Running disbursement by month | SUM() OVER — Window Function |
| Rank borrowers by income | RANK() PARTITION BY |
| Month-over-Month NPA change | LAG() — Window Function |
| High value bad loans vs avg | Correlated Subquery |
| Risk category summary | CTE + CASE WHEN |
| Recovery rate by grade | JOIN + Aggregation |

---

## 📊 Tableau Dashboards

### Dashboard 1 — Portfolio Risk Overview
- Horizontal bar: Loan disbursed by grade (color = NPA Risk Band)
- Pie chart: Loan status distribution
- Treemap: Exposure by risk category
- Dual axis: NPA Rate (FIXED LOD) vs Recovery Rate by grade

### Dashboard 2 — Trend & Borrower Analysis  
- Stacked area: Cumulative disbursement by risk band (Running Total)
- Scatter plot: Loan amount vs interest rate (EXCLUDE LOD reference line)
- Heatmap: Avg loan by income band × grade (INCLUDE LOD)
- Multi-line: Cumulative disbursement by grade over time


---

## 💡 Tableau Concepts Demonstrated

| Concept | Where Used |
|---|---|
| FIXED LOD | NPA Rate benchmark per grade — immune to view filters |
| INCLUDE LOD | Avg loan per income band × grade — granular heatmap |
| EXCLUDE LOD | Global avg interest rate reference line on scatter plot |
| Running Total | Cumulative disbursement area chart |
| Percent Difference | Month-over-month trend on dual axis |
| Dual Axis | NPA Rate bars + Recovery Rate circles |
| Filter Action | Grade selection filters all Dashboard 1 charts |
| Highlight Action | Grade highlight across Dashboard 2 |
| Reference Lines | Portfolio avg on bar chart, quadrant lines on scatter |
| Story Points | 3-point stakeholder narrative |
---

## 🔑 Key Findings
1. **Grade B dominates** — $378M disbursed but carries 12.3% NPA risk
2. **Grade G is unviable** — 30.4% NPA with only 2.4% recovery rate
3. **84.6% loans fully paid** — portfolio health is fundamentally sound
4. **Post-2011 acceleration** — portfolio grew 5x in 2 years, led by B and C
5. **Mid Income × Grade B** — highest avg loan segment at $188K total volume
6. **Recommendation** — Cap Grade F/G exposure, prioritise Grade A-C growth
---

## 🛠️ Tech Stack
- **Database:** MySQL 8.0
- **Visualization:** Tableau Public
- **Data Source:** Lending Club Loan Data (Kaggle)
- **Schema:** Star schema — 3 tables, 100K rows
---

## 📁 Repository Structure
loan-portfolio-risk-tableau/
│
├── sql/
│   └── loan_portfolio_analysis.sql    # All 8 analytical queries
│
├── data/
│   └── data_source.md                 # Dataset info and download link
│
├── screenshots/
│   ├── <img width="1880" height="800" alt="Screenshot 2026-04-30 011659" src="https://github.com/user-attachments/assets/52b82ea6-9c36-49cd-a367-aa18dd4a073e" />


│   ├── <img width="1884" height="797" alt="Screenshot 2026-04-30 011731" src="https://github.com/user-attachments/assets/d562a867-7d69-4777-9b97-031c87b3d317" />


│   └── <img width="1920" height="1080" alt="Screenshot 2026-04-29 122034" src="https://github.com/user-attachments/assets/6908cf82-cb7c-43e1-b886-488615b44352" />

│
└── README.md
---
## Dataset
[Lending Club Loan Data — Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club)

## Project Structure
loan-portfolio-risk-tableau/
├── sql/
│   └── loan_portfolio_analysis.sql
└── README.md
---
## 🔗 Links
- 📊 **Live Dashboard:** [Tableau Public][(https://public.tableau.com/app/profile/aquib.tahil8642/viz/Lending_club_17775741205830/Dashboard1?publish=yes)]
- 💼 **LinkedIn:** [Aquib Tahil](https://linkedin.com/in/aquib-tahil/)
- 🐙 **GitHub:** [github.com/aquib-tahil46](https://github.com/aquib-tahil46)
---

## 👤 Author
**Aquib Tahil**  
BI Analyst & Tableau Developer | BFSI Domain | 9+ Years Experience  
Salesforce Certified: Tableau Desktop Foundations (April 2026)

