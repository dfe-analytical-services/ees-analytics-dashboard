filter_on_date <- function(data, period) {
  first_date <- if (period == "week") {
    week_date
  } else if (period == "four_week") {
    four_week_date
  } else if (period == "since_2ndsep") {
    since_4thsep_date
  } else if (period == "six_month") {
    six_month_date
  } else if (period == "one_year") {
    one_year_date
  } else if (period == "all_time") {
    all_time_date
  } else {
    "2020-04-03"
  }

  data %>% filter(date >= first_date & date <= latest_date)
}

filter_on_date_pub <- function(data, period, page) {
  first_date <- if (period == "week") {
    week_date
  } else if (period == "four_week") {
    four_week_date
  } else if (period == "since_4thsep") {
    since_4thsep_date
  } else if (period == "six_month") {
    six_month_date
  } else if (period == "one_year") {
    one_year_date
  } else if (period == "all_time") {
    all_time_date
  } else {
    "2020-04-03"
  }

  data %>%
    filter(date >= first_date & date <= latest_date) %>%
    filter(publication == page)
}

#' Read in table from delta lake
#'
#' This relies on already having a pool connection set up, or using the test
#' flag to read in local data from the repo.
#'
#' @param table_name name of table in delta lake / local test data
#' @param lazy whether to return lazily loaded table or collect into memory
#' @param test_mode override flag that will load test data from repo
read_delta_lake <- function(table_name, lazy = FALSE, test_mode = "") {
  if (test_mode == "true") {
    lazy_table <- duckplyr::read_parquet_duckdb(
      paste0("tests/testdata/", table_name, ".parquet")
    )
  } else if (test_mode == "") {
    lazy_table <- pool |>
      dplyr::tbl(
        DBI::Id(
          catalog = config$catalog,
          schema = config$schema,
          table = table_name
        )
      )
  } else {
    warning("There was an issue with the test_mode argument:", test_mode)
  }

  if (lazy) {
    return(lazy_table |> duckplyr::as_duckdb_tibble())
  } else {
    return(lazy_table |> collect())
  }
}

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

#' Create basic single line, line chart
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
