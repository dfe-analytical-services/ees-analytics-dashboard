server <- function(input, output, session) {
  # Check the latest date =====================================================
  last_updated_table <- reactive({
    message("Checking last updated")

    read_delta_lake("ees__last_updated", test_mode = Sys.getenv("TESTTHAT"))
  })

  last_updated_date <- reactive({
    last_updated_table() |> pull(last_updated)
  })

  output$latest_date <- renderText({
    paste0("Latest available data: ", last_updated_table() |> pull(latest_data))
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Service summary ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  service_summary_data <- reactive({
    message("Reading service by date")

    read_delta_lake(
      "ees_service_summary",
      test_mode = Sys.getenv("TESTTHAT"),
      lazy = TRUE
    )
  }) |>
    bindCache(last_updated_date)

  service_by_date <- reactive({
    service_summary_data() |>
      filter_on_date(input$date_choice, latest_date) |>
      collect()
  }) # caching not needed here as the plots themselves are cached

  # Value boxes ---------------------------------------------------------------
  output$service_total_sessions_box <- renderText({
    aggregate_total(
      data = service_by_date(),
      metric = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  output$service_total_pageviews_box <- renderText({
    aggregate_total(
      data = service_by_date(),
      metric = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  # Plots ---------------------------------------------------------------------
  output$service_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = service_by_date(),
      x = "date",
      y = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  output$service_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = service_by_date(),
      x = "date",
      y = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summaries =====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Data loading ==============================================================
  release_pageviews_data <- reactive({
    message("Reading publication pageviews")

    read_delta_lake(
      "ees_release_pageviews",
      test_mode = Sys.getenv("TESTTHAT"),
      lazy = TRUE
    )
  }) |>
    bindCache(last_updated_date())

  # Dropdown options =========================================================
  publication_list <- reactive({
    release_pageviews_data() |>
      distinct(publication) |>
      pull(publication) |>
      stringr::str_sort()
  }) |>
    bindCache(last_updated_date())

  observe({
    updateSelectInput(
      session,
      "pub_name_choice",
      choices = publication_list()
    )
  })

  # Filtering data ============================================================
  release_pageviews_by_date <- reactive({
    release_pageviews_data() |>
      filter(publication == input$pub_name_choice) |>
      filter_on_date(input$pub_date_choice, latest_date) |>
      collect()
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)

  # Value boxes ---------------------------------------------------------------
  output$publication_total_sessions_box <- renderText({
    aggregate_total(
      data = release_pageviews_by_date(),
      metric = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)

  output$publication_total_pageviews_box <- renderText({
    aggregate_total(
      data = release_pageviews_by_date(),
      metric = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)

  # Plots ---------------------------------------------------------------------
  output$publication_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = release_pageviews_by_date(),
      x = "date",
      y = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)

  output$publication_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = release_pageviews_by_date(),
      x = "date",
      y = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)
}
