ui <- page_navbar(
  title = "Explore education statistics analytics",
  bg = "#0062cc",

  # Service summary ===========================================================
  nav_panel(
    title = "Service summary",
    layout_sidebar(
      sidebar = sidebar(
        title = "Options",
        radioButtons(
          "date_choice",
          "Choose date range",
          c(
            "week",
            "four_week",
            "since_2ndsep",
            "six_month",
            "one_year",
            "all_time"
          ),
          selected = "all_time"
        ),
      ),
      textOutput("latest_date"),
      layout_columns(
        bslib::value_box(
          title = tooltip(
            span(
              "Number of sessions",
              bsicons::bs_icon("question-circle-fill")
            ),
            paste(
              "The total number of sessions. This is only applicable to the service as",
              "a whole - sessions are only counted for entry pages in the Google Analytics",
              "data. Sessions have a 24 hour limit, a session lasting 25 hours would count",
              "as two sessions."
            ),
            placement = "bottom"
          ),
          value = textOutput("service_total_sessions_box")
        ),
        bslib::value_box(
          title = tooltip(
            span(
              "Number of pageviews",
              bsicons::bs_icon("question-circle-fill")
            ),
            "The total number of pageviews.",
            placement = "bottom"
          ),
          value = textOutput("service_total_pageviews_box")
        )
      ),
      layout_columns(
        card(
          card_header(
            "Sessions",
            tooltip(
              bs_icon("info-circle"),
              paste(
                "The total number of sessions. This is only applicable to the service as",
                "a whole - sessions are only counted for entry pages in the Google Analytics",
                "data. Sessions have a 24 hour limit, a session lasting 25 hours would count",
                "as two sessions."
              )
            )
          ),
          girafeOutput("service_sessions_plot")
        ),
        card(
          card_header(
            "Page views", tooltip(bs_icon("info-circle"), "The total number of pageviews.")
          ),
          girafeOutput("service_pageviews_plot"),
          col_widths = c(6, 6)
        )
      )
    )
  )
)
