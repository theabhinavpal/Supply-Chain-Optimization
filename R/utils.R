# ============================================================================
# utils.R -- Shared helper functions for the Supply Chain Optimization project
# ============================================================================
# Sourced by every script in this folder. Centralizes formatting, theming,
# and small utilities so the analysis scripts stay focused on business logic.
# ============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(scales)
  library(ggplot2)
})

# ---- Paths -------------------------------------------------------------
RAW_CSV    <- "../dataset/Supply_Chain_Data.csv"
CLEAN_CSV  <- "../dataset/Supply_Chain_Data_Clean.csv"
DB_PATH    <- "../dataset/supply_chain.db"
CHART_DIR  <- "../images/charts"

# ---- clean_names(): lightweight janitor::clean_names() replacement -----
# (janitor isn't in Ubuntu's apt mirror and CRAN isn't reachable in this
#  sandboxed environment, so we reimplement the one function we need)
clean_names <- function(df) {
  names(df) <- names(df) |>
    str_trim() |>
    str_replace_all("[^A-Za-z0-9]+", "_") |>
    str_replace_all("_+", "_") |>
    str_replace_all("^_|_$", "") |>
    tolower()
  df
}

# ---- Consistent professional ggplot theme -------------------------------
theme_scm <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 3, color = "#1F2A44"),
      plot.subtitle = element_text(color = "#5B6B85", size = base_size - 1),
      axis.title = element_text(color = "#3A445C", face = "bold"),
      axis.text = element_text(color = "#3A445C"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#E7EAF1"),
      legend.title = element_text(face = "bold"),
      plot.caption = element_text(color = "#8792A8", size = base_size - 3),
      strip.text = element_text(face = "bold", color = "#1F2A44")
    )
}

scm_palette <- c("#1F6FEB","#F2994A","#27AE60","#EB5757","#9B51E0","#2D9CDB","#F2C94C","#6E7A94")

fmt_usd  <- function(x) dollar(x, accuracy = 1, scale = 1)
fmt_usd_k <- function(x) dollar(x/1000, accuracy = 0.1, suffix = "K")
fmt_pct  <- function(x) percent(x, accuracy = 0.1)

save_chart <- function(plot, filename, width = 9, height = 5.5, dpi = 150) {
  if (!dir.exists(CHART_DIR)) dir.create(CHART_DIR, recursive = TRUE)
  ggsave(file.path(CHART_DIR, filename), plot = plot, width = width, height = height, dpi = dpi, bg = "white")
  message("Saved chart: ", filename)
}

# ---- MAPE / MAE / RMSE for forecast evaluation --------------------------
mape <- function(actual, forecast) mean(abs((actual - forecast) / pmax(actual, 1))) * 100
mae  <- function(actual, forecast) mean(abs(actual - forecast))
rmse <- function(actual, forecast) sqrt(mean((actual - forecast)^2))

section <- function(title) {
  cat("\n", strrep("=", 78), "\n", sep = "")
  cat(title, "\n")
  cat(strrep("=", 78), "\n")
}
