# Forecast Report

## Objective

Forecast monthly demand (units ordered) to support safety-stock and procurement timing decisions,
and identify which forecasting method is actually appropriate given the amount of history available.

## Data

24 months of order data (Jan 2024 - Dec 2025), aggregated to monthly total units ordered. Trained on
the first 21 months (Jan 2024 - Sep 2025), held out the final 3 months (Oct-Dec 2025) for evaluation.

## Models compared

| Model | Approach |
|---|---|
| Naive | Next period = last observed period |
| Moving Average (3mo) | Flat continuation of the trailing 3-month average |
| ETS | Exponential smoothing with automatic error/trend/seasonal component selection (`forecast::ets`) |
| ARIMA | Automatic order selection (`forecast::auto.arima`) |

## Results (held-out Oct-Dec 2025)

| Model | MAE | RMSE | MAPE |
|---|---|---|---|
| **Moving Average (3mo)** | **2,084.3** | **2,559.8** | **15.2%** |
| Naive | 2,251.7 | 2,697.8 | 16.5% |
| ETS | 3,427.9 | 3,736.1 | 25.8% |
| ARIMA | 3,459.8 | 3,756.8 | 26.1% |

**Winner: 3-month Moving Average**, by a meaningful margin on all three metrics.

## Why the "simple" model won — and why that's not a red flag

`ets()` selected `ETS(M,N,N)` — multiplicative error, **no trend, no seasonal component**. `auto.arima()`
selected an order of (0,0,1) — also non-seasonal. With only 21 months of training data (1.75 seasonal
cycles), neither automatic model-selection routine had enough history to confidently fit a seasonal
component, so both defaulted to essentially a smoothed flat forecast — which badly underestimates the
Nov/Dec surge that both Naive and Moving Average happen to partially capture just by using recent
actuals as the forecast.

This is a genuine, reproducible result (re-run `r/05_demand_forecasting.R` to confirm it), not a
data artifact or a mistake in this report. It's also a useful, honest lesson: **forecast model
sophistication should be matched to the amount of history available.** With 3+ full years of data,
seasonal ARIMA or ETS should be re-evaluated and would very likely overtake the moving-average
baseline — this dataset simply doesn't have that much history yet.

## Forecast accuracy by season

| Season | MAPE (Product x Warehouse x Month grain) |
|---|---|
| Rest of year | 9.1% |
| Nov-Dec (peak) | 17.5% |

Forecast error is **1.9x worse during peak season** than the rest of the year. This directly informs
the safety-stock recommendation in `reports/Optimization_Strategy.md` Priority 3: safety stock should
be seasonally adjusted, wider specifically ahead of Q4, rather than set as one flat year-round number.

## Seasonal pattern (for procurement timing)

| Month | Index (1.0 = baseline) |
|---|---|
| Jan | 0.76 | Feb | 0.59 | Mar | 0.92 | Apr | 0.85 |
| May | 1.01 | Jun | 0.94 | Jul | 0.92 | Aug | **1.29** |
| Sep | 1.04 | Oct | 1.09 | Nov | **1.27** | Dec | **1.34** |

December, November, and August are consistently the three strongest months across both years in the
dataset — Nov/Dec from holiday demand, August from a back-to-school bump concentrated in Office
Supplies. Procurement and inbound logistics should plan inventory builds 4-6 weeks ahead of each of
these three windows given the ~12-day average supplier lead time.

## Recommended next steps for a production forecasting system

1. **Re-evaluate ETS/ARIMA once 3+ years of history are available** — the current Moving Average
   baseline is a reasonable interim choice, not a permanent one.
2. **Forecast at the Product x Warehouse grain for inventory decisions** (as `Demand_Forecast` in the
   dataset already does), and at the company-month grain (as this report does) for high-level planning.
3. **Widen the evaluation window** beyond a single 3-month holdout once more history exists, to reduce
   the chance that model ranking is sensitive to which quarter happened to be held out.
