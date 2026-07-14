# Screenshots

This repo ships the real, working Excel workbooks (`excel/*.xlsx`) and the real generated PNG charts
(`images/charts/*.png`), so the underlying artifacts are already here and don't require a screenshot
substitute to evaluate.

If you're presenting this project (e.g. in a portfolio site or a slide deck) rather than pointing
someone at the repo directly, a few screenshots make it more skimmable:

- [ ] `images/dashboard/executive_dashboard.png` — Excel → `Supply_Chain_Dashboard.xlsx` →
      Executive Dashboard tab → screenshot the KPI cards + both charts
- [ ] `images/dashboard/kpi_scorecard.png` — `KPIs.xlsx` → KPI Scorecard tab
- [ ] `images/dashboard/supplier_scorecard.png` — `Reports.xlsx` → Supplier_Scorecard tab (shows the
      conditional-formatted A-F grading)
- [ ] `images/dashboard/warehouse_heatmap.png` — already generated as
      `images/charts/03_warehouse_utilization_heatmap.png`, no manual screenshot needed

The `images/dashboard/` folder is intentionally left empty in this repo (screenshots are
environment/OS-specific and go stale the moment a workbook is edited) — regenerate them from the live
workbooks above whenever the data or dashboard changes.
