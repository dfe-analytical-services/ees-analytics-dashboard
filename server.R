server <- function(input, output, session) {
  # Check the latest date =====================================================
  last_updated_table <- reactive({
    message("Checking last updated")

    read_delta_lake("ees__last_updated", Sys.getenv("TESTTHAT"))
  })

  last_updated_date <- reactive({
    last_updated_table() |> pull(last_updated)
  })

  output$service_latest_date <- renderText({
    paste0("Latest available data: ", last_updated_table() |> pull(latest_data))
  })

  output$pub_latest_date <- renderText({
    paste0("Latest available data: ", last_updated_table() |> pull(latest_data))
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Service summary ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  service_summary_data <- reactive({
    message("Reading service by date")

    read_delta_lake("ees_service_summary", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date)

  service_summary_by_date <- reactive({
    service_summary_data() |>
      filter_on_date(input$service_date_choice) |>
      collect()
  })

  # Value boxes ---------------------------------------------------------------
  output$service_total_sessions_box <- renderText({
    aggregate_total(
      data = service_summary_by_date(),
      metric = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  output$service_total_pageviews_box <- renderText({
    aggregate_total(
      data = service_summary_by_date(),
      metric = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  # Plots ---------------------------------------------------------------------
  output$service_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "sessions"
    )
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  output$service_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "screenPageViews"
    )
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summaries =====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Data loading ==============================================================
  release_pageviews_data <- reactive({
    message("Reading publication pageviews")

    read_delta_lake("ees_release_pageviews", Sys.getenv("TESTTHAT"))
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
      filter_on_date(input$pub_date_choice) |>
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
      metric = "pageviews"
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
      y = "pageviews"
    )
  }) |>
    bindCache(last_updated_date(), input$pub_date_choice, input$pub_name_choice)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Search console ============================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  search_console_data <- reactive({
    message("Reading search console data")

    read_delta_lake("ees_search_console_queries", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_search_console <- reactive({
    search_console_data() |>
      filter(publication == "Service") |>
      select(-c(publication))
  }) |>
    bindCache(last_updated_date())

  publication_search_console <- reactive({
    search_console_data() |>
      filter(publication == input$pub_name_choice) |>
      filter(metric == input$pub_search_console_metric) |>
      select(-c(metric, publication))
  }) |>
    bindCache(last_updated_date(), input$pub_name_choice, input$pub_search_console_metric)

  search_console_timeseries <- reactive({
    message("Reading search console timeseries")

    read_delta_lake("ees_search_console_timeseries", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_search_console_time <- reactive({
    search_console_timeseries() |>
      filter_on_date(input$service_date_choice)
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  # Table outputs -------------------------------------------------------------
  output$service_search_console_q_clicks <- renderReactable({
    service_search_console() |>
      filter(metric == "clicks") |>
      rename("clicks" = count) |>
      select(-metric) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$service_search_console_q_impressions <- renderReactable({
    service_search_console() |>
      filter(metric == "impressions") |>
      rename("impressions" = count) |>
      select(-metric) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$publication_search_console_table <- renderReactable({
    dfe_reactable(publication_search_console())
  }) |>
    bindCache(publication_search_console())

  # Plot outputs --------------------------------------------------------------
  output$service_search_console_plot_clicks <- renderGirafe({
    simple_bar_chart(
      data = service_search_console_time(),
      x = "date",
      y = "clicks"
    )
  }) |>
    bindCache(service_search_console_timeseries())

  output$service_search_console_plot_impressions <- renderGirafe({
    simple_bar_chart(
      data = service_search_console_time(),
      x = "date",
      y = "impressions"
    )
  }) |>
    bindCache(service_search_console_timeseries())
}
