# Executive Summary

**Supply Chain Optimization Analysis | Jan 2024 - Dec 2025 | 12,000 orders, $9.95M revenue**

## The bottom line

The business is profitable at a 16.7% blended margin, but roughly **$4.2M in value is either lost or
sitting idle** across three concrete, fixable problems: unprofitable order-level economics ($148K in
direct losses), excess working capital tied up in overstocked inventory (~$4.1M), and avoidable
logistics risk concentrated in a handful of supplier and mode combinations.

## Three things to fix first

**1. Electronics is losing money, and it's a freight problem as much as a pricing problem.**
Electronics is the only category with a negative overall margin (-21.0%), and unprofitable orders
company-wide are disproportionately Electronics (58.5% of them) shipped via premium freight. Capping
Air/Parcel eligibility on low-margin SKUs below a minimum order value would address this without
touching pricing.

**2. $4.1M is tied up in overstocked inventory — more than double what's lost to stock-outs.**
16% of product-warehouse positions are overstocked. Right-sizing them would free enough capital to
self-fund the wider Q4 safety-stock buffer recommended below, at effectively no net working-capital
cost.

**3. Peak season needs a wider forecasting and safety-stock buffer, not a flat one.**
Demand forecast error nearly doubles in Nov/Dec (17.5% MAPE vs. 9.1% the rest of the year), and
Singapore's warehouse already peaks at 135% of capacity during that window. Widening safety stock and
pre-booking overflow capacity specifically ahead of Q4 — rather than year-round — targets the actual
risk window.

## Supporting evidence

- Supplier on-time rate correlates with customer satisfaction at r = 0.82 (p < 0.001) — supplier
  scorecards are a legitimate lever for the customer experience number, not just an ops metric.
- Road freight is both the cheapest mode (5.4% of revenue) and among the most reliable (83.1% on-time)
  — it's the benchmark every other mode should be measured against.
- Parcel/International shipments run late 92.2% of the time — the single highest-risk lane
  combination in the network.
- A simple 3-month moving average currently outperforms ETS/ARIMA on this data (15.2% MAPE vs.
  25.8%/26.1%) because 21 months of history isn't enough for automatic seasonal model fitting —
  a reminder that "more sophisticated" isn't automatically "more accurate" without enough history to
  support it.

## Where to go deeper

- Full findings: `reports/Business_Insights.md` (20 insights, all grounded in the analysis in `r/`)
- Live, interactive numbers: `excel/Supply_Chain_Dashboard.xlsx` and `excel/KPIs.xlsx`
- Methodology: `reports/Project_Workflow.md`, `reports/Statistical_Analysis.md`, `reports/Forecast_Report.md`
- Recommendations in detail: `reports/Optimization_Strategy.md`
