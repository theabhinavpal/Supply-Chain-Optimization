# Business Insights

20 executive-level insights, every number pulled directly from the R analysis scripts in `r/`
(re-run `Rscript 10_business_insights.R` to reproduce the summary this document is based on).

## Revenue & Profitability

**1. The business is profitable overall, but nearly a third of individual orders lose money.**
$9,951,737 in revenue across 12,000 orders at a 16.7% blended margin — but 30.8% of orders (3,702 of
them) are individually unprofitable, totaling $148,394 in losses. The portfolio total stays healthy
because a relatively small number of large, high-margin orders carry it. *(`03_eda.R`, `08_cost_optimization.R`)*

**2. Electronics is the only category losing money overall.** Electronics runs a **-21.0%** category
margin (-$79,543 on $378,262 of revenue) — every other category is profitable, ranging from Sporting
Goods at a thin 7.0% up to Health & Beauty at 27.7%. Electronics combines the thinnest starting margin
band with the smallest, lowest-value units, which means fixed freight fees (especially Air/Parcel) can
exceed the entire product margin on a single unit.

**3. Unprofitable orders are concentrated, not random.** Orders that lose money are disproportionately
Electronics (58.5% of unprofitable orders vs. just 3.6% of profitable ones) and disproportionately
shipped via premium freight (Air/Parcel at 39.1% of unprofitable orders vs. 29.7% of profitable ones).
**Recommendation:** restrict Air/Parcel eligibility on low-margin SKUs below a minimum order value,
rather than relying on blanket discount caps.

**4. Home & Kitchen leads revenue; Health & Beauty leads profitability.** Home & Kitchen is the
largest category by revenue ($3,959,985) but Health & Beauty converts revenue to profit most
efficiently (27.7% margin). Revenue leadership and margin leadership are not the same thing, and
category investment decisions should weigh both.

**5. Peak-season discounting compresses margin more than the topline suggests.** The revenue-weighted
margin only slips from 17.2% (rest of year) to 14.9% (Nov/Dec) — the portfolio stays solidly
profitable in aggregate. But the *simple average* order margin swings from a roughly breakeven +0.2%
to **-7.3%** in peak season — meaning a large share of individual orders, concentrated in Electronics,
are sold at a loss during the holiday promotional window even though total portfolio dollars stay
positive. **Recommendation:** cap discount depth by category margin floor, not a flat storewide
promo percentage.

**6. Middle East & Africa carries the highest logistics-cost burden.** At 12.0% of regional revenue
(vs. 6.3-6.6% for North America and Europe), MEA's logistics cost ratio is roughly double the
company's best-performing regions — driven by longer average shipping distances and a heavier mix of
Air/Sea freight to a single, smaller warehouse (Dubai).

## Inventory & Warehousing

**7. Nearly a quarter of orders touch a stock-out or low-stock position.** 1.6% of product-warehouse-
months are fully Stock-Out and another 21.3% are Low Stock — together, 23.0% of all orders in the
dataset are placed against a constrained inventory position, directly causing partial shipments
(148 units short-shipped across flagged stock-out orders in this dataset alone).

**8. Overstocking is a bigger dollar problem than stock-outs.** 16.0% of product-warehouse-month
positions are Overstocked, tying up an estimated **$4.1M** in working capital across 1,907 positions —
compare that to the roughly $6,900 in short-shipped value lost to stock-outs. The inventory problem in
this business is capital efficiency, not just availability.

**9. Toys & Games turns inventory 2.3x faster than Home & Kitchen.** Average annualized turnover
ranges from 5.30x/year (Toys & Games) down to 2.34x/year (Home & Kitchen) — Home & Kitchen's slower
turnover, combined with it being the #1 revenue category, makes it the single best candidate for
safety-stock right-sizing.

**10. Singapore's warehouse is the tightest capacity constraint in the network.** WH-SIN averages
70.8% utilization but peaks at **135%** of rated capacity, exceeding 100% in 5 of the 24 months in the
dataset — consistently the Nov/Dec surge. Dubai (WH-DXB) is a close second at a 130% peak. Both should
have overflow/3PL capacity pre-booked ahead of Q4 rather than scaling internal capacity for a
once-a-year peak.

