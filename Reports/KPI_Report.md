# KPI Report

All 15 KPIs below are live formulas in `excel/KPIs.xlsx` (KPI Scorecard sheet) computed directly
against the `Data` sheet, and independently cross-checked against the R analysis in `r/03_eda.R`
through `r/08_cost_optimization.R`. Values as of the current dataset snapshot (Jan 2024 - Dec 2025).

## Financial

| KPI | Definition | Value |
|---|---|---|
| Total Revenue | `SUM(Revenue)` | **$9,951,737** |
| Total Profit | `SUM(Profit)` | **$1,657,436** |
| Blended Profit Margin | `Total Profit / Total Revenue` | **16.7%** |
| Average Order Value | `AVERAGE(Revenue)` | **$829.31** |
| Total Shipping Cost | `SUM(Shipping_Cost)` | **$750,000** |
| Shipping Cost % of Revenue | `Total Shipping Cost / Total Revenue` | **7.5%** |
| % of Orders Unprofitable | `COUNT(Profit<0) / COUNT(Orders)` | **30.9%** |

## Inventory

| KPI | Definition | Value |
|---|---|---|
| Stock-Out Rate | share of product-warehouse-months at zero inventory | **1.6%** |
| Low-Stock Rate | share at or below reorder point | **21.3%** |
| Overstocked Rate | share above 3x reorder point | **16.0%** |
| Avg Inventory Turnover | Annual COGS / Avg Inventory Value, order-weighted | **6.08x/yr** |
| Order Fulfillment Rate | `SUM(Quantity_Shipped) / SUM(Quantity_Ordered)` | **94.8%** |
| Avg Warehouse Utilization | mean of monthly Warehouse_Utilization across all 8 sites | **78.2%** |

> **Note on Inventory Turnover:** the KPI above is *order-weighted* (every order line counts once, so
> popular/fast-moving products contribute more), giving **6.08x/yr**. `r/04_inventory_analysis.R`
> reports a *product-weighted* version instead (every one of the 150 products counts equally
> regardless of order volume), which gives a lower **3.62x/yr** company-wide average and the
> 2.34x-5.30x per-category range used in `Business_Insights.md`. Both are legitimate; the
> product-weighted view is the right one for category-level comparisons (it isn't skewed by a handful
> of high-volume SKUs), while the order-weighted view better reflects what the average transaction
> actually experiences. Use whichever matches the decision you're making.

## Logistics & Supplier

| KPI | Definition | Value |
|---|---|---|
| Average Lead Time | `AVERAGE(Lead_Time_Days)` | **12.1 days** |
| On-Time Delivery Rate | `1 - COUNT(Late_Delivery=TRUE)/COUNT(Orders)` | **81.8%** |
| Late Delivery Rate | `COUNT(Late_Delivery=TRUE)/COUNT(Orders)` | **18.2%** |
| Order Cancellation Rate | `COUNT(Status="Cancelled")/COUNT(Orders)` | **2.4%** |

## Customer

| KPI | Definition | Value |
|---|---|---|
| Avg Customer Satisfaction | `AVERAGE(Customer_Satisfaction)`, 1-5 scale | **4.01 / 5** |
| Order Return Rate | `COUNT(Status="Returned")/COUNT(Orders)` | **8.0%** |
| Avg Product Return Rate | `AVERAGE(Product_Return_Rate)` | **8.0%** |
| Total Orders | `COUNT(Order_ID)` | **12,000** |

## Where to find each KPI live

- `excel/KPIs.xlsx` → **KPI Scorecard** sheet — every cell above is a formula, not a typed-in number
- `r/03_eda.R`, `r/04_inventory_analysis.R`, `r/06_supplier_analysis.R`, `r/07_transportation_analysis.R`,
  `r/08_cost_optimization.R` — the R-side computation and interpretation behind each KPI
