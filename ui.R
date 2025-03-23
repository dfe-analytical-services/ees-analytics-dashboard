ui <- page_navbar(
  title = "Explore education statistics analytics",
  bg = "#0062cc",
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Service summary ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    autoWaiter(),
    title = "Service summary",
    layout_sidebar(
      sidebar = sidebar(
        title = "Options",
        radioButtons(
          "date_choice",
          "Choose date range",
          date_options,
          selected = "Last four weeks"
        ),
      ),
      textOutput("latest_date"), # TODO: no longer working due to duplicate IDs
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
          value = textOutput("service_total_sessions_box") |>
            withSpinner()
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
          value = textOutput("service_total_pageviews_box") |>
            withSpinner()
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
          girafeOutput("service_sessions_plot") |>
            withSpinner()
        ),
        card(
          card_header(
            "Page views", tooltip(bs_icon("info-circle"), "The total number of pageviews.")
          ),
          girafeOutput("service_pageviews_plot") |>
            withSpinner(),
          col_widths = c(6, 6)
        )
      )
    )
  ),

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summary =======================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Publication summary",
    layout_sidebar(
      sidebar = sidebar(
        title = "Options",
        selectInput(
          "pub_name_choice",
          label = p(strong("Choose a publication")),
          choices = "loading...",
          selected = NULL
        ),
        radioButtons(
          "pub_date_choice",
          "Choose date range",
          date_options,
          selected = "Last four weeks"
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
          value = textOutput("publication_total_sessions_box") |>
            withSpinner()
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
          value = textOutput("publication_total_pageviews_box") |>
            withSpinner()
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
          girafeOutput("publication_sessions_plot") |>
            withSpinner()
        ),
        card(
          card_header(
            "Page views", tooltip(bs_icon("info-circle"), "The total number of pageviews.")
          ),
          girafeOutput("publication_pageviews_plot") |>
            withSpinner(),
          col_widths = c(6, 6)
        )
      )
    )
  )
)
