# ============================================================================
# 03_eda.R -- Exploratory Data Analysis
# ============================================================================
suppressPackageStartupMessages({ library(dplyr); library(lubridate) })
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE) %>%
  mutate(Order_Date = as.Date(Order_Date))

# ---------------------------------------------------------------------------
# ANALYSIS 1: Overall revenue, profit & order volume
# Business Question: What's the headline size of the business in this dataset?
# ---------------------------------------------------------------------------
section("ANALYSIS 1 -- Overall Revenue, Profit & Order Volume")
overall <- df %>% summarise(
  Total_Orders = n(),
  Total_Revenue = sum(Revenue),
  Total_Profit = sum(Profit),
  Avg_Order_Value = mean(Revenue),
  Overall_Margin = sum(Profit)/sum(Revenue),
  Pct_Unprofitable_Orders = mean(Profit < 0)
)
print(overall)
cat("\nInterpretation: The business processed", format(overall$Total_Orders, big.mark=","),
    "orders totaling", fmt_usd(overall$Total_Revenue), "in revenue at a",
    fmt_pct(overall$Overall_Margin), "blended margin.\n")
cat("Business Insight: ", fmt_pct(overall$Pct_Unprofitable_Orders),
    "of orders are unprofitable (freight + discounting outweighing product margin) --",
    "this is quantified further in 08_cost_optimization.R.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 2: Category performance (revenue, margin, and volume)
# Business Question: Which product categories generate the most revenue,
# and which are the most/least profitable per dollar of revenue?
# ---------------------------------------------------------------------------
section("ANALYSIS 2 -- Category Performance")
cat_perf <- df %>% group_by(Category) %>% summarise(
  Orders = n(),
  Revenue = sum(Revenue),
  Profit = sum(Profit),
  Margin = round(sum(Profit)/sum(Revenue), 3),
  Avg_Satisfaction = round(mean(Customer_Satisfaction, na.rm = TRUE), 2)
) %>% arrange(desc(Revenue))
print(cat_perf)
top_cat <- cat_perf$Category[1]
best_margin_cat <- cat_perf$Category[which.max(cat_perf$Margin)]
worst_margin_cat <- cat_perf$Category[which.min(cat_perf$Margin)]
cat("\nBusiness Insight:", top_cat, "leads in raw revenue, but", best_margin_cat,
    "converts revenue to profit most efficiently (", fmt_pct(max(cat_perf$Margin)), "margin ) while",
    worst_margin_cat, "runs the thinnest margin at", fmt_pct(min(cat_perf$Margin)), ".\n")

# ---------------------------------------------------------------------------
# ANALYSIS 3: Regional performance (revenue & logistics cost)
# Business Question: Which customer regions drive the most revenue, and
# where is logistics cost eating into margin the most?
# ---------------------------------------------------------------------------
section("ANALYSIS 3 -- Regional Performance & Logistics Cost Burden")
region_perf <- df %>% group_by(Customer_Region) %>% summarise(
  Orders = n(),
  Revenue = sum(Revenue),
  Shipping_Cost = sum(Shipping_Cost),
  Logistics_Cost_Pct_of_Revenue = round(sum(Shipping_Cost)/sum(Revenue), 3),
  Late_Delivery_Rate = round(mean(Late_Delivery), 3)
) %>% arrange(desc(Revenue))
print(region_perf)
worst_logistics <- region_perf$Customer_Region[which.max(region_perf$Logistics_Cost_Pct_of_Revenue)]
cat("\nBusiness Insight:", worst_logistics, "has the highest logistics cost burden at",
    fmt_pct(max(region_perf$Logistics_Cost_Pct_of_Revenue)), "of revenue -- a candidate for",
    "regional warehousing or mode-mix optimization (see 07_transportation_analysis.R).\n")

saveRDS(list(overall=overall, cat_perf=cat_perf, region_perf=region_perf), "../dataset/_eda_results.rds")
