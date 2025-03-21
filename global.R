message("Loading dependencies...")
shhh <- suppressPackageStartupMessages # It's a library, so shhh!

# Standard app styling
shhh(library(bslib))
shhh(library(shiny))
shhh(library(bsicons))
shhh(library(shinyWidgets))

# Data processing
shhh(library(duckplyr))
shhh(library(lubridate))
shhh(library(dplyr))
shhh(library(stringr))
shhh(library(tibble))
shhh(library(data.table))
shhh(library(mgsub))
shhh(library(tidyr))
shhh(library(DT))
shhh(library(snakecase))
shhh(library(janitor))
shhh(library(readr))
shhh(library(anytime))
shhh(library(arrow))
shhh(library(dfeR))

# Database connection
shhh(library(dbplyr))
shhh(library(odbc))
shhh(library(pool))

# Data vis
shhh(library(plotly))

# Pre-commit hooks and CI
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
  config <- config::get("db_connection")

  pool <- pool::dbPool(
    drv = odbc::databricks(),
    httpPath = config$sql_warehouse_id
  )

  onStop(function() {
    pool::poolClose(pool)
  })

  message("...connected to database...")
}

# Global variables ============================================================
link_guidance <- tags$a(
  img(
    src = "Fred.png",
    width = "30",
    height = "30"
  ),
  "Guidance",
  href = paste0(
    "https://dfe-analytical-services.github.io/analysts-guide/",
    "statistics-production/user-analytics.html"
  ),
  target = "_blank"
)

link_shiny <- tags$a(
  shiny::icon("github"),
  "Shiny",
  href = "https://github.com/rstudio/shiny", target = "_blank"
)
link_posit <- tags$a(
  shiny::icon("r-project"), "Posit",
  href = "https://posit.co", target = "_blank"
)

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
