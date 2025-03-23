# Quick script to make the test files
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# You need access to the database and your local .Renviron file set up first
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
start <- Sys.time()
# Library calls ===============================================================
pkgs <- c("odbc", "pool", "dplyr", "duckplyr")

for (pkg in pkgs) {
  shhh(library(pkg, character.only = TRUE))
}

# List out data sets ==========================================================
datasets <- c(
  "ees_service_summary", "ees_release_pageviews"
)

# Connect to database =========================================================
config <- config::get("db_connection")

pool <- pool::dbPool(
  drv = odbc::databricks(),
  httpPath = config$sql_warehouse_id
)

# Function to load source data ================================================
pull_from_database <- function(table_name) {
  pool |>
    dplyr::tbl(
      DBI::Id(
        catalog = config$catalog,
        schema = config$schema,
        table = table_name
      )
    ) |>
    filter(date >= "2024-08-01" & date <= "2024-08-08") |>
    collect()
}

# Load, filter and write out data sets ========================================
datasets <- lapply(datasets, function(x) {
  message("Processing ", x)

  pull_from_database(x) |>
    duckplyr::compute_parquet(
      paste0("tests/testdata/", x, ".parquet")
    )
})

# Close the pool connection ===================================================
pool::poolClose(pool)

# Create a last updated date file =============================================
invisible({ # just to suppress the console output
  duckplyr::compute_parquet(
    duckplyr::duckdb_tibble(
      last_updated = "2024-08-08 19:17:42.666",
      latest_data = "2024-08-08"
    ),
    "tests/testdata/ees__last_updated.parquet"
  )
})

# Report time =================================================================
end <- Sys.time()
message("Generating test files took ", dfeR::pretty_time_taken(start, end))
