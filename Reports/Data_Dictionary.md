# Data Dictionary

`dataset/Supply_Chain_Data_Clean.csv` — 12,000 rows, one row per order line, Jan 2024 - Dec 2025.

| Field | Type | Business Relevance |
|---|---|---|
| `Order_ID` | text | Unique order-line identifier |
| `Order_Date` | date | When the order was placed — drives all seasonality analysis |
| `Order_Year` / `Order_Quarter` / `Order_Month` | derived | Convenience fields for grouping |
| `Product_ID` / `Product_Name` / `Category` | text | What was ordered (150 SKUs across 8 categories) |
| `Supplier_ID` / `Supplier_Name` | text | Who supplied the product (40 suppliers, 1-2 per product) |
| `Warehouse` / `Warehouse_City` / `Warehouse_Region` / `Warehouse_Country` | text | Fulfillment location (8 warehouses) |
| `Warehouse_Capacity` | integer | Rated unit capacity of the fulfilling warehouse |
| `Warehouse_Utilization` | decimal | That warehouse's inventory-to-capacity ratio for the order's month — the core input to the warehouse capacity-planning analysis |
| `Customer_ID` / `Customer_Region` / `Customer_Tier` | text | Who ordered. `Customer_Tier` (`Key Account` / `Standard`) reflects the Pareto concentration built into the data — the top 20% of customers by rank drive a disproportionate share of order volume |
| `Quantity_Ordered` / `Quantity_Shipped` | integer | Demand vs. actual fulfillment — the gap is driven by stock position |
| `Inventory_Level` / `Reorder_Point` / `Safety_Stock` | integer | Product x Warehouse x Month inventory position, derived from realized demand and its volatility |
| `Stock_Status` | text | `In Stock` / `Low Stock` / `Overstocked` / `Stock-Out`, derived from the three fields above |
| `Demand_Forecast` | integer | A simulated monthly demand forecast for that Product x Warehouse, with realistic forecast error (worse during seasonally-boosted months) — the basis of the forecast-accuracy analysis |
| `Inventory_Turnover` | decimal | Annualized COGS / average inventory value, computed per product across the whole network |
| `Lead_Time_Days` | integer | Days from order to ship, driven by the assigned supplier's typical lead time |
| `Ship_Date` / `Delivery_Date` / `Promised_Delivery_Date` | date | Actual vs. promised fulfillment timeline |
| `Late_Delivery` | boolean | `Delivery_Date > Promised_Delivery_Date` |
| `Transportation_Mode` | text | Road / Rail / Air / Sea / Parcel — chosen probabilistically based on distance, shipment weight, and domestic vs. international routing |
| `Transportation_Distance_KM` | decimal | Warehouse-to-customer-region distance |
| `Shipping_Cost` / `Fuel_Cost` | decimal | Freight cost, modeled as fixed fee + per-kg rate + per-km rate (mode-specific) |
| `Supplier_Unit_Cost` | decimal | What the business pays the supplier per unit |
| `Selling_Price` | decimal | What the customer pays per unit (reflects category margin bands and occasional Nov/Dec promotional discounting) |
| `Revenue` / `Profit` | decimal | `Selling_Price × Quantity_Shipped`, and `Revenue − Supplier_Unit_Cost×Qty − Shipping_Cost` |
| `Profit_Margin` | decimal | `Profit / Revenue` for the order line |
| `Order_Status` | text | Delivered / Returned / Cancelled |
| `Product_Return_Rate` | decimal | That product's overall return rate across the dataset |
| `Customer_Satisfaction` | decimal (1-5) | Simulated satisfaction score, penalized by late delivery, returns, and partial shipment |
| `Fulfillment_Rate` | decimal | `Quantity_Shipped / Quantity_Ordered` |
| `Delivery_Delay_Days` | integer | `Delivery_Date − Promised_Delivery_Date` |
| `Is_Peak_Season` | boolean | `Order_Month` in {11, 12} |
| `Satisfaction_Missing` | boolean | Flags rows where satisfaction was genuinely not captured (kept as `NA`, not imputed — see `r/02_data_cleaning.R`) |

## How the data was generated (and why it's realistic, not random)

The dataset is synthetic but built with the same structural assumptions a real retail/distribution
business exhibits, so that analysis performed on it produces genuine, non-trivial findings rather than
noise:

- **Seasonality**: monthly order-volume weights peak in Nov/Dec (holiday) and Aug (back-to-school,
  concentrated in Office Supplies), with category-specific seasonal boosts layered on top (e.g. Toys &
  Games gets a much larger Nov/Dec multiplier than Health & Beauty).
- **Pareto concentration**: both customers and products are assigned a Zipf-distributed popularity
  weight, so a small share of customers/SKUs account for a disproportionate share of volume — exactly
  the pattern real order data shows.
- **Category margin bands**: each category draws its margin from a realistic, distinct range (e.g.
  Electronics 14-26%, Health & Beauty 42-66%), so category profitability differences in the analysis
  are structural, not accidental.
- **Supplier reliability profiles**: each of the 40 suppliers has its own on-time rate, lead time, and
  defect-rate distribution, which is what makes the supplier-performance and satisfaction-correlation
  analyses meaningful.
- **Freight economics**: shipping cost is modeled as `fixed fee + per-kg rate + per-km rate`, with
  mode-specific rates, so mode choice has real, non-arbitrary cost and speed trade-offs.
- **Inventory position**: safety stock and reorder points are derived from each Product x Warehouse's
  own realized demand and its volatility (not a flat rule), and inventory level is drawn from a mixture
  that produces a realistic mix of stock-out, low-stock, healthy, and overstocked positions.

The raw file (`dataset/Supply_Chain_Data.csv`) additionally has realistic data-quality issues injected
on top of this clean structure (duplicate rows, missing values, inconsistent text casing, a few keying
errors, mixed date formats) — see `reports/Project_Workflow.md` and `r/02_data_cleaning.R` for how each
one is detected and fixed.
