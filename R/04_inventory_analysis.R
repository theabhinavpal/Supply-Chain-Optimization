# ============================================================================
# 04_inventory_analysis.R -- Inventory & Warehouse Analysis
# ============================================================================
suppressPackageStartupMessages(library(dplyr))
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# ANALYSIS 4: Stock status distribution & the revenue at risk from stock-outs
# ---------------------------------------------------------------------------
section("ANALYSIS 4 -- Stock Status Distribution & Stock-Out Impact")
stock_dist <- df %>% count(Stock_Status) %>% mutate(Pct = round(n/sum(n), 3)) %>% arrange(desc(n))
print(stock_dist)

stockout_orders <- df %>% filter(Stock_Status == "Stock-Out")
lost_qty <- sum(stockout_orders$Quantity_Ordered - stockout_orders$Quantity_Shipped)
lost_rev_est <- round(lost_qty * mean(df$Selling_Price)) 
cat("\nOrders touching a stock-out product-warehouse-month:", nrow(stockout_orders), "\n")
cat("Units short-shipped on those orders:", lost_qty, "\n")
pct_stockout <- stock_dist$Pct[stock_dist$Stock_Status=="Stock-Out"]
cat("\nBusiness Insight:", fmt_pct(pct_stockout), "of product-warehouse-months are in a Stock-Out",
    "state, directly causing partial shipments and an estimated", fmt_usd(lost_rev_est),
    "in short-shipped unit value across the dataset.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 5: Inventory turnover by category (fast movers vs. dead stock)
# ---------------------------------------------------------------------------
section("ANALYSIS 5 -- Inventory Turnover by Category")
turns <- df %>% distinct(Product_ID, Category, Inventory_Turnover) %>%
  group_by(Category) %>% summarise(Avg_Turnover = round(mean(Inventory_Turnover, na.rm=TRUE), 2),
                                     Products = n()) %>% arrange(desc(Avg_Turnover))
print(turns)
fastest <- turns$Category[1]; slowest <- turns$Category[nrow(turns)]
cat("\nBusiness Insight:", fastest, "turns inventory fastest (", turns$Avg_Turnover[1],
    "x/year ) while", slowest, "is the slowest mover at", turns$Avg_Turnover[nrow(turns)],
    "x/year -- a candidate for safety-stock reduction or markdown strategy.\n")

# ---------------------------------------------------------------------------
# ANALYSIS 6: Warehouse capacity utilization -- who's over capacity?
# ---------------------------------------------------------------------------
section("ANALYSIS 6 -- Warehouse Utilization vs Capacity")
wh_util <- df %>% distinct(Warehouse, Warehouse_City, Warehouse_Region, Order_Year, Order_Month=substr(Order_Date,1,7), Warehouse_Utilization) %>%
  group_by(Warehouse, Warehouse_City, Warehouse_Region) %>%
  summarise(Avg_Utilization = round(mean(Warehouse_Utilization), 3),
            Peak_Utilization = round(max(Warehouse_Utilization), 3),
            Months_Over_Capacity = sum(Warehouse_Utilization > 1.0), .groups = "drop") %>%
  arrange(desc(Peak_Utilization))
print(wh_util)
worst_wh <- wh_util$Warehouse_City[1]
cat("\nBusiness Insight:", worst_wh, "peaks at", fmt_pct(wh_util$Peak_Utilization[1]),
    "of rated capacity and exceeds 100% in", wh_util$Months_Over_Capacity[1],
    "month(s) in the dataset -- almost always during the Nov/Dec demand surge.",
    "Overflow/3PL capacity should be pre-booked for peak season at this site.\n")

saveRDS(list(stock_dist=stock_dist, turns=turns, wh_util=wh_util), "../dataset/_inventory_results.rds")
