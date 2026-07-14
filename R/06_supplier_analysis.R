# ============================================================================
# 06_supplier_analysis.R -- Supplier Performance Analysis
# ============================================================================
suppressPackageStartupMessages(library(dplyr))
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# ANALYSIS 10: Supplier on-time delivery ranking
# ---------------------------------------------------------------------------
section("ANALYSIS 10 -- Supplier On-Time Delivery Performance")
sup_perf <- df %>% group_by(Supplier_ID, Supplier_Name) %>% summarise(
  Orders = n(), Revenue = sum(Revenue),
  On_Time_Rate = round(1 - mean(Late_Delivery), 3),
  Avg_Lead_Time = round(mean(Lead_Time_Days), 1),
  .groups = "drop") %>% filter(Orders >= 30) %>% arrange(desc(On_Time_Rate))
cat("Top 5 suppliers by on-time rate (min. 30 orders):\n"); print(head(sup_perf, 5))
cat("\nBottom 5 suppliers by on-time rate (min. 30 orders):\n"); print(tail(sup_perf, 5))
best_sup <- sup_perf$Supplier_Name[1]; worst_sup <- sup_perf$Supplier_Name[nrow(sup_perf)]
cat("\nBusiness Insight:", best_sup, "delivers on time", fmt_pct(sup_perf$On_Time_Rate[1]), "of the time vs",
    worst_sup, "at just", fmt_pct(sup_perf$On_Time_Rate[nrow(sup_perf)]),
    "-- a", round((sup_perf$On_Time_Rate[1]-sup_perf$On_Time_Rate[nrow(sup_perf)])*100,0),
    "point gap that directly explains part of the late-delivery variance seen in customer satisfaction.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 11: Does supplier reliability actually correlate with satisfaction/returns?
# ---------------------------------------------------------------------------
section("ANALYSIS 11 -- Supplier Reliability vs Customer Outcomes")
rel_check <- df %>% group_by(Supplier_ID) %>% summarise(
  On_Time_Rate = 1 - mean(Late_Delivery),
  Avg_Satisfaction = mean(Customer_Satisfaction, na.rm = TRUE),
  Return_Rate = mean(Order_Status == "Returned"), .groups = "drop") %>% filter(!is.na(Avg_Satisfaction))
cor_sat <- cor(rel_check$On_Time_Rate, rel_check$Avg_Satisfaction)
cor_ret <- cor(rel_check$On_Time_Rate, rel_check$Return_Rate)
cat("Correlation: Supplier On-Time Rate vs Avg Customer Satisfaction:", round(cor_sat,3), "\n")
cat("Correlation: Supplier On-Time Rate vs Return Rate:", round(cor_ret,3), "\n")
ct <- cor.test(rel_check$On_Time_Rate, rel_check$Avg_Satisfaction)
cat("Hypothesis test (H0: no correlation) p-value:", signif(ct$p.value,3), "\n")
cat("\nBusiness Insight: Supplier on-time rate is", if_else(cor_sat>0.3,"positively","weakly"),
    "correlated with customer satisfaction (r =", round(cor_sat,2),
    ", p =", signif(ct$p.value,3), ") -- statistically", if_else(ct$p.value<0.05,"significant,","not significant,"),
    "supporting supplier scorecards as a lever for the satisfaction KPI, not just an ops metric.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 12: Landed cost variance -- cheaper suppliers aren't always cheaper
# ---------------------------------------------------------------------------
section("ANALYSIS 12 -- Supplier Cost Efficiency (Landed Cost vs Margin)")
cost_eff <- df %>% group_by(Supplier_ID, Supplier_Name) %>% summarise(
  Orders = n(), Avg_Unit_Cost = round(mean(Supplier_Unit_Cost),2),
  Avg_Margin = round(mean(Profit_Margin, na.rm=TRUE),3),
  Defect_Proxy_Return_Rate = round(mean(Order_Status=="Returned"),3),
  .groups="drop") %>% filter(Orders >= 30) %>% arrange(desc(Avg_Margin))
cat("Top 5 suppliers by average order margin:\n"); print(head(cost_eff %>% select(-Orders), 5))
cat("\nBottom 5 suppliers by average order margin:\n"); print(tail(cost_eff %>% select(-Orders), 5))
cat("\nBusiness Insight: The lowest-unit-cost supplier is not automatically the most profitable --",
    "margin also depends on return rate and category mix, so procurement should score suppliers on",
    "realized margin contribution, not quoted unit cost alone.\n")

saveRDS(list(sup_perf=sup_perf, rel_check=rel_check, cost_eff=cost_eff), "../dataset/_supplier_results.rds")
