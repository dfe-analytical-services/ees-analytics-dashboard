message("Loading dependencies...")
shhh <- suppressPackageStartupMessages # It's a library, so shhh!

# Standard app styling
shhh(library(shiny))
shhh(library(bslib))
shhh(library(bsicons))

# Database connection
shhh(library(odbc))
shhh(library(pool))

# Data processing
shhh(library(dplyr))
shhh(library(duckplyr)) # loading this after dplyr to overwrite verbs

# Specific type manipulation
shhh(library(dfeR))
shhh(library(stringr))
shhh(library(lubridate))

# Data vis
shhh(library(ggplot2))
shhh(library(afcharts))
shhh(library(scales))
shhh(library(ggiraph))

# Pre-commit hooks and CI
# We don't need the app to load these, they're just here for renv to track so
# developers have them available locally
if ("meaning of life" == "42") {
  library(lintr)
  library(styler)
  library(git2r)
  library(rsconnect)
  library(shinytest2)
  # we should never run library(config)
  # their own docs recommend only calling using config::
  # this is due to function / namespace clashes and masking
  library(config)
}

message("...library calls done, setting up database connection...")

# Load data ====================================================================
if (Sys.getenv("TESTTHAT") == "") {
  message("Connecting to SQL warehouse...")
  config <- config::get("db_connection")

  pool <- pool::dbPool(
    drv = odbc::databricks(),
    httpPath = config$sql_warehouse_id
  )

  # This will close the pool cleanly whenever the app is stopped
  onStop(function() {
    pool::poolClose(pool)
  })

  message("...connected!")
}

# Global variables ============================================================
if (Sys.getenv("TESTTHAT") == "true") {
  latest_date <- as.Date("2024-08-08")
} else {
  latest_date <- Sys.Date() - 1
}

week_date <- latest_date - 7
four_week_date <- latest_date - 28
since_4thsep_date <- "2024-09-02"
six_month_date <- latest_date - 183
one_year_date <- latest_date - 365
all_time_date <- "2020-04-03"

# Custom functions ============================================================
lapply(paste0("R/", list.files("R/", recursive = TRUE)), source)

message("...global variables set!")
