# Requirements

## R (4.x)

Install via CRAN, or on Ubuntu/Debian via apt (used to build this project, since it doesn't require
reaching CRAN directly):

```bash
sudo apt install r-base-core \
  r-cran-tidyverse r-cran-dplyr r-cran-tidyr r-cran-readr r-cran-ggplot2 \
  r-cran-lubridate r-cran-forecast r-cran-plotly r-cran-caret r-cran-reshape2 \
  r-cran-stringr r-cran-scales r-cran-readxl r-cran-openxlsx r-cran-rsqlite
```

Or, from an R console with CRAN access:

```r
install.packages(c("tidyverse","dplyr","tidyr","readr","ggplot2","lubridate",
                    "forecast","plotly","caret","reshape2","stringr","janitor",
                    "scales","readxl","openxlsx","DBI","RSQLite"))
```

> Note: `janitor` is not available via apt in a minimal Ubuntu environment. `r/utils.R` ships a small
> `clean_names()` replacement so the project runs without it; if you have CRAN access, installing the
> real `janitor` package is a drop-in swap.

## Excel

Excel 2016+ (for native `MAXIFS`/`MINIFS` support used in a couple of dashboard formulas) or
LibreOffice Calc 7.x+. All four workbooks in `excel/` were built and formula-verified against
LibreOffice Calc 24.2.

## Optional (dataset generation only)

The synthetic dataset in `dataset/` was generated with Python 3.12 + `pandas`/`numpy`. You do not
need Python to run any part of the analysis — it's only relevant if you want to regenerate the raw
dataset from scratch with different parameters. See `reports/Data_Dictionary.md` for the generation
methodology.

## Disk / runtime

- Dataset: ~12,000 rows, ~5 MB as CSV
- Full R pipeline (01 → 10): under 2 minutes on a single core
- Excel workbooks: ~1.6 MB each (they each embed the full cleaned dataset as their `Data` sheet so
  every formula is self-contained and portable)
