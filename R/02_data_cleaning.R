# ============================================================================
# 02_data_cleaning.R -- Clean the raw export into an analysis-ready dataset
# ============================================================================
# Every fix below is documented with WHY it was made. Output: 
#   ../dataset/Supply_Chain_Data_Clean.csv  (analysis-ready)
#   ../dataset/supply_chain.db              (SQLite -- used to test queries)
# ============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(stringr); library(lubridate); library(DBI); library(RSQLite)
})
source("utils.R")

raw <- readRDS("../dataset/_raw_cache.rds")
n_start <- nrow(raw)

section("STEP 1 -- Remove duplicate rows")
# WHY: 82 rows are byte-for-byte duplicates -- consistent with the order system
# double-logging a row on retry. Keeping them would double-count revenue/profit.
df <- raw %>% distinct()
cat("Removed", n_start - nrow(df), "exact duplicate rows ->", nrow(df), "rows remain\n")
# A naive distinct() only catches FULL-row equality. Some duplicate pairs share
# the same Order_ID (the real business key) but differ on one field because a
# missing-value flag landed on only one copy -- those survive distinct() and
# would still double-count revenue. Dedupe on Order_ID, keeping the row with
# fewer NAs (the more complete record).
dup_ids_before <- sum(duplicated(df$Order_ID))
df <- df %>%
  mutate(.na_count = rowSums(is.na(.))) %>%
  arrange(Order_ID, .na_count) %>%
  distinct(Order_ID, .keep_all = TRUE) %>%
  select(-.na_count)
cat("Removed", dup_ids_before, "additional rows sharing a duplicate Order_ID ->", nrow(df), "rows remain\n")

section("STEP 2 -- Standardize text fields (Category, Transportation_Mode, Warehouse_Region)")
# WHY: source systems exported these with inconsistent casing/whitespace
# ("  electronics ", "ELECTRONICS", "Electronics" should all be one value).
df <- df %>% mutate(
  Category             = str_to_title(str_trim(Category)),
  Transportation_Mode  = str_to_title(str_trim(Transportation_Mode)),
  Warehouse_Region      = str_to_title(str_trim(Warehouse_Region))
)
cat("Distinct Category values after cleaning:", length(unique(df$Category)), "\n")
cat("Distinct Transportation_Mode values after cleaning:", length(unique(df$Transportation_Mode)), "\n")

section("STEP 3 -- Fix data type / date format issues")
# WHY: a subset of Order_Date values were exported as MM/DD/YYYY instead of
# ISO YYYY-MM-DD (a classic symptom of a batch coming from a different export job).
parse_mixed_date <- function(x) {
  iso <- suppressWarnings(ymd(x))
  us  <- suppressWarnings(mdy(x))
  coalesce(iso, us)
}
df <- df %>% mutate(
  Order_Date = parse_mixed_date(Order_Date),
  Ship_Date = ymd(Ship_Date),
  Delivery_Date = ymd(Delivery_Date),
  Promised_Delivery_Date = ymd(Promised_Delivery_Date)
)
cat("Unparseable Order_Date after fix:", sum(is.na(df$Order_Date)), "\n")

section("STEP 4 -- Correct invalid numeric records")
# WHY: 25 rows have a negative Quantity_Ordered (keying sign error --
# a legitimate return would instead show up as Order_Status == 'Returned').
# We take the absolute value rather than dropping the row, since every other
# field on those rows is valid and dropping would lose real revenue history.
neg_qty <- sum(df$Quantity_Ordered < 0)
df <- df %>% mutate(Quantity_Ordered = abs(Quantity_Ordered))
cat("Corrected", neg_qty, "negative Quantity_Ordered values (sign error)\n")

# WHY: 15 rows have Selling_Price == 0, which is not a real price (even
# heavily promoted SKUs have a floor). We impute using the product's median
# selling price elsewhere in the data rather than dropping the transaction.
zero_price <- sum(df$Selling_Price == 0)
med_price_by_product <- df %>% filter(Selling_Price > 0) %>%
  group_by(Product_ID) %>% summarise(med_price = median(Selling_Price), .groups = "drop")
df <- df %>% left_join(med_price_by_product, by = "Product_ID") %>%
  mutate(Selling_Price = if_else(Selling_Price == 0, med_price, Selling_Price)) %>%
  select(-med_price)
# Revenue/Profit must be recomputed for the rows we just fixed
df <- df %>% mutate(
  Revenue = round(Selling_Price * Quantity_Shipped, 2),
  Profit  = round(Revenue - Supplier_Unit_Cost * Quantity_Shipped - Shipping_Cost, 2)
)
cat("Imputed", zero_price, "zero-price rows using product median price; Revenue/Profit recomputed\n")

