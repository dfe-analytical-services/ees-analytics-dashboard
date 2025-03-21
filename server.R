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

  # Read in data ------------------------------------------------------------
  service_summary_data <- reactive({
    message("Reading service by date")

    read_delta_lake("ees_service_summary", test_mode = Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date)

  # Filter data -------------------------------------------------------------
  service_by_date <- reactive({
    service_summary_data() |>
      filter_on_date(input$date_choice)
  })

  # Create outputs ----------------------------------------------------------
  ## Value boxes ------------------------------------------------------------
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

  ## Plots ------------------------------------------------------------------
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
}
