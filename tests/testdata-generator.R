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

# Custom functions ============================================================
pull_filtered_data <- function(table_name, pool, config) {
  message("Generating ", table_name, "...")

  pool |>
    dplyr::tbl(
      DBI::Id(
        catalog = config$catalog,
        schema = config$schema,
        table = table_name
      )
    ) |>
    dplyr::filter(date >= "2024-08-01" & date <= "2024-08-08") |>
    dplyr::collect() |>
    duckplyr::compute_parquet(
      paste0("tests/testdata/", table_name, ".parquet")
    )

  message("... ", table_name, " generated!")
}

create_last_updated <- function() {
  message("Generating _last_updated...")

  duckplyr::compute_parquet(
    duckplyr::duckdb_tibble(
      last_updated = "2024-08-08 19:17:42.666",
      latest_data = "2024-08-08"
    ),
    "tests/testdata/ees__last_updated.parquet"
  )

  message("... _last_updated generated!")
}

# Execute =====================================================================
datasets <- c(
  "ees_service_summary", "ees_release_pageviews"
)

config <- config::get("db_connection")

pool <- pool::dbPool(
  drv = odbc::databricks(),
  httpPath = config$sql_warehouse_id
)

lapply(datasets, pull_filtered_data, pool, config)

pool::poolClose(pool)

create_last_updated()

# Report time =================================================================
end <- Sys.time()
message("Generating test files took ", dfeR::pretty_time_taken(start, end))
