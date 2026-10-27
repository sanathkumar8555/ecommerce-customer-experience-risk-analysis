# E-Commerce Customer Experience & Risk Analysis

### SQL | Python | Tableau | Data Analytics

## Project Overview

This project analyzes the Brazilian Olist e-commerce dataset to explore customer satisfaction, delivery performance, and seller risk indicators.

The analysis uses SQL for order and delivery analysis, Python for exploratory data analysis and statistical exploration, and Tableau for interactive visualizations.

## Business Objectives

- Understand customer review patterns and satisfaction levels.
- Analyze delivery delays and their relationship with customer ratings.
- Identify sellers with higher negative review percentages.
- Explore how product prices and freight charges relate to customer satisfaction.
- Present insights through an interactive dashboard.

## Tools & Technologies

- **SQL (MySQL):** Data quality checks, JOINs, CTEs, aggregations, and window functions.
- **Python:** Pandas, NumPy, Matplotlib, Seaborn, and statistical analysis.
- **Tableau Public:** Interactive dashboard, KPIs, charts, and filters.
- **Excel:** Data exploration and validation.

## Key Findings

- The SQL analysis found an average delivery time of approximately 12.50 days for delivered orders.
- Late deliveries were associated with substantially lower customer ratings than early deliveries.
- The Tableau dashboard reports 97,709 unique reviews, an average customer rating of 4.106, and a negative rating percentage of 14.15% for its prepared review dataset.
- Seller-level analysis highlighted differences in negative review percentages across sellers.
- Customer ratings and negative review rates varied across product price categories.

*Note: SQL and Tableau analyses use different prepared data subsets and aggregation levels, so their metrics should not be assumed to be directly comparable.*

## Interactive Tableau Dashboard

[View Live E-Commerce Customer Experience & Seller Risk Dashboard](https://public.tableau.com/app/profile/sanath.kumar5850/viz/E-CommerceCustomerExperienceSellerRiskAnalysis/E-CommerceCustomerExperienceSellerRiskDashboard_)

## Project Structure

```text
ecommerce-customer-experience-risk-analysis/
├── SQL/
│   └── Ecommerce_Customer_Experience_Risk_Analysis.sql
├── Python/
│   └── E-Commerce Customer Experience & Risk Analysis.ipynb
├── Tableau/
│   └── dashboard_link.md
└── README.md
```

## Business Recommendations

1. Monitor sellers with consistently high negative review percentages and sufficient review volume.
2. Investigate delivery delays associated with lower customer satisfaction.
3. Analyze recurring customer complaints to identify product and service quality issues.
4. Track customer experience metrics regularly to identify emerging operational risks.

## Conclusion

This project demonstrates an end-to-end analytics workflow using SQL, Python, and Tableau to investigate customer experience and seller risk indicators, translate data into business insights, and communicate findings through an interactive dashboard.

## Dataset

Brazilian E-Commerce Public Dataset by Olist, available on Kaggle.