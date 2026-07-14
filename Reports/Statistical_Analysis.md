# Statistical Analysis

The statistical methods used in this project, what they showed, and why each one was the right tool
for the question being asked.

## Descriptive statistics

Used throughout `r/03_eda.R` (revenue, profit, margin by category/region) as the baseline every other
method is compared against. Simple, but essential — several of the headline insights (e.g. Electronics'
negative margin) are visible directly in a grouped mean/sum before any modeling is applied.

## Correlation analysis & hypothesis testing

**Question:** Does supplier on-time delivery rate actually move customer satisfaction, or is that
assumed? *(`r/06_supplier_analysis.R` Analysis 11)*

**Method:** Pearson correlation between each supplier's on-time rate and average customer
satisfaction across 40 suppliers, plus a `cor.test()` for statistical significance.

**Result:** r = 0.82, p = 4.56e-10 — a strong, highly significant positive correlation. The null
hypothesis (no relationship) is rejected with very high confidence.

**Business value:** converts an assumed relationship into a defensible, quantified one. This is the
evidence base for treating supplier scorecards as a customer-experience lever, not just an operations
metric.

A second correlation (on-time rate vs. return rate, r = -0.22) was also tested and found weak —
reported honestly as a secondary, less conclusive finding rather than overstated.

## Distribution analysis

**Question:** What does the profit distribution actually look like — is "31% of orders unprofitable"
a heavy, structural problem or a scattering of small outliers? *(`r/09_visualizations.R` chart 05,
`r/08_cost_optimization.R` Analysis 16)*

**Method:** A histogram of order-level profit with a breakeven reference line, cross-tabulated against
category and freight mode.

**Result:** The unprofitable tail is not scattered noise — it's concentrated (58.5% Electronics, 39.1%
premium freight), which is what makes it fixable with a targeted rule rather than a blanket
price change.

## Seasonal decomposition & simple seasonal indexing

**Question:** Is monthly demand variation a real, repeatable pattern or just noise?
*(`r/05_demand_forecasting.R` Analysis 7)*

**Method:** Classical multiplicative `decompose()` for a trend/seasonal/remainder visual, plus a
simpler, more transparent seasonal index (each month's average / the overall average) for the headline
number — used deliberately *instead of* `decompose()`'s own seasonal figure, because classical
decomposition needs several full cycles to estimate the seasonal component reliably, and this dataset
only has two (a real methodological limitation worth calling out rather than hiding).

**Result:** December +33.5% above baseline, February -40.7% below it, with December/November/August
consistently the three strongest months in *both* years — a repeatable pattern, not one-off noise.

## Forecast accuracy evaluation (MAE / RMSE / MAPE)

**Question:** Which forecasting method should actually be used in production?
*(`r/05_demand_forecasting.R` Analysis 8)*

**Method:** Naive, 3-month Moving Average, ETS, and ARIMA models trained on 21 months of data,
evaluated against a held-out Oct-Dec 2025 window using MAE, RMSE, and MAPE.

**Result:** Moving Average wins (15.2% MAPE) over Naive (16.5%), ETS (25.8%), and ARIMA (26.1%) — and
the diagnostic (`ets_fit$method` = `ETS(M,N,N)`, a non-seasonal fit) explains *why*: with under two
full seasonal cycles of history, automatic model selection couldn't reliably lock onto the seasonal
component, so the "smarter" models actually did worse. This is reported as a genuine, data-driven
finding rather than forcing a "sophisticated model wins" narrative that the evidence doesn't support.

## Confidence in results

Every number in `reports/Business_Insights.md` is reproducible by re-running the corresponding R
script against `dataset/Supply_Chain_Data_Clean.csv` — none are manually typed or estimated. Sample
sizes are noted where they matter (e.g. the supplier on-time ranking filters to suppliers with ≥30
orders specifically to avoid small-sample noise driving the ranking).
