# ============================================================================
# 01_data_loading.R -- Load and profile the raw supply chain export
# ============================================================================
# Business question: What does the raw data actually look like, and what
# needs to be fixed before it's trustworthy for analysis?
# ============================================================================

# NOTE: run all scripts with the working directory set to r/, e.g.
#   cd r && Rscript 01_data_loading.R
suppressPackageStartupMessages(library(dplyr))
source("utils.R")

section("LOADING RAW DATA")
raw <- read.csv(RAW_CSV, stringsAsFactors = FALSE)
cat("Rows:", nrow(raw), " | Columns:", ncol(raw), "\n")

section("STRUCTURE")
str(raw, list.len = 15)

section("MISSING VALUES BY COLUMN (top 10)")
missing_report <- sort(colSums(is.na(raw)), decreasing = TRUE)
print(head(missing_report, 10))

section("DUPLICATE ROWS")
cat("Exact duplicate rows:", sum(duplicated(raw)), "\n")

section("DATA QUALITY FLAGS")
cat("Negative Quantity_Ordered:", sum(raw$Quantity_Ordered < 0, na.rm = TRUE), "\n")
cat("Zero Selling_Price:", sum(raw$Selling_Price == 0, na.rm = TRUE), "\n")
cat("Distinct raw Category text values:", length(unique(raw$Category)), " (should be 8 after cleaning)\n")
cat("Distinct raw Transportation_Mode text values:", length(unique(raw$Transportation_Mode)), " (should be 5 after cleaning)\n")
cat("Distinct raw Order_Date formats present -- sample:\n")
print(head(unique(raw$Order_Date), 6))

section("SUMMARY (numeric columns)")
print(summary(select(raw, Quantity_Ordered, Revenue, Profit, Lead_Time_Days, Customer_Satisfaction)))

saveRDS(raw, "../dataset/_raw_cache.rds")
cat("\nRaw data cached for 02_data_cleaning.R\n")