**11. Freeing up overstocked capital could self-fund the peak-season safety-stock increase.**
Right-sizing the 1,907 overstocked positions frees an estimated $4.1M — comfortably enough to fund
the wider Q4 safety-stock buffer recommended in insight #14, largely making the fix self-funded rather
than requiring new working capital.

## Demand Forecasting

**12. Seasonality is real and repeatable, not noise.** December runs 33.5% above the monthly demand
baseline; February runs 40.7% below it. December, November, and August are consistently the three
strongest months across *both* years in the dataset — Nov/Dec from holiday demand, August from a
back-to-school bump concentrated in Office Supplies.

**13. A simple 3-month moving average currently beats ETS and ARIMA on this data — and the reason
matters.** On a held-out Oct-Dec 2025 test window, Moving Average scores 15.2% MAPE vs. Naive's 16.5%,
while ETS and ARIMA score a much worse 25.8% and 26.1%. The reason isn't that the simple model is
smarter: with only 21 months of training history (under two full seasonal cycles), `ets()`'s automatic
model selection fell back to a **non-seasonal** fit (`ETS(M,N,N)`), so it badly underestimates the
Nov/Dec surge. This is a genuine, reproducible finding, not a data artifact — and a good real-world
lesson: **always benchmark a sophisticated model against a naive baseline before trusting it**, since
model sophistication is only an advantage once there's enough history to support it. With 3+ years of
data, seasonal ARIMA/ETS should overtake the moving-average baseline.

**14. Forecast accuracy nearly doubles in error during peak season.** Product x warehouse x month
demand forecasts run 17.5% MAPE in Nov/Dec vs. 9.1% the rest of the year — 1.9x worse. Safety stock
policy should widen ahead of Q4 specifically, rather than using one flat year-round buffer.

## Supplier Performance

**15. There's a 30-point on-time delivery gap between the best and worst suppliers.** Pinnacle
Manufacturing delivers on time 93.2% of the time; Anchor Trading Ltd. manages just 62.9% (both above
the 30-order minimum sample threshold). That gap is large enough to be a primary lever for the
company's overall delivery reliability, not just a rounding difference.

**16. Supplier reliability is statistically linked to customer satisfaction — this isn't just an
operations metric.** Supplier on-time rate correlates with average customer satisfaction at **r =
0.82** (p < 0.001, highly significant) across the 40 suppliers. Late-running suppliers measurably move
the customer experience number leadership actually tracks.

**17. The cheapest supplier isn't automatically the most profitable one to use.** Several of the
lowest-average-margin supplier relationships (down to -90% average order margin) are *not* the
highest-unit-cost suppliers — margin also depends heavily on return rate and the category mix that
supplier happens to serve. **Recommendation:** score procurement relationships on realized margin
contribution, not quoted unit cost alone.

## Transportation & Logistics

**18. Road is both the cheapest and one of the most reliable modes.** Road shipping costs just 5.4% of
the revenue it carries (the lowest of any mode) with an 83.1% on-time rate — the benchmark every other
mode should be measured against for domestic and regional lanes. Sea and Air both run close to 18% of
revenue in shipping cost, roughly 3.5x Road's ratio.

**19. Parcel/International is the highest-risk lane combination in the network.** 92.2% of
Parcel-shipped international orders run late — dramatically worse than any domestic combination (Road
domestic: 16.9%; Rail domestic: just 4.0%). This is a strong candidate for either a carrier SLA
renegotiation or a mode substitution (e.g., consolidating into Sea/Air for that lane) rather than
continuing to route small international shipments through standard parcel carriers.

**20. Parcel is the only mode where shipping cost doesn't scale with distance.** Distance-to-cost
correlation is r = 0.50 for Parcel vs. r > 0.97 for Sea, Road, and Rail — meaning Parcel's flat
per-shipment and per-kg fees dominate its total cost regardless of how far the shipment travels. For
long-haul lanes specifically, that makes Parcel relatively more cost-competitive as distance grows,
which should factor into mode-selection rules alongside the raw on-time-rate comparison in insight #19.

---

*Every figure above traces back to a specific R script and analysis number — see
`reports/Business_Questions.md` for the full question-to-script mapping, and `reports/KPI_Report.md`
for the underlying KPI definitions.*
