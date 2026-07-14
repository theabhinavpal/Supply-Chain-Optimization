# Business Questions

24 business questions this project answers, grouped by theme. Each links to the script/analysis
that computed the answer — every number is traceable back to real, runnable code.

## Revenue & Profitability
1. Which product categories generate the most revenue, and which are the most/least profitable? — `r/03_eda.R`, Analysis 2
2. What's the company's overall profit margin, and how much of it is at risk from unprofitable orders? — `r/03_eda.R` Analysis 1, `r/08_cost_optimization.R` Analysis 16
3. Which categories carry the thinnest — or negative — margins, and why? — `r/03_eda.R` Analysis 2
4. Does peak-season promotional discounting actually hurt profitability? — `r/08_cost_optimization.R` Analysis 17
5. Which regions carry the highest logistics cost burden relative to their revenue? — `r/03_eda.R` Analysis 3

## Inventory & Warehousing
6. What share of the business is in a stock-out or low-stock position at any given time? — `r/04_inventory_analysis.R` Analysis 4
7. What products are overstocked, and how much working capital does that tie up? — `r/08_cost_optimization.R` Analysis 18
8. Which categories turn over inventory fastest vs. slowest? — `r/04_inventory_analysis.R` Analysis 5
9. Which warehouses are operating closest to (or beyond) rated capacity? — `r/04_inventory_analysis.R` Analysis 6
10. Does warehouse capacity strain follow the same seasonal pattern as demand? — `r/04_inventory_analysis.R` Analysis 6, `r/09_visualizations.R` chart 03
11. What products should be reordered, and what's a defensible reorder point / safety stock level? — `r/02_data_cleaning.R` feature engineering, `excel/Reports.xlsx` (StockOut_Report)

## Demand Forecasting
12. Is there a real, repeatable seasonal demand pattern, or is month-to-month variation just noise? — `r/05_demand_forecasting.R` Analysis 7
13. Which forecasting method — Naive, Moving Average, ETS, or ARIMA — performs best on this data, and why? — `r/05_demand_forecasting.R` Analysis 8
14. How much does forecast accuracy degrade during peak season, and what does that mean for safety stock policy? — `r/05_demand_forecasting.R` Analysis 9

## Supplier Performance
15. Which suppliers have the best and worst on-time delivery records? — `r/06_supplier_analysis.R` Analysis 10
16. Does supplier reliability actually move customer satisfaction, or is that just assumed? — `r/06_supplier_analysis.R` Analysis 11
17. Is the cheapest supplier by unit cost also the most profitable to work with? — `r/06_supplier_analysis.R` Analysis 12
18. Which suppliers should be flagged for a scorecard review or replacement? — `excel/Reports.xlsx` (Supplier_Scorecard)

## Transportation & Logistics
19. Which transportation mode is most cost-effective, and does that hold across all route types? — `r/07_transportation_analysis.R` Analysis 13
20. Which mode/route combinations run late most often, and where's the highest operational risk? — `r/07_transportation_analysis.R` Analysis 14
21. How does shipping cost actually scale with distance for each mode — and where do fixed fees dominate over distance? — `r/07_transportation_analysis.R` Analysis 15

## Cost Optimization
22. What's actually driving the ~31% of orders that lose money — is it freight, discounting, or product mix? — `r/08_cost_optimization.R` Analysis 16
23. Where's the highest-leverage, lowest-effort fix to improve portfolio profitability? — `r/08_cost_optimization.R` Analyses 16-18
24. Could freeing up capital from overstocked positions self-fund the safety-stock increase peak season needs? — `r/08_cost_optimization.R` Analysis 18

---

*Scope note: this list is a curated, portfolio-focused set of the highest-value questions the dataset
can answer — chosen for depth over volume. Each one is backed by a full analysis (business question →
code → output → interpretation → business insight) in the corresponding R script, not just a one-line
answer.*
