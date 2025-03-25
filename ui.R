ui <- page_navbar(
  title = "Explore education statistics analytics",
  id = "pages",
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Custom styling ============================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  bg = "#000", # main navbar background colour
  theme = bs_theme() |>
    # Custom CSS to add whitespace below tabs
    bs_add_rules(
      ".nav-underline { margin-bottom: 20px; };
      .navbar-nav { margin-bottom: 0}"
      # This second line stops the first line
      # applying to the main navbar in the header
    ),
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
        selected = "Last year"
      )
    ),
    ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Overview ---------------------------------------------------------------
    navset_underline(
      id = "service_tabs",
      nav_panel(
        "Overview",
        layout_column_wrap(
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
            value = textOutput("service_sessions_box") |>
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
            value = textOutput("service_pageviews_box") |>
              withSpinner()
          ),
          bslib::value_box(
            title = tooltip(
              span(
                "Average session duration",
                bsicons::bs_icon("question-circle-fill")
              ),
              "The average session duration (total engagment time / total sessions).",
              placement = "bottom"
            ),
            value = textOutput("service_avg_session_duration_box") |>
              withSpinner()
          ),
          bslib::value_box(
            title = tooltip(
              span(
                "Average page views per session",
                bsicons::bs_icon("question-circle-fill")
              ),
              "The average page views per session. Total pageviews / total sessions.",
              placement = "bottom"
            ),
            value = textOutput("service_pageviews_per_session_box") |>
              withSpinner()
          )
        ),
        layout_column_wrap(
          card(
            height = 300,
            full_screen = TRUE,
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
            card_body(
              min_height = 200,
              girafeOutput("service_sessions_plot") |>
                withSpinner()
            )
          ),
          card(
            height = 300,
            full_screen = TRUE,
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
        layout_column_wrap(
          card(
            height = 600,
            full_screen = TRUE,
            card_header("Sessions by device"),
            reactableOutput("service_device_table") |>
              withSpinner()
          ),
          card(
            height = 600,
            full_screen = TRUE,
            card_header("Sessions by device"),
            girafeOutput("service_device_plot") |>
              withSpinner()
          )
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Browser ===============================================================
      nav_panel(
        "Browser",
        layout_column_wrap(
          card(
            height = 280,
            full_screen = TRUE,
            card_header("Sessons by browser"),
            reactableOutput("service_browser_table") |>
              withSpinner()
          ),
          card(
            height = 600,
            full_screen = TRUE,
            card_header("Sessions by browser"),
            girafeOutput("service_browser_plot") |>
              withSpinner()
          )
        ),
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Referrals =============================================================
      nav_panel(
        "Referrals",
        layout_column_wrap(
          navset_card_tab(
            full_screen = TRUE,
            id = "pub_referrals_tabs",
            nav_panel(
              "Chart",
              tags$strong("Percentage of pageviews by source"),
              girafeOutput("service_source_plot") |>
                withSpinner()
            ),
            nav_panel(
              "Full table",
              reactableOutput("service_source_table") |>
                withSpinner()
            )
          ),
          navset_card_tab(
            full_screen = TRUE,
            id = "pub_medium_tabs",
            nav_panel(
              "Chart",
              tags$strong("Percentage of pageviews by medium"),
              girafeOutput("service_medium_plot") |>
                withSpinner()
            ),
            nav_panel(
              "Full table",
              reactableOutput("service_medium_table") |>
                withSpinner()
            )
          )
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Google search =========================================================
      nav_panel(
        "Google search",
        layout_column_wrap(
          card(
            height = 280,
            full_screen = TRUE,
            card_header("Top 10 Google searches by clicks in the past year"),
            reactableOutput("service_gsc_q_clicks_table") |>
              withSpinner()
          ),
          card(
            height = 280,
            full_screen = TRUE,
            card_header("Google clicks over time"),
            girafeOutput("service_gsc_clicks_plot") |>
              withSpinner()
          )
        ),
        layout_column_wrap(
          card(
            height = 280,
            full_screen = TRUE,
            card_header("Top 10 Google searches by appearances the past year"),
            reactableOutput("service_gsc_q_impressions_table") |>
              withSpinner()
          ),
          card(
            height = 280,
            full_screen = TRUE,
            card_header("Google search appearances over time"),
            girafeOutput("service_gsc_impressions_plot") |>
              withSpinner()
          )
        )
      ),
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Page types ============================================================
      nav_panel(
        "Page types",
        "Some breakdowns by page type",
        card(
          height = 280,
          full_screen = TRUE,
          card_header("Title"),
          reactableOutput("service_time_on_page") |>
            withSpinner()
        )
      )
    ) # of of underline tabset
  ), # end of nav page
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summary =======================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Publication analytics",
    layout_column_wrap(
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
        selected = "Last year"
      ),
    ),
    navset_underline(
      id = "pub_tabs",
      nav_panel(
        "Overview",
        layout_column_wrap(
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
            value = textOutput("pub_sessions_box") |>
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
            value = textOutput("pub_pageviews_box") |>
              withSpinner()
          )
        ),
        layout_column_wrap(
          card(
            height = 300,
            full_screen = TRUE,
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
            girafeOutput("pub_sessions_plot") |>
              withSpinner()
          ),
          card(
            height = 300,
            full_screen = TRUE,
            card_header(
              "Page views",
              tooltip(bs_icon("info-circle"), "The total number of pageviews.")
            ),
            girafeOutput("pub_pageviews_plot") |>
              withSpinner()
          ),
          col_widths = c(6, 6)
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Content interactions ==================================================
      nav_panel(
        "Content interactions",
        layout_column_wrap(
          bslib::value_box(
            title = "Time to read latest release in full",
            value = textOutput("readtime_box") |>
              withSpinner()
          )
        ),
        card(
          height = 530,
          full_screen = TRUE,
          card_header("Title"),
          reactableOutput("pub_content_interactions_table") |>
            withSpinner()
        )
      ),



      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Accordions ============================================================
      nav_panel(
        "Accordion clicks",
        layout_column_wrap(
          card(
            height = 530,
            full_screen = TRUE,
            card_header("Release pages"),
            reactableOutput("pub_accordions_release_table") |>
              withSpinner()
          ),
          card(
            height = 530,
            full_screen = TRUE,
            card_header("Methodology page"),
            reactableOutput("pub_accordions_methodology_table") |>
              withSpinner()
          )
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Searches ==============================================================
      nav_panel(
        "Searches",
        layout_column_wrap(
          card(
            height = 600,
            full_screen = TRUE,
            card_header(
              tagList(
                tags$p("Top 10 Google searches in the past year"),
                radioButtons(
                  "pub_search_console_metric",
                  label = NULL,
                  inline = TRUE,
                  choiceNames = c("Clicks", "Search appearances"),
                  choiceValues = c("clicks", "impressions")
                )
              )
            ),
            reactableOutput("pub_gsc_table") |>
              withSpinner()
          ),
          card(
            height = 600,
            full_screen = TRUE,
            card_header("Searches on publication pages"),
            reactableOutput("pub_searches_table") |>
              withSpinner()
          ),
          card(
            height = 600,
            full_screen = TRUE,
            card_header("Searches on methodology pages"),
            reactableOutput("pub_searches_meth_table") |>
              withSpinner()
          )
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Referrals =============================================================
      nav_panel(
        "Referrals",
        layout_column_wrap(
          navset_card_tab(
            full_screen = TRUE,
            id = "pub_referrals_tabs",
            nav_panel(
              "Chart",
              tags$strong("Percentage of pageviews by source"),
              girafeOutput("pub_source_plot") |>
                withSpinner()
            ),
            nav_panel(
              "Full table",
              reactableOutput("pub_source_table") |>
                withSpinner()
            )
          ),
          navset_card_tab(
            full_screen = TRUE,
            id = "pub_medium_tabs",
            nav_panel(
              "Chart",
              tags$strong("Percentage of pageviews by medium"),
              girafeOutput("pub_medium_plot") |>
                withSpinner()
            ),
            nav_panel(
              "Full table",
              reactableOutput("pub_medium_table") |>
                withSpinner()
            )
          )
        )
      ),

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Tables ================================================================
      nav_panel(
        "Tables",
        layout_column_wrap(
          card(
            full_screen = TRUE,
            card_header("Top viewed featured tables"),
            reactableOutput("pub_featured_tables_table") |>
              withSpinner()
          ),
          card(
            full_screen = TRUE,
            card_header("Data sets with most tables created"),
            reactableOutput("pub_created_tables_table") |>
              withSpinner()
          )
        )
      )
    ) # end of underline tabset
  ), # end of nav page
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Downloads =================================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Downloads",
    bslib::layout_column_wrap(
      width = 1 / 2,
      downloads_content() # defined in R/pages/technical_notes.R
    )
  ),
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Technical notes ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  nav_panel(
    title = "Technical notes",
    bslib::layout_column_wrap(
      width = 1 / 2,
      technical_notes_content() # defined in R/pages/technical_notes.R
    )
  )
)
