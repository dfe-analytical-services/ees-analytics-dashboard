message("Loading dependencies...")
shhh <- suppressPackageStartupMessages # It's a library, so shhh!

# Standard app styling
shhh(library(shiny))
shhh(library(bslib))
shhh(library(shinyGovstyle))
shhh(library(bsicons))
shhh(library(shinycssloaders))

# Database connection
shhh(library(odbc))
shhh(library(pool))
shhh(library(dbplyr))

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
shhh(library(reactable))
shhh(library(tidyr))

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

message("...library calls done...")

# Database connection =========================================================
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
  yesterday <- as.Date("2024-08-08")
} else {
  yesterday <- Sys.Date() - 1
}

date_options <- list(
  "Last four weeks" = yesterday - 28,
  "Since 2nd Sept" = as.Date("2024-09-02"),
  "Last year" = yesterday - 365,
  "All time" = as.Date("2020-04-03")
)

options(
  spinner.type = 7,
  spinner.color = afcharts::af_colour_values[["dark-blue"]],
  spinner.proxy.height = "30px"
)

# TODO: Cache to temporary place on disk, should make sure it is
# - wiped out with each deploy on server
# - wiped out easily when developing locally
# shinyOptions(cache = cachem::cache_disk(file.path(getwd(), "ees-analytics-cache")))
# Wipe cache when running global.R


# Custom functions ============================================================
lapply(paste0("R/", list.files("R/", recursive = TRUE)), source)

message("...global variables set!")
