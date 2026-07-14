# Optimization Strategy

Concrete, prioritized recommendations, each tied to a specific analysis and the dollar impact behind it.

## Priority 1 — Fix Electronics unit economics (freight-eligibility rule)

**Problem:** Electronics is the only category with a negative overall margin (-21.0%, -$79,543).
Unprofitable orders company-wide are 58.5% Electronics and 39.1% Air/Parcel freight, vs. 3.6% and
29.7% respectively among profitable orders. *(`r/08_cost_optimization.R` Analysis 16)*

**Recommendation:** Introduce a minimum order value threshold for Air/Parcel eligibility on
low-margin categories (Electronics first, then Sporting Goods and Furniture as secondary
candidates). Orders below the threshold default to Road/Sea. This targets the mechanism directly
(fixed freight fees exceeding thin per-unit margin) rather than a blanket price increase that would
also hit healthy-margin orders in the same category.

**Expected impact:** a meaningful share of the $148,394 in aggregate order-level losses is
concentrated in exactly this Electronics + premium-freight combination — this single rule addresses
the highest-concentration driver identified in the diagnostic.

## Priority 2 — Right-size overstocked inventory positions

**Problem:** 16.0% of product-warehouse positions are overstocked, tying up an estimated $4.1M in
working capital — more than the entire dollar impact of stock-outs. Home & Kitchen, the #1 revenue
category, also has the slowest inventory turnover (2.34x/yr). *(`r/04_inventory_analysis.R` Analysis 5,
`r/08_cost_optimization.R` Analysis 18)*

**Recommendation:** Run a markdown/liquidation pass on the identified overstocked SKUs (see
`excel/Reports.xlsx` for the underlying data), starting with Home & Kitchen and Health & Beauty (the
two slowest-turning categories). Redirect the freed capital directly into Priority 3 below.

**Expected impact:** ~$4.1M in freed working capital, self-funding the peak-season safety-stock
increase without new capital outlay.

## Priority 3 — Widen safety stock specifically for Q4

**Problem:** Demand forecast error is 1.9x worse in Nov/Dec (17.5% MAPE) than the rest of the year
(9.1%), and Singapore's warehouse already peaks at 135% of rated capacity during that window (Dubai at
130%). A flat, year-round safety-stock policy is by definition too thin for Q4 and likely too generous
for the rest of the year. *(`r/05_demand_forecasting.R` Analysis 9, `r/04_inventory_analysis.R` Analysis 6)*

**Recommendation:** Move from a flat safety-stock formula to a season-adjusted one — widen the buffer
specifically for Oct-Dec at the Product x Warehouse combinations with the highest historical Nov/Dec
seasonal boost (Toys & Games, Electronics, Home & Kitchen), and pre-book 3PL overflow capacity at
Singapore and Dubai ahead of the surge rather than scaling permanent capacity for a six-week peak.

**Expected impact:** reduced stock-out risk during the highest-value six weeks of the year, funded by
Priority 2's freed capital rather than new spend.

## Priority 4 — Supplier scorecard-driven procurement

**Problem:** On-time delivery ranges from 93.2% (best) to 62.9% (worst) among suppliers with
sufficient order volume, and on-time rate correlates with customer satisfaction at r = 0.82
(p < 0.001) — this isn't a soft metric. Separately, the cheapest suppliers by unit cost are not
consistently the most profitable to work with once return rate and category mix are accounted for.
*(`r/06_supplier_analysis.R` Analyses 10-12)*

**Recommendation:** Formalize the composite scorecard already built in `excel/Reports.xlsx`
(50% on-time rate, 35% realized margin, 15% inverse return rate) as the standing procurement review
tool, and use it — not quoted unit cost — as the primary input to sourcing decisions and supplier
renegotiation conversations.

## Priority 5 — Mode/lane-specific freight policy

**Problem:** Parcel/International shipments run late 92.2% of the time, by far the highest-risk lane
combination in the network, while Road remains both the cheapest (5.4% of revenue) and one of the most
reliable modes (83.1% on-time) for domestic lanes. *(`r/07_transportation_analysis.R` Analyses 13-14)*

**Recommendation:** Renegotiate the Parcel carrier SLA for international lanes, or substitute Sea/Air
consolidation for that specific lane combination. Use Road as the default benchmark mode for any new
domestic lane decision.

---

## Summary of dollar impact identified

| Priority | Issue | Dollar impact identified |
|---|---|---|
| 1 | Unprofitable orders (Electronics + premium freight) | $148,394 in direct losses |
| 2 | Overstocked inventory | ~$4.1M in tied-up working capital |
| 3 | Peak-season forecast/stock-out risk | Qualitative + capacity risk (135% peak utilization) |
| 4 | Supplier reliability gap | 30-point on-time rate spread; r=0.82 satisfaction link |
| 5 | High-risk freight lane | 92.2% late rate on Parcel/International |

None of these require new systems or headcount — they're policy and threshold changes applied to data
the business already collects.
