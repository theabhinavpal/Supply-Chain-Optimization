# Resume Bullets & Interview Prep

## Resume bullet points (ATS-friendly)

- Built an end-to-end supply chain analytics pipeline in R (data cleaning, EDA, inventory optimization,
  demand forecasting, supplier/transportation analysis) on a 12,000-row order dataset, identifying
  $148K in direct order-level losses and $4.1M in overstocked working capital
- Diagnosed a -21% margin category by cross-tabulating unprofitable orders against freight mode and
  product category, isolating a fixable freight-eligibility rule from a broader pricing problem
- Benchmarked Naive, Moving Average, ETS, and ARIMA demand forecasting models using MAE/RMSE/MAPE on a
  held-out test window, and diagnosed *why* the simpler model won (insufficient training history for
  automatic seasonal model selection) rather than reporting results without explanation
- Quantified the statistical relationship between supplier on-time delivery and customer satisfaction
  (Pearson r = 0.82, p < 0.001) across 40 suppliers, converting an assumed relationship into a
  defensible, data-backed procurement recommendation
- Built a formula-driven Excel reporting suite (executive dashboard, KPI scorecard, pivot-style
  cross-tabs, operational reports) with zero formula errors across 12,000+ live formulas, verified via
  automated recalculation testing rather than manual spot-checking

## Supply Chain Analytics — Interview Q&A

**Q: Walk me through how you'd diagnose why a product category is losing money.**
A: Start by separating "is it a pricing problem or a cost problem" — in this project, I cross-tabulated
unprofitable orders against category and freight mode rather than just looking at category margin in
isolation. That showed Electronics' losses were concentrated in orders shipped via Air/Parcel, which
pointed at a freight-eligibility fix (cap premium shipping on low-margin SKUs below a minimum order
value) instead of a blanket price increase that would've also hurt healthy-margin orders in the same
category.

**Q: How do you decide on a safety stock level?**
A: Safety stock should scale with demand *volatility*, not just average demand — I computed it per
Product x Warehouse as `z-score × demand std dev × sqrt(lead time)`, so a volatile, long-lead-time SKU
gets a much bigger buffer than a stable, short-lead-time one. I also found forecast error nearly
doubles during peak season in this data, which means a single flat safety-stock number is structurally
wrong — it should be seasonally adjusted.

**Q: What's the difference between reorder point and safety stock?**
A: Safety stock is the buffer against demand/lead-time uncertainty. Reorder point is the inventory
level that triggers a new order — it's safety stock *plus* expected demand during the lead time
(`avg daily demand × lead time + safety stock`). Below the reorder point but above zero is "low stock";
at or below zero is a stock-out.

**Q: How would you decide between shipping modes for a given lane?**
A: On cost and reliability together, not just cost. In this project, Road was both the cheapest mode
(5.4% of revenue) and one of the most reliable (83.1% on-time) for domestic lanes — a clear default.
But I also found Parcel's cost barely scales with distance (r=0.50) while Sea/Road/Rail scale almost
linearly (r>0.97), which flips the cost calculus for long international lanes even though Parcel had
the worst on-time rate (92.2% late for Parcel/International) — so mode choice has to weigh weight,
distance, and lane-specific reliability together, not a single rule of thumb.

**Q: How do you measure supplier performance beyond on-time delivery?**
A: I built a composite scorecard weighting on-time rate (50%), realized margin contribution (35%), and
inverse return rate (15%) — because I found the cheapest supplier by unit cost wasn't consistently the
most profitable one once return rate and category mix were factored in. Unit cost alone is an
incomplete picture.

**Q: What would you do differently with more time or better data?**
A: Extend the training history for forecasting — with only 21 months available, ETS/ARIMA couldn't
reliably fit a seasonal component and a simple moving average won by default. I'd also want
SKU-level cost-to-serve data rather than modeled freight costs, and real customer survey response
rates rather than a simulated satisfaction score, to validate the supplier-satisfaction correlation
against ground truth.

## Excel — Interview Q&A

**Q: Why did you use SUMIFS/COUNTIFS-based cross-tabs instead of native PivotTables?**
A: Native PivotTable XML embeds a data cache that `openpyxl` (the library I used to build these
programmatically) only has partial, version-sensitive support for — a common failure mode is a
PivotTable that opens fine in one Excel version and throws an error in another. Formula-driven
cross-tabs are more verbose to build but guaranteed to open and recalculate correctly everywhere,
which mattered more for a deliverable meant to be opened by someone else's Excel install. I documented
the native-PivotTable equivalent workflow in `excel/Power_Query_Steps.md` since that's the faster
day-to-day approach when you're not scripting the build.

**Q: How do you make sure a workbook has zero formula errors before sending it?**
A: I don't rely on manually scrolling through it — I recalculate the whole workbook programmatically
(via a LibreOffice headless recalculation pass) and scan every cell for `#REF!`, `#DIV/0!`, `#VALUE!`,
`#N/A`, and `#NAME?`. That's how I caught, for example, that `MAXIFS` needs an `_xlfn.` prefix when
written by certain libraries or it silently shows `#NAME?` in some Excel/LibreOffice versions — a bug
that's easy to miss with a visual spot-check but impossible to miss with an automated error scan.

**Q: What's the difference between COUNTIFS and SUMPRODUCT for conditional counting, and when would
you use each?**
A: `COUNTIFS`/`SUMIFS`/`AVERAGEIFS` are simpler and faster for straightforward AND-conditions across
columns. `SUMPRODUCT` is more flexible — it handles OR logic, array math, and conditions that aren't
expressible as simple equality/range checks — at the cost of being harder to read and slower on large
ranges. I used `COUNTIFS`/`SUMIFS` throughout this project since every condition was a straightforward
AND match.

