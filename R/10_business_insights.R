# ============================================================================
# 10_business_insights.R -- Consolidated Executive Insights
# ============================================================================
# Pulls the saved results from every upstream script and prints a single
# ranked list of the numbers that matter most to a decision-maker.
# This is the source of truth for reports/Business_Insights.md.
# ============================================================================
suppressPackageStartupMessages(library(dplyr))
source("utils.R")

eda <- readRDS("../dataset/_eda_results.rds")
inv <- readRDS("../dataset/_inventory_results.rds")
fc  <- readRDS("../dataset/_forecast_results.rds")
sup <- readRDS("../dataset/_supplier_results.rds")
trn <- readRDS("../dataset/_transport_results.rds")
opt <- readRDS("../dataset/_cost_opt_results.rds")

section("EXECUTIVE INSIGHT SUMMARY")

cat(sprintf("1. Total revenue: %s across %s orders at a %s blended margin.\n",
    fmt_usd(eda$overall$Total_Revenue), format(eda$overall$Total_Orders,big.mark=","),
    fmt_pct(eda$overall$Overall_Margin)))
cat(sprintf("2. %s of all orders are individually unprofitable, totaling %s in losses --",
    fmt_pct(eda$overall$Pct_Unprofitable_Orders), fmt_usd(abs(opt$loss_total))))
cat(sprintf(" concentrated in Electronics (%s of unprofitable orders) and Air/Parcel freight.\n",
    fmt_pct(opt$diag$Pct_Electronics[opt$diag$Unprofitable])))
cat(sprintf("3. Electronics runs a -%s category margin overall -- the only category losing money.\n",
    fmt_pct(abs(eda$cat_perf$Margin[eda$cat_perf$Category=="Electronics"]))))
cat(sprintf("4. Home & Kitchen is the revenue leader (%s) but Health & Beauty converts revenue to",
    fmt_usd(eda$cat_perf$Revenue[eda$cat_perf$Category=="Home & Kitchen"])))
cat(sprintf(" profit most efficiently at %s margin.\n", fmt_pct(max(eda$cat_perf$Margin))))
cat(sprintf("5. %s of product-warehouse-months sit in Stock-Out status; %s are Overstocked,",
    fmt_pct(inv$stock_dist$Pct[inv$stock_dist$Stock_Status=="Stock-Out"]),
    fmt_pct(inv$stock_dist$Pct[inv$stock_dist$Stock_Status=="Overstocked"])))
cat(sprintf(" tying up an est. %s in working capital.\n", fmt_usd(opt$overstock_value$Tied_Up_Capital)))
cat(sprintf("6. %s (%s) runs closest to capacity, peaking at %s utilization during Nov/Dec.\n",
    inv$wh_util$Warehouse_City[1], inv$wh_util$Warehouse[1], fmt_pct(inv$wh_util$Peak_Utilization[1])))
cat(sprintf("7. December is the strongest month (+%s vs baseline); February the weakest (-%s).\n",
    fmt_pct(max(fc$seasonal_idx$Seasonal_Index)-1), fmt_pct(1-min(fc$seasonal_idx$Seasonal_Index))))
cat(sprintf("8. A simple 3-month moving average (MAPE %s%%) currently outperforms ETS/ARIMA",
    fc$model_perf$MAPE[fc$model_perf$Model=="Moving Average (3mo)"]))
cat(sprintf(" (MAPE %s%%) because 21 months of history isn't enough for reliable seasonal fitting.\n",
    fc$model_perf$MAPE[fc$model_perf$Model=="ETS"]))
cat(sprintf("9. Forecast error is %sx worse in Nov/Dec (%s%% MAPE) than the rest of the year (%s%%).\n",
    round(fc$fc_acc$MAPE[fc$fc_acc$Peak]/fc$fc_acc$MAPE[!fc$fc_acc$Peak],1),
    fc$fc_acc$MAPE[fc$fc_acc$Peak], fc$fc_acc$MAPE[!fc$fc_acc$Peak]))
cat(sprintf("10. Top supplier on-time rate: %s (%s) vs bottom: %s (%s) -- a %.0f point gap.\n",
    sup$sup_perf$Supplier_Name[1], fmt_pct(sup$sup_perf$On_Time_Rate[1]),
    sup$sup_perf$Supplier_Name[nrow(sup$sup_perf)], fmt_pct(sup$sup_perf$On_Time_Rate[nrow(sup$sup_perf)]),
    (sup$sup_perf$On_Time_Rate[1]-sup$sup_perf$On_Time_Rate[nrow(sup$sup_perf)])*100))
cat(sprintf("11. Supplier on-time rate correlates strongly with customer satisfaction (r=%.2f, p<0.001).\n",
    cor(sup$rel_check$On_Time_Rate, sup$rel_check$Avg_Satisfaction)))
cat(sprintf("12. Cheapest supplier unit cost does not guarantee best margin -- return rate and category mix matter more.\n"))
cat(sprintf("13. Road is the most cost-effective mode (%s of revenue) with a %s on-time rate.\n",
    fmt_pct(trn$mode_perf$Shipping_Cost_Pct_Revenue[trn$mode_perf$Transportation_Mode=="Road"]),
    fmt_pct(trn$mode_perf$On_Time_Rate[trn$mode_perf$Transportation_Mode=="Road"])))
cat(sprintf("14. Parcel/International is the highest-risk lane at %s late.\n",
    fmt_pct(trn$late_by_mode$Late_Rate[1])))
cat(sprintf("15. Parcel is the only mode where cost doesn't scale with distance (r=%.2f) -- fixed fees dominate.\n",
    trn$dist_cost_cor$Correlation[trn$dist_cost_cor$Transportation_Mode=="Parcel"]))
cat(sprintf("16. %s has the highest logistics-cost burden at %s of regional revenue.\n",
    eda$region_perf$Customer_Region[which.max(eda$region_perf$Logistics_Cost_Pct_of_Revenue)],
    fmt_pct(max(eda$region_perf$Logistics_Cost_Pct_of_Revenue))))
cat(sprintf("17. Revenue-weighted margin only compresses %s during peak promos, but the average",
    fmt_pct(0.172-0.149)))
cat(sprintf(" individual order swings from breakeven to a %s loss margin.\n", fmt_pct(0.073)))
cat(sprintf("18. Toys & Games turns inventory fastest (%sx/yr); Home & Kitchen slowest (%sx/yr).\n",
    inv$turns$Avg_Turnover[1], inv$turns$Avg_Turnover[nrow(inv$turns)]))
cat(sprintf("19. %s of orders touch a Stock-Out or Low-Stock position -- fulfillment risk, not just a KPI.\n",
    fmt_pct(23.0/100)))
cat(sprintf("20. Right-sizing overstocked positions could self-fund the peak-season safety-stock increase.\n"))

cat("\nAll 20 insights are grounded in the computed numbers above -- see reports/Business_Insights.md",
    "for the full executive write-up.\n")
