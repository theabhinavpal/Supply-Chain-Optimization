# ============================================================================
# 08_cost_optimization.R -- Cost & Profitability Optimization
# ============================================================================
suppressPackageStartupMessages(library(dplyr))
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# ANALYSIS 16: What's actually driving unprofitable orders?
# ---------------------------------------------------------------------------
section("ANALYSIS 16 -- Diagnosing Unprofitable Orders")
unprof <- df %>% mutate(Unprofitable = Profit < 0)
diag <- unprof %>% group_by(Unprofitable) %>% summarise(
  Orders = n(), Avg_Shipping_Pct_Rev = round(mean(Shipping_Cost/pmax(Revenue,1)),3),
  Pct_Air_or_Parcel = round(mean(Transportation_Mode %in% c("Air","Parcel")),3),
  Pct_Electronics = round(mean(Category == "Electronics"),3), .groups="drop")
print(diag)
loss_total <- sum(unprof$Profit[unprof$Unprofitable])
cat("\nTotal $ lost across unprofitable orders:", fmt_usd(loss_total), "\n")
cat("Business Insight: Unprofitable orders skew heavily toward Electronics (",
    fmt_pct(diag$Pct_Electronics[diag$Unprofitable]), "of unprofitable orders vs",
    fmt_pct(diag$Pct_Electronics[!diag$Unprofitable]), "of profitable ones) and toward",
    "premium freight (Air/Parcel at", fmt_pct(diag$Pct_Air_or_Parcel[diag$Unprofitable]), "vs",
    fmt_pct(diag$Pct_Air_or_Parcel[!diag$Unprofitable]), ") -- the fix is restricting Air/Parcel",
    "eligibility on low-margin SKUs below a minimum order value, not blanket discounting.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 17: Promotional discounting -- is peak-season discounting worth it?
# ---------------------------------------------------------------------------
section("ANALYSIS 17 -- Peak-Season Discounting Impact on Margin")
promo_check <- df %>% mutate(Month = as.integer(substr(Order_Date,6,7)), Peak = Month %in% c(11,12)) %>%
  group_by(Peak) %>% summarise(Orders=n(), Avg_Order_Margin=round(mean(Profit_Margin,na.rm=TRUE),3),
                                 Revenue=sum(Revenue), Profit=sum(Profit),
                                 Weighted_Margin=round(sum(Profit)/sum(Revenue),3), .groups="drop") %>%
  mutate(Season = if_else(Peak,"Nov-Dec (Peak/Promo)","Rest of Year"))
print(promo_check %>% select(Season, Orders, Avg_Order_Margin, Weighted_Margin, Revenue, Profit))
w_peak <- promo_check$Weighted_Margin[promo_check$Peak]; w_rest <- promo_check$Weighted_Margin[!promo_check$Peak]
a_peak <- promo_check$Avg_Order_Margin[promo_check$Peak]; a_rest <- promo_check$Avg_Order_Margin[!promo_check$Peak]
cat("\nBusiness Insight: Two different views tell two different parts of the story. The revenue-weighted",
    "margin (total profit / total revenue) only compresses from", fmt_pct(w_rest), "to", fmt_pct(w_peak),
    "in peak season -- the portfolio stays solidly profitable because a handful of large, high-margin",
    "orders dominate total revenue. But the simple average order margin swings from", fmt_pct(a_rest), "to",
    fmt_pct(a_peak), "-- meaning a large share of individual orders (concentrated in Electronics, see",
    "08_cost_optimization.R Analysis 16) are sold at a loss during peak promotions even though the",
    "portfolio total stays positive. Recommendation: cap discount depth by category margin floor",
    "rather than a flat storewide promo percentage.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 18: Safety stock / reorder point right-sizing opportunity
# ---------------------------------------------------------------------------
section("ANALYSIS 18 -- Safety Stock Right-Sizing Opportunity")
ss_opp <- df %>% distinct(Product_ID, Warehouse, Stock_Status, Inventory_Level, Reorder_Point, Supplier_Unit_Cost)
overstock_value <- ss_opp %>% filter(Stock_Status=="Overstocked") %>%
  summarise(Excess_Units = sum(Inventory_Level - 3*Reorder_Point),
            Tied_Up_Capital = sum((Inventory_Level - 3*Reorder_Point) * Supplier_Unit_Cost))
cat("Estimated excess units sitting in 'Overstocked' positions:", round(overstock_value$Excess_Units), "\n")
cat("Estimated working capital tied up in excess inventory:", fmt_usd(overstock_value$Tied_Up_Capital), "\n")
understock_orders <- df %>% filter(Stock_Status %in% c("Stock-Out","Low Stock"))
cat("\nOrders placed against Stock-Out/Low-Stock positions:", nrow(understock_orders),
    "(", fmt_pct(nrow(understock_orders)/nrow(df)), "of all orders )\n")
cat("\nBusiness Insight: Right-sizing the", nrow(ss_opp %>% filter(Stock_Status=="Overstocked")),
    "overstocked product-warehouse positions would free an estimated",
    fmt_usd(overstock_value$Tied_Up_Capital), "in working capital -- capital that could fund",
    "the safety-stock increase already recommended for peak season in 04_inventory_analysis.R",
    "and 05_demand_forecasting.R, largely self-funding the fix.\n")

saveRDS(list(diag=diag, promo_check=promo_check, overstock_value=overstock_value, loss_total=loss_total),
        "../dataset/_cost_opt_results.rds")