**Q: How would you build a KPI that updates automatically when new data comes in?**
A: Point every formula at a full-column or table reference (`Data!$A:$A` or a structured Table
reference) rather than a hardcoded range like `A2:A500`, so new rows are picked up automatically. In
this project I used Excel Tables (`ws.add_table`) specifically so the `Data` sheet expands cleanly.

## R — Interview Q&A

**Q: Why did Moving Average outperform ETS and ARIMA in your forecast comparison?**
A: With only 21 months of training history — under two full seasonal cycles — `ets()`'s automatic
model selection couldn't reliably fit a seasonal component and fell back to `ETS(M,N,N)`, a
non-seasonal fit that badly underestimates the holiday surge. Moving Average and Naive both implicitly
capture *some* of the recent trend just by using recent actuals, so they won on this particular
holdout window by default, not because they're better models in general. I'd expect ETS/ARIMA to
overtake them with 3+ years of history.

**Q: How do you handle missing data — do you always impute?**
A: No — it depends on what the missingness means. In this project, `Ship_Date`/`Delivery_Date` were
`NA` for cancelled orders, which is a correct business state, not missing data, so I left those as-is.
`Customer_Satisfaction` gaps were flagged with a boolean column rather than imputed, since fabricating
a sentiment score would bias any downstream satisfaction analysis. `Lead_Time_Days` gaps *were*
imputed, using each supplier's median lead time, because lead time is a stable supplier-level
characteristic rather than something that should vary row to row.

**Q: Walk me through your data cleaning dedup logic.**
A: A first pass with `distinct()` caught exact full-row duplicates. But I found a second class of
duplicate that a naive full-row check misses: rows sharing the same `Order_ID` (the actual business
key) that differ on one field because a missing-value flag landed on only one copy during data
generation. I deduped a second time on `Order_ID`, keeping whichever row had fewer `NA`s — a good
example of why you dedupe on the business key, not just row equality.

**Q: What packages did you use and why?**
A: `dplyr`/`tidyr` for data manipulation, `lubridate` for dates, `forecast` for time-series modeling
(`ets`, `auto.arima`, `decompose`), `ggplot2` for visualization, `DBI`/`RSQLite` to build and
query-test a real database rather than just working off a CSV, and `stringr`/`scales` for text
cleaning and chart formatting. I also wrote a small `clean_names()` replacement in `utils.R` since
`janitor` wasn't available through the package repository I had access to in that environment — a
good example of writing a minimal, targeted workaround instead of blocking on a single dependency.

**Q: How do you validate that a data cleaning script actually worked?**
A: Automated assertions, not eyeballing the output. `r/02_data_cleaning.R` ends with five explicit
validation rules (shipped quantity ≤ ordered quantity, non-negative revenue, no duplicate order IDs,
ship date on/after order date, positive selling price) and calls `stopifnot()` — the script fails loudly
if any rule doesn't hold, rather than silently writing out a file that might still have a problem.

## Business Analytics — Interview Q&A

**Q: How do you decide which insights matter enough to put in front of leadership?**
A: Dollar-size and actionability, in that order. This project surfaces plenty of statistically
interesting patterns, but the ones that made the executive summary were the ones with both a real
dollar figure attached ($4.1M in tied-up capital, $148K in direct losses) *and* a concrete lever to
pull (a freight-eligibility rule, a markdown pass) — not just "interesting" correlations without a
clear next action.

**Q: How do you avoid p-hacking or cherry-picking a favorable statistic?**
A: Report what the test actually shows, including when it's inconclusive. I tested two correlations
involving supplier on-time rate — one with customer satisfaction (r=0.82, highly significant) and one
with return rate (r=-0.22, weak) — and reported both, rather than only surfacing the strong one. Same
principle applied to the forecasting comparison: the "sophisticated" models lost, and I explained why
instead of re-running until a preferred model won.

**Q: How would you communicate a finding like "30% of orders are unprofitable" to a non-technical
stakeholder without it sounding alarming or vague?**
A: Immediately follow it with where it's concentrated and what to do about it. "30% of orders lose
money" sounds like a crisis; "30% of orders lose money, and it's 58% concentrated in Electronics
shipped via premium freight — capping Air/Parcel eligibility on low-margin SKUs targets most of it"
is a scoped, fixable problem. Always pair the size of an issue with its concentration and a lever.

**Q: What's a time you found a result that contradicted your initial expectation, and what did you
do?**
A: I expected ARIMA/ETS to beat a simple moving average on the demand forecast — that's the "expected"
outcome going in. When they didn't, I didn't just report the number; I dug into *why* (checked the
model each one actually selected) and found a legitimate, explainable reason tied to the amount of
training history available. Reporting the surprising result *with* the explanation is more credible
and more useful than either hiding it or reporting it without diagnosis.

## How to talk about this project in an interview (30-second version)

"I built an end-to-end supply chain analytics project — a synthetic but realistically-structured
12,000-order dataset, a full R pipeline from cleaning through forecasting through cost optimization,
and a formula-driven Excel reporting layer. The part I'm proudest of isn't the volume of analysis, it's
that every number is grounded and I reported the results honestly even when they weren't the
'expected' outcome — for example, a simple moving average beat ARIMA on the forecast, and instead of
hiding that I diagnosed why (not enough training history for seasonal model selection) and explained
what would change that. I can walk through any part of the pipeline in as much depth as you want."
