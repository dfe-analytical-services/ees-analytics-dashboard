ui <- page_navbar(
  title = "Explore education statistics analytics",
  bg = "#000",

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Service summary ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Service summary",

    # User selections ---------------------------------------------------------
    layout_columns(
      fill = FALSE,
      textOutput("service_latest_date") |>
        withSpinner(),
      selectInput(
        "service_date_choice",
        "Choose date range",
        names(date_options),
        selected = "All time"
      ),
      selectInput(
        "service_metric_choice",
        "Choose metric",
        choices = c("Sessions", "Pageviews"),
        selected = "Sessions"
      )
    ),
    ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Overview ---------------------------------------------------------------
    navset_underline(
      nav_panel(
        "Overview",
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
              withSpinner()
          ),
          col_widths = c(6, 6)
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Devices ===============================================================
      nav_panel(
        "Devices",
        "Some devices"
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Referrals =============================================================
      nav_panel(
        "Referrals",
        "Some referral stuff"
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Google search =========================================================
      nav_panel(
        "Google search",
        layout_column_wrap(
          card(
            card_header("Top Google searches by clicks in the past year"),
            reactableOutput("service_search_console_q_clicks") |>
              withSpinner()
          ),
          card(
            card_header("Google clicks over time"),
            girafeOutput("service_search_console_plot_clicks") |>
              withSpinner()
          )
        ),
        layout_column_wrap(
          card(
            card_header("Top Google searches by appearances the past year"),
            reactableOutput("service_search_console_q_impressions") |>
              withSpinner()
          ),
          card(
            card_header("Google appearances over time"),
            girafeOutput("service_search_console_plot_impressions") |>
              withSpinner()
          )
        )
      ),
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Page types ============================================================
      nav_panel(
        "Page types",
        "Some breakdowns by page type"
      )
    ) # of of underline tabset
  ), # end of nav page
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summary =======================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Publication analytics",
    layout_columns(
      fill = FALSE,
      textOutput("pub_latest_date"),
      selectInput(
        "pub_name_choice",
        "Choose a publication",
        choices = "loading...",
        selected = NULL
      ),
      selectInput(
        "pub_date_choice",
        "Choose date range",
        names(date_options),
        selected = "All time"
      ),
    ),
    navset_underline(
      nav_panel(
        "Overview",
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
              "Page views",
              tooltip(bs_icon("info-circle"), "The total number of pageviews.")
            ),
            girafeOutput("publication_pageviews_plot") |>
              withSpinner()
          ),
          col_widths = c(6, 6)
        )
      ),
      nav_panel(
        "Content",
        "Some stuff on content"
      ),
      nav_panel(
        "Searches and referrals",
        card(
          card_header(
            tagList(
              tags$p("Top Google searches in the past year"),
              radioButtons(
                "pub_search_console_metric",
                label = NULL,
                inline = TRUE,
                choiceNames = c("Clicks", "Search appearances"),
                choiceValues = c("clicks", "impressions")
              )
            )
          ),
          reactableOutput("publication_search_console_table") |>
            withSpinner()
        )
      ),
      nav_panel(
        "Tables",
        "Something about tables"
      )
    ) # end of underline tabset
  ), # end of nav page
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Downloads =================================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Downloads",
    "Some downloads"
  ),
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Technical notes ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Technical notes",
    "Some technical notes"
  )
)
