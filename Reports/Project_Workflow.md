# Project Workflow

How this project was actually built, end to end.

## 1. Dataset generation

A ~12,000-row order dataset was generated with realistic structure baked in (seasonality, Pareto
customer/product concentration, category margin bands, supplier reliability profiles, mode-dependent
freight economics) rather than random noise — see `reports/Data_Dictionary.md` for the full
methodology. Realistic data-quality issues (duplicates, missing values, inconsistent text casing, a
few keying errors, mixed date formats) were then injected on top, so the cleaning step in `r/` has
genuine work to do rather than being a no-op demonstration.

## 2. Data loading & profiling — `r/01_data_loading.R`

Loads the raw export and profiles it: row/column counts, structure, a missing-value report, duplicate
count, and explicit data-quality flags (negative quantities, zero prices, inconsistent categorical
text, mixed date formats). This is the "what am I actually working with" step, run before any cleaning
decision is made.

## 3. Data cleaning — `r/02_data_cleaning.R`

Seven documented steps, each with a stated reason:

1. **Duplicate removal** — first an exact full-row `distinct()`, then a second pass deduping on the
   `Order_ID` business key (a naive full-row check missed a handful of duplicate pairs where only one
   copy had picked up a missing-value flag — a real lesson about why business-key dedup matters more
   than full-row equality).
2. **Text standardization** — `Category`, `Transportation_Mode`, and `Warehouse_Region` are
   trimmed and title-cased (raw values included `"  electronics "`, `"ELECTRONICS"`, `"Electronics"` as
   three distinct strings for the same category).
3. **Date parsing** — a subset of `Order_Date` values were exported as `MM/DD/YYYY` instead of ISO
   format; both are parsed and coalesced.
4. **Invalid numeric correction** — a small number of `Quantity_Ordered` values were negative (a
   keying sign error, corrected with `abs()` rather than dropped) and a small number of
   `Selling_Price` values were exactly zero (imputed from that product's median price elsewhere in the
   data, with `Revenue`/`Profit` recomputed for those rows).
5. **Missing-value handling** — `Ship_Date`/`Delivery_Date` are genuinely `NA` for Cancelled orders
   (a correct business state, not missing data, so left as-is); `Customer_Satisfaction` gaps are
   flagged (`Satisfaction_Missing`) rather than imputed, since fabricating a sentiment score would bias
   downstream analysis; `Lead_Time_Days` gaps are imputed from that supplier's median lead time, since
   lead time is a supplier-level characteristic rather than random noise.
6. **Feature engineering** — `Delivery_Delay_Days`, `Fulfillment_Rate`, `Profit_Margin`,
   `Is_Peak_Season`.
7. **Validation rules** — five automated checks (shipped ≤ ordered, non-negative revenue, no duplicate
   order IDs, ship date ≥ order date, positive selling price) must all pass before the script writes
   its output; the script halts (`stopifnot`) if any rule fails.

Output: `dataset/Supply_Chain_Data_Clean.csv`, plus a real SQLite database (`dataset/supply_chain.db`)
built with `RSQLite`, indexed on product/supplier/warehouse/date, and query-tested live in the same
script (row-count check + a live `GROUP BY` query) before the script reports success.

## 4. Analysis — `r/03_eda.R` through `r/08_cost_optimization.R`

18 analyses across six themed scripts (EDA, inventory, demand forecasting, supplier performance,
transportation, cost optimization). Every analysis follows the same structure: business question → R
code → printed output → interpretation → a stated business insight with the actual number attached.
See `reports/Business_Questions.md` for the full question-to-script index.

## 5. Visualization — `r/09_visualizations.R`

6 additional ggplot2 charts (category revenue/profit, monthly trend, warehouse utilization heatmap,
stock-status mix, profit distribution, supplier reliability vs. satisfaction), plus 4 charts generated
inline by the forecasting and transportation scripts — 10 PNGs total in `images/charts/`.

## 6. Insight synthesis — `r/10_business_insights.R`

Loads the saved results object from every upstream script and prints one consolidated, numbered
insight list — the source of truth that `reports/Business_Insights.md` is written from.

## 7. Excel deliverables — `excel/`

Four workbooks built with `openpyxl`, every KPI and cross-tab a live formula (not a hardcoded value)
against a `Data` sheet containing the full cleaned dataset. Every workbook was recalculated with
LibreOffice and checked for zero formula errors before being considered done (`#REF!`, `#DIV/0!`,
`#VALUE!`, `#N/A`, `#NAME?`) — see `requirements.md`.

## 8. Documentation

Everything in `reports/` — this file plus the executive summary, business questions/insights, KPI
report, data dictionary, statistical and forecast write-ups, and interview prep guide.

## Reproducing this project end to end

```bash
cd r
for f in 0*.R; do Rscript "$f"; done
```

Then re-run the Excel build (see `excel/Power_Query_Steps.md` for the manual-Excel equivalent
workflow) against the refreshed `dataset/Supply_Chain_Data_Clean.csv`.
