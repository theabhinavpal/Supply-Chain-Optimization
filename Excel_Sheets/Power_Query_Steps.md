# Power Query & Excel Workflow Notes

The four workbooks in this folder were built programmatically (via `openpyxl`) so that every KPI and
cross-tab is a live formula against a full embedded dataset, and so the whole set is reproducible from
`dataset/Supply_Chain_Data_Clean.csv` in one script run. This document describes the equivalent manual
workflow in real Excel + Power Query, for two reasons: it's the more realistic day-to-day workflow in
most analyst roles, and it's a good interview walkthrough of the same logic.

## 1. Importing & shaping the data (Power Query)

1. `Data` tab → `Get Data` → `From Text/CSV` → select `dataset/Supply_Chain_Data_Clean.csv`
2. In the Power Query Editor:
   - Confirm data types per column (Power Query usually infers correctly, but double-check `Order_Date`
     is `Date`, `Late_Delivery` is `Boolean`, and cost/revenue fields are `Decimal Number`)
   - `Add Column → Custom Column` for any derived field not already in the clean CSV (most are already
     present, since `r/02_data_cleaning.R` does this work)
   - `Close & Load To...` → **PivotTable Report** (this loads the data into the Excel Data Model rather
     than a plain worksheet, which scales much better than 12,000 rows in a raw sheet + volatile
     formulas)

## 2. Building native PivotTables (in place of `Pivot_Tables.xlsx`)

1. With the query loaded to the Data Model, `Insert → PivotTable → Use this workbook's Data Model`
2. Drag `Category` to **Rows**, `Order_Quarter` to **Columns**, `Revenue` to **Values** (summarized as
   Sum) → reproduces the `Category_x_Quarter` sheet as a live, refreshable PivotTable
3. Repeat with `Supplier_Name` in Rows and `Revenue`/`Profit`/`Late_Delivery` in Values (the latter
   summarized as Average, after converting TRUE/FALSE to 1/0 via a calculated column) to reproduce
   `Supplier_Performance`
4. `Insert → Slicer` → choose `Warehouse_Region`, `Transportation_Mode`, and `Customer_Tier` for
   interactive filtering across all PivotTables at once (`Report Connections` lets one slicer drive
   multiple PivotTables)
5. Right-click any value cell → `Show Values As → % of Grand Total` for a quick mix/share view without
   an extra formula

## 3. Building the Executive Dashboard (in place of `Supply_Chain_Dashboard.xlsx`)

1. Add PivotCharts directly from the PivotTables above (`PivotTable Analyze → PivotChart`)
2. For the KPI cards: link cells directly to `GETPIVOTDATA()` formulas pointing at the PivotTable
   totals, rather than separate `SUMIFS` formulas — this keeps everything driven from the same Data
   Model refresh
3. Conditional formatting for the warehouse utilization table: `Home → Conditional Formatting →
   Color Scales`, 3-color scale, midpoint set to a fixed value of 0.9 (90% capacity) so the color
   ramp is centered on the point that actually matters operationally, not just min/max of the data
4. `Data → Queries & Connections → Properties → Refresh every N minutes` (or `Refresh on Open`) if
   this were wired to a live source instead of a static CSV

## 4. Refreshing everything after a data update

With the Power Query approach: replace the source CSV, then `Data → Refresh All` — every PivotTable,
PivotChart, and KPI cell recalculates automatically since they all point back to the same query.

With this repo's formula-driven approach: re-run `r/02_data_cleaning.R` to regenerate
`Supply_Chain_Data_Clean.csv`, then re-run the Excel build script — the `SUMIFS`/`COUNTIFS`/`AVERAGEIFS`
formulas recalculate against the refreshed `Data` sheet the same way.

## Why this repo didn't ship native PivotTable objects

Native PivotTable XML embeds a *cache* of the source data separate from the visible sheet, which
`openpyxl` has only partial, version-sensitive support for writing programmatically — a
programmatically-generated PivotTable cache is a common source of "opens fine in one Excel version,
corrupts in another" bugs. Shipping transparent `SUMIFS`-based cross-tabs instead guarantees the
workbook opens correctly and recalculates correctly in any Excel/LibreOffice version, at the cost of
losing drag-and-drop interactivity — a deliberate reliability-over-polish trade-off for a portfolio
deliverable that needs to just work when someone else opens it.
