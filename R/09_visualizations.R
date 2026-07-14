# ============================================================================
# 09_visualizations.R -- Professional Chart Suite (ggplot2)
# ============================================================================
suppressPackageStartupMessages({ library(dplyr); library(ggplot2); library(reshape2) })
source("utils.R")
df <- read.csv(CLEAN_CSV, stringsAsFactors = FALSE) %>% mutate(Order_Date = as.Date(Order_Date))

# 01 -- Revenue & Profit by Category (business question: which categories matter most?)
cat_summary <- df %>% group_by(Category) %>% summarise(Revenue=sum(Revenue), Profit=sum(Profit)) %>%
  arrange(desc(Revenue))
p1 <- ggplot(cat_summary, aes(x=reorder(Category,Revenue), y=Revenue)) +
  geom_col(fill="#1F6FEB") +
  geom_col(aes(y=Profit), fill="#27AE60", width=0.5) +
  coord_flip() + scale_y_continuous(labels=dollar_format()) +
  labs(title="Revenue (blue) vs Profit (green) by Category", x=NULL, y="USD") + theme_scm()
save_chart(p1, "01_revenue_profit_by_category.png")

# 02 -- Monthly revenue trend with peak season shading
monthly <- df %>% mutate(YM = format(Order_Date,"%Y-%m")) %>%
  group_by(YM) %>% summarise(Revenue=sum(Revenue), .groups="drop")
monthly$YM_date <- as.Date(paste0(monthly$YM,"-01"))
p2 <- ggplot(monthly, aes(x=YM_date, y=Revenue)) +
  geom_line(color="#1F6FEB", linewidth=1) + geom_point(color="#1F6FEB", size=1.8) +
  scale_y_continuous(labels=dollar_format()) + scale_x_date(date_labels="%b %Y", date_breaks="3 months") +
  labs(title="Monthly Revenue Trend (2024-2025)", subtitle="Nov/Dec holiday peaks repeat both years",
       x=NULL, y="Revenue") + theme_scm() + theme(axis.text.x = element_text(angle=45, hjust=1))
save_chart(p2, "02_monthly_revenue_trend.png")

# 03 -- Warehouse utilization heatmap (Warehouse x Month)
wh_month <- df %>% distinct(Warehouse_City, Order_Date, Warehouse_Utilization) %>%
  mutate(YM = format(Order_Date,"%Y-%m")) %>% group_by(Warehouse_City, YM) %>%
  summarise(Utilization = mean(Warehouse_Utilization), .groups="drop")
p3 <- ggplot(wh_month, aes(x=YM, y=Warehouse_City, fill=Utilization)) +
  geom_tile(color="white", linewidth=0.3) +
  scale_fill_gradient2(low="#27AE60", mid="#F2C94C", high="#EB5757", midpoint=0.85, labels=percent_format()) +
  labs(title="Warehouse Capacity Utilization Heatmap", x=NULL, y=NULL, fill="Utilization") +
  theme_scm() + theme(axis.text.x = element_text(angle=90, hjust=1, size=8))
save_chart(p3, "03_warehouse_utilization_heatmap.png", width=11)

# 04 -- Stock status distribution
stock_dist <- df %>% count(Stock_Status) %>% mutate(Pct = n/sum(n))
p4 <- ggplot(stock_dist, aes(x="", y=n, fill=Stock_Status)) +
  geom_col(width=1, color="white") + coord_polar("y") +
  scale_fill_manual(values=c("In Stock"="#27AE60","Low Stock"="#F2C94C","Overstocked"="#2D9CDB","Stock-Out"="#EB5757")) +
  labs(title="Inventory Stock Status Distribution", fill=NULL) +
  theme_void(base_size=12) + theme(plot.title = element_text(face="bold", hjust=0.5))
save_chart(p4, "04_stock_status_distribution.png")

# 05 -- Profit distribution (histogram) -- shows the unprofitable-order tail
p5 <- ggplot(df, aes(x=Profit)) +
  geom_histogram(bins=60, fill="#1F6FEB", alpha=0.85) +
  geom_vline(xintercept=0, color="#EB5757", linetype="dashed", linewidth=0.8) +
  scale_x_continuous(labels=dollar_format(), limits=c(-1000,2000)) +
  labs(title="Order-Level Profit Distribution", subtitle="Dashed line = breakeven",
       x="Profit per Order", y="Order Count") + theme_scm()
save_chart(p5, "05_profit_distribution.png")

# 06 -- Supplier on-time rate vs customer satisfaction (correlation from Analysis 11)
sup_rel <- df %>% group_by(Supplier_ID) %>%
  summarise(On_Time_Rate = 1-mean(Late_Delivery), Avg_Satisfaction = mean(Customer_Satisfaction,na.rm=TRUE),
            Orders = n(), .groups="drop") %>% filter(Orders >= 20, !is.na(Avg_Satisfaction))
p6 <- ggplot(sup_rel, aes(x=On_Time_Rate, y=Avg_Satisfaction)) +
  geom_point(color="#1F6FEB", size=2.5, alpha=0.75) +
  geom_smooth(method="lm", se=TRUE, color="#EB5757", fill="#EB5757", alpha=0.15) +
  scale_x_continuous(labels=percent_format()) +
  labs(title="Supplier On-Time Rate vs Customer Satisfaction", subtitle="r = 0.82 (see 06_supplier_analysis.R)",
       x="On-Time Delivery Rate", y="Avg Customer Satisfaction (1-5)") + theme_scm()
save_chart(p6, "06_supplier_ontime_vs_satisfaction.png")

cat("\nAll 6 core visualizations saved to images/charts/ (plus 4 more generated inline by",
    "05_demand_forecasting.R and 07_transportation_analysis.R -- 10 charts total).\n")