section("STEP 5 -- Handle missing values")
# WHY: Ship_Date/Delivery_Date are genuinely NA for Cancelled orders (never
# shipped) -- that's not missing data, that's a correct business state, so we
# leave those as NA rather than imputing a fake date.
cat("NA Ship_Date on Cancelled orders (expected, left as-is):",
    sum(is.na(df$Ship_Date) & df$Order_Status == "Cancelled"), "\n")

# WHY: Customer_Satisfaction is missing for ~1.8% of rows (survey not
# returned). We flag it rather than imputing a fabricated satisfaction score,
# since imputing sentiment data would bias downstream satisfaction analysis.
df <- df %>% mutate(Satisfaction_Missing = is.na(Customer_Satisfaction))
cat("Flagged", sum(df$Satisfaction_Missing), "rows with missing Customer_Satisfaction (kept as NA, not imputed)\n")

# WHY: Lead_Time_Days missing (~1%) -- impute with the supplier's median lead
# time, since lead time is a supplier-level characteristic, not random noise.
med_lead_by_supplier <- df %>% filter(!is.na(Lead_Time_Days)) %>%
  group_by(Supplier_ID) %>% summarise(med_lt = median(Lead_Time_Days), .groups = "drop")
n_na_lead <- sum(is.na(df$Lead_Time_Days))
df <- df %>% left_join(med_lead_by_supplier, by = "Supplier_ID") %>%
  mutate(Lead_Time_Days = if_else(is.na(Lead_Time_Days), med_lt, Lead_Time_Days)) %>%
  select(-med_lt)
cat("Imputed", n_na_lead, "missing Lead_Time_Days using each supplier's median lead time\n")

section("STEP 6 -- Feature engineering")
df <- df %>% mutate(
  Late_Delivery = Late_Delivery %in% c("True", "TRUE", "true"),
  Order_Year = year(Order_Date),
  Order_Month = month(Order_Date),
  Order_Quarter = paste0("Q", quarter(Order_Date)),
  Delivery_Delay_Days = as.numeric(Delivery_Date - Promised_Delivery_Date),
  Fulfillment_Rate = round(Quantity_Shipped / pmax(Quantity_Ordered, 1), 3),
  Profit_Margin = if_else(Revenue > 0, round(Profit / Revenue, 3), NA_real_),
  Is_Peak_Season = Order_Month %in% c(11, 12)
)
cat("Added: Delivery_Delay_Days, Fulfillment_Rate, Profit_Margin, Is_Peak_Season\n")

section("STEP 7 -- Validation rules")
validation <- tibble(
  rule = c("Quantity_Shipped <= Quantity_Ordered", "Revenue >= 0", "No duplicate Order_ID",
           "Ship_Date >= Order_Date (where present)", "Selling_Price > 0"),
  passed = c(
    all(df$Quantity_Shipped <= df$Quantity_Ordered),
    all(df$Revenue >= 0),
    !any(duplicated(df$Order_ID)),
    all(df$Ship_Date >= df$Order_Date, na.rm = TRUE),
    all(df$Selling_Price > 0)
  )
)
print(validation)
stopifnot(all(validation$passed))
cat("\nAll validation rules PASSED.\n")

section("SAVE CLEANED DATASET")
write.csv(df, CLEAN_CSV, row.names = FALSE)
cat("Wrote", nrow(df), "rows x", ncol(df), "cols ->", CLEAN_CSV, "\n")
cat("Net rows removed (dupes only):", n_start - nrow(df), "\n")

section("LOAD INTO SQLITE (real DB, used to test queries in later scripts)")
con <- dbConnect(SQLite(), DB_PATH)
dbWriteTable(con, "orders", df, overwrite = TRUE)
dbExecute(con, "CREATE INDEX idx_product ON orders(Product_ID)")
dbExecute(con, "CREATE INDEX idx_supplier ON orders(Supplier_ID)")
dbExecute(con, "CREATE INDEX idx_warehouse ON orders(Warehouse)")
dbExecute(con, "CREATE INDEX idx_date ON orders(Order_Date)")

test1 <- dbGetQuery(con, "SELECT COUNT(*) AS n_rows FROM orders")
test2 <- dbGetQuery(con, "SELECT Category, ROUND(SUM(Revenue),0) AS revenue
                           FROM orders GROUP BY Category ORDER BY revenue DESC LIMIT 3")
cat("DB row count check:", test1$n_rows, "\n")
cat("Top 3 categories by revenue (queried live from SQLite):\n")
print(test2)
dbDisconnect(con)
cat("\nsupply_chain.db written and query-tested successfully.\n")
