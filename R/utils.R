# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Filter table by date
#'
#' @param data table to filter, can be lazy or in memory
#' @param selected_start_date date to filter data from
filter_on_date <- function(data, selected_start_date) {
  first_date <- date_options[[selected_start_date]]

  data |>
    filter(date >= first_date)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Read in table
#'
#' This relies on already having a pool connection set up, or using the test
#' flag to read in local data from the repo.
#'
#' @param table_name name of table in delta lake / local test data
#' @param test_mode override flag that will load test data from repo
read_delta_lake <- function(table_name, test_mode = "") {
  if (test_mode == "true") {
    lazy_table <- duckplyr::read_parquet_duckdb(
      paste0("tests/testdata/", table_name, ".parquet")
    )
  } else {
    lazy_table <- pool |>
      dplyr::tbl(
        DBI::Id(
          catalog = config$catalog,
          schema = config$schema,
          table = table_name
        )
      ) |>
      duckplyr::as_duckdb_tibble()
  }

  return(lazy_table)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create headline aggregate total for value boxes
#'
#' @param data data set
#' @param metric metric to sum
aggregate_total <- function(data, metric) {
  data |>
    as.data.frame() |>
    summarise(sum(!!sym(metric))) |>
    dfeR::comma_sep() |>
    paste0()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create basic bar chart
#'
#' @param data data set
#' @param x x axis data
#' @param y y axis data
simple_bar_chart <- function(data, x, y) {
  x_var <- as.character(rlang::as_name(x))
  y_var <- as.character(rlang::as_name(y))

  p <- data |>
    ggplot(aes(x = !!sym(x), y = !!sym(y))) +
    geom_col_interactive(
      aes(
        data_id = seq_along(!!sym(x)),
        tooltip = paste0(
          x_var, ": ", !!sym(x), "\n", y_var, ": ", scales::comma(!!sym(y))
        )
      ),
      fill = af_colour_values["dark-blue"],
      hover_nearest = TRUE
    ) +
    theme_af() +
    scale_y_continuous(labels = comma) +
    labs(
      x = NULL,
      y = NULL
    )

  g <- girafe(
    ggobj = p,
    options = list(
      opts_hover(css = "fill:#ffdd00;stroke:black;stroke-width:1px;opacity:1;"),
      opts_hover_inv(css = "opacity:0.3;")
    )
  )

  girafe_options(g, opts_toolbar(saveaspng = FALSE, hidden = c("selection", "zoom", "misc")))
}
