# Quick script to make the test files
# Library calls ===============================================================
library(dbplyr)
library(dplyr)
library(odbc)
library(pool)

# Connect to database =========================================================
config <- config::get("db_connection")

pool <- pool::dbPool(
  drv = odbc::databricks(),
  httpPath = config$sql_warehouse_id
)

# List out data sets ==========================================================
datasets <- c(
  "ees_service_summary"
)

# Load source data ============================================================
pull_from_database <- function(table_name) {
  pool |>
    dplyr::tbl(
      DBI::Id(
        catalog = config$catalog,
        schema = config$schema,
        table = table_name
      )
    )
}

# Filter and write out data sets ==============================================
datasets <- lapply(datasets, function(x) {
  message("Processing ", x)

  pull_from_database(x) |>
    filter(date >= "2024-08-01" & date <= "2024-08-08") |>
    collect() |>
    arrow::write_dataset(
      "tests/testdata/",
      format = "parquet",
      basename_template = paste0(x, "_{i}.parquet")
    )
})

# Close the pool connection ===================================================
pool::poolClose(pool)

# Create a last updated date file =============================================
last_updated_table <- data.frame(
  last_updated = "2024-08-08 19:17:42.666",
  latest_data = "2024-08-08"
)

arrow::write_dataset(
  last_updated_table,
  "tests/testdata/",
  format = "parquet",
  basename_template = "ees__last_updated_{i}.parquet"
)
