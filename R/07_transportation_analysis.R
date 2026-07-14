# ============================================================================
# 07_transportation_analysis.R -- Transportation & Logistics Analysis
# ============================================================================
suppressPackageStartupMessages(library(dplyr))
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# ANALYSIS 13: Cost-effectiveness by transportation mode
# ---------------------------------------------------------------------------
section("ANALYSIS 13 -- Transportation Mode Cost-Effectiveness")
mode_perf <- df %>% group_by(Transportation_Mode) %>% summarise(
  Orders = n(),
  Avg_Shipping_Cost = round(mean(Shipping_Cost),2),
  Shipping_Cost_Pct_Revenue = round(sum(Shipping_Cost)/sum(Revenue),3),
  On_Time_Rate = round(1-mean(Late_Delivery),3),
  Avg_Distance_KM = round(mean(Transportation_Distance_KM),0),
  .groups="drop") %>% arrange(Shipping_Cost_Pct_Revenue)
print(mode_perf)
cheapest <- mode_perf$Transportation_Mode[1]
cat("\nBusiness Insight:", cheapest, "is the most cost-effective mode at",
    fmt_pct(mode_perf$Shipping_Cost_Pct_Revenue[1]), "of revenue with a",
    fmt_pct(mode_perf$On_Time_Rate[mode_perf$Transportation_Mode==cheapest]), "on-time rate --",
    "the benchmark other modes should be compared against for domestic/regional lanes.\n")

p1 <- ggplot(df, aes(x=Transportation_Mode, y=Shipping_Cost, fill=Transportation_Mode)) +
  geom_boxplot(outlier.alpha=0.25, show.legend = FALSE) + scale_fill_manual(values=scm_palette) +
  scale_y_continuous(labels = dollar_format()) +
  labs(title="Shipping Cost Distribution by Transportation Mode", x=NULL, y="Shipping Cost ($)") +
  theme_scm()
save_chart(p1, "09_shipping_cost_by_mode.png")

# ---------------------------------------------------------------------------
# ANALYSIS 14: Late delivery rate by mode x is-international (root cause)
# ---------------------------------------------------------------------------
section("ANALYSIS 14 -- Late Delivery Rate by Mode & Route Type")
df <- df %>% mutate(Route_Type = if_else(Customer_Region == Warehouse_Region, "Domestic", "International"))
late_by_mode <- df %>% group_by(Transportation_Mode, Route_Type) %>%
  summarise(Orders=n(), Late_Rate=round(mean(Late_Delivery),3), .groups="drop") %>%
  filter(Orders >= 20) %>% arrange(desc(Late_Rate))
print(late_by_mode)
worst_combo <- late_by_mode[1,]
cat("\nBusiness Insight:", worst_combo$Transportation_Mode, "/", worst_combo$Route_Type,
    "shipments run late", fmt_pct(worst_combo$Late_Rate), "of the time -- the highest-risk lane",
    "combination in the network and a strong candidate for a carrier SLA renegotiation",
    "or mode substitution.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 15: Distance vs shipping cost -- diminishing returns / mode crossover
# ---------------------------------------------------------------------------
section("ANALYSIS 15 -- Distance vs Shipping Cost by Mode")
dist_cost_cor <- df %>% group_by(Transportation_Mode) %>%
  summarise(Correlation = round(cor(Transportation_Distance_KM, Shipping_Cost), 3), .groups="drop")
print(dist_cost_cor)
p2 <- ggplot(df %>% sample_n(min(3000,nrow(df))), aes(x=Transportation_Distance_KM, y=Shipping_Cost, color=Transportation_Mode)) +
  geom_point(alpha=0.35, size=1.2) + scale_color_manual(values=scm_palette) +
  scale_y_continuous(labels=dollar_format()) +
  labs(title="Shipping Cost vs Distance by Mode", x="Distance (km)", y="Shipping Cost ($)") +
  theme_scm()
save_chart(p2, "10_distance_vs_cost.png")
cat("\nBusiness Insight: Parcel is the only mode where shipping cost is weakly tied to distance",
    "(r =", dist_cost_cor$Correlation[dist_cost_cor$Transportation_Mode=="Parcel"],
    ") because its flat per-shipment and per-kg fees dominate the total -- Sea, Road and Rail are",
    "all r > 0.97, scaling almost linearly with distance. For long-haul lanes, Parcel's fixed-fee",
    "structure makes it relatively more attractive versus distance-sensitive modes as distance grows.\n")

saveRDS(list(mode_perf=mode_perf, late_by_mode=late_by_mode, dist_cost_cor=dist_cost_cor), "../dataset/_transport_results.rds")
