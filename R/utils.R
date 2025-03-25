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
    duck_table <- duckplyr::read_parquet_duckdb(
      paste0("tests/testdata/", table_name, ".parquet")
    )
  } else {
    duck_table <- pool |>
      dplyr::tbl(
        DBI::Id(
          catalog = config$catalog,
          schema = config$schema,
          table = table_name
        )
      ) |>
      collect() |>
      as_duckdb_tibble()
  }

  return(duck_table)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create headline aggregate total for value boxes
#'
#' @param data data set
#' @param metric metric to sum
aggregate_total <- function(data, metric) {
  data |>
    as.data.frame() |>
    summarise(sum(!!sym(metric), na.rm = TRUE)) |>
    dfeR::comma_sep() |>
    paste0()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create basic bar chart
#'
#' @param data data set
#' @param x x axis data
#' @param y y axis data
#' @param flip boolean to flip the chart to horizontal bars
#' @param suffix character string to append to y values in axis label and tooltips
#' @param reorder boolean to reorder the data by y values
simple_bar_chart <- function(data, x, y, flip = FALSE, suffix = "", reorder = FALSE) {
  x_var <- as.character(rlang::as_name(x))
  y_var <- as.character(rlang::as_name(y))

  p <- data |>
    ggplot(aes(
      x = if (reorder) reorder(!!sym(x), !!sym(y)) else !!sym(x),
      y = !!sym(y)
    )) +
    geom_col_interactive(
      aes(
        data_id = seq_along(!!sym(x)),
        tooltip = paste0(
          x_var, ": ", !!sym(x), "\n", y_var, ": ", scales::comma(!!sym(y)), suffix
        )
      ),
      fill = af_colour_values["dark-blue"],
      hover_nearest = TRUE
    ) +
    theme_af() +
    scale_y_continuous(labels = function(y) paste0(scales::comma(y), suffix)) +
    labs(
      x = NULL,
      y = NULL
    )
  if (flip) {
    data <- data |>
      arrange(desc(!!sym(y)))

    p <- p +
      coord_flip() +
      theme(panel.grid = element_blank())
  }

  g <- girafe(
    ggobj = p,
    options = list(
      opts_hover(css = "fill:#ffdd00;stroke:black;stroke-width:1px;opacity:1;"),
      opts_hover_inv(css = "opacity:0.3;")
    ),
    height_svg = 1.7
  )

  girafe_options(g, opts_toolbar(saveaspng = FALSE, hidden = c("selection", "zoom", "misc")))
}

#' Custom table styling
#'
#' @param data table
#' @param row_style
#' @param searchable
#' @param default_page_size
dfe_reactable <- function(data,
                          row_style = NULL,
                          sortable = FALSE,
                          default_page_size = 10) {
  reactable::reactable(
    data,

    # DfE styling
    highlight = TRUE,
    borderless = TRUE,
    showSortIcon = FALSE,
    style = list(fontSize = "16px", display = "block"),
    defaultColDef = colDef(headerClass = "bar-sort-header"),

    # Customiseable settings
    sortable = sortable,
    defaultPageSize = default_page_size,
    searchable = FALSE
  )
}

#' Pretty time
#'
#' Convert seconds into a human readable format
#'
#' Recognises when to present as:
#' - seconds
#' - minutes and seconds
#' - hours, minutes and seconds
#'
#' It doesn't do days or higher yet, but could be adapted to
#' if there's demand.
#'
#' @param seconds number of seconds to prettify
#'
#' @returns string containing the 'pretty' time
pretty_time <- function(seconds) {
  # Present as seconds
  if (seconds < 120) {
    if (seconds == 1) {
      return("1 second")
    } else {
      return(paste0(seconds, " seconds"))
    }
  } else {
    # Present as minutes and seconds
    if (seconds < 7140) {
      mins <- seconds %/% 60
      secs <- dfeR::round_five_up(seconds %% 60)

      min_desc <- ifelse(mins == 1, " minute ", " minutes ")
      sec_desc <- ifelse(secs == 1, " second", " seconds")

      return(
        paste0(
          mins, min_desc, secs, sec_desc
        )
      )
      # Present as hours, minutes and seconds
    } else {
      hours <- seconds %/% 3600
      mins <- seconds %/% 60 - hours * 60
      secs <- round_five_up(seconds %% 60)

      hour_desc <- ifelse(hours == 1, " hour ", " hours ")
      min_desc <- ifelse(mins == 1, " minute ", " minutes ")
      sec_desc <- ifelse(secs == 1, " second", " seconds")

      return(
        paste0(
          dfeR::comma_sep(hours), hour_desc, mins, min_desc, secs, sec_desc
        )
      )
    }
  }
}
