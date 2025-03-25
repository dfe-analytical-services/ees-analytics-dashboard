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
  service_summary_full <- reactive({
    message("Reading service summary")

    read_delta_lake("ees_service_summary", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_summary_by_date <- reactive({
    service_summary_full() |>
      filter_on_date(input$service_date_choice) |>
      collect()
  }) |>
    bindCache(last_updated_date(), input$service_date_choice)

  output$service_summary_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_analytics_service_summary.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(service_summary_full(), file)
    }
  )

  # Value boxes ---------------------------------------------------------------
  output$service_sessions_box <- renderText({
    aggregate_total(
      data = service_summary_by_date(),
      metric = "sessions"
    )
  }) |>
    bindCache(service_summary_by_date())

  output$service_pageviews_box <- renderText({
    aggregate_total(
      data = service_summary_by_date(),
      metric = "pageviews"
    )
  }) |>
    bindCache(service_summary_by_date())

  # Plots ---------------------------------------------------------------------
  output$service_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "sessions"
    )
  }) |>
    bindCache(service_summary_by_date())

  output$service_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "pageviews"
    )
  }) |>
    bindCache(service_summary_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Service devices ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  service_device_full <- reactive({
    message("Reading service by device")

    read_delta_lake("ees_service_device_browser", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_device_by_date <- reactive({
    service_device_full() |>
      filter_on_date(input$service_date_choice) |>
      collect()
  }) |>
    bindCache(service_device_full(), input$service_date_choice)

  output$service_device_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_service_device_browser.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(service_device_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  output$service_device_table <- renderReactable({
    service_device_by_date() |>
      dfe_reactable()
  }) |>
    bindCache(service_device_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication summaries =====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Data loading ==============================================================
  pub_summary_full <- reactive({
    message("Reading publication summary")

    read_delta_lake("ees_publication_summary", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  output$pub_summary_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_analytics_pub_summary.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_summary_full(), file)
    }
  )

  # Dropdown options =========================================================
  publication_list <- reactive({
    pub_summary_full() |>
      distinct(publication) |>
      pull(publication) |>
      stringr::str_sort()
  }) |>
    bindCache(pub_summary_full())

  observe({
    updateSelectInput(
      session,
      "pub_name_choice",
      choices = publication_list()
    )
  })

  # Filtering data ============================================================
  pub_summary_by_date <- reactive({
    pub_summary_full() |>
      filter(publication == input$pub_name_choice) |>
      filter_on_date(input$pub_date_choice) |>
      collect()
  }) |>
    bindCache(pub_summary_full(), input$pub_date_choice, input$pub_name_choice)

  # Value boxes ---------------------------------------------------------------
  output$pub_sessions_box <- renderText({
    aggregate_total(
      data = pub_summary_by_date(),
      metric = "sessions"
    )
  }) |>
    bindCache(pub_summary_by_date())

  output$pub_pageviews_box <- renderText({
    aggregate_total(
      data = pub_summary_by_date(),
      metric = "pageviews"
    )
  }) |>
    bindCache(pub_summary_by_date())

  # Plots ---------------------------------------------------------------------
  output$pub_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = pub_summary_by_date(),
      x = "date",
      y = "sessions"
    )
  }) |>
    bindCache(pub_summary_by_date())

  output$pub_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = pub_summary_by_date(),
      x = "date",
      y = "pageviews"
    )
  }) |>
    bindCache(pub_summary_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication accordions ====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_accordions_full <- reactive({
    message("Reading publication accordions")

    read_delta_lake("ees_publication_accordions", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_accordions_by_date <- reactive({
    pub_accordions_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(pub_accordions_full(), input$pub_date_choice, input$pub_name_choice)

  # Download ------------------------------------------------------------------
  output$pub_accordions_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_analytics_pub_accordions.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_accordions_full(), file)
    }
  )

  # Table ---------------------------------------------------------------------
  output$pub_accordions_release_table <- renderReactable({
    pub_accordions_by_date() |>
      filter(page_type == "Release page") |>
      select(-page_type) |>
      group_by(publication, eventLabel) |>
      summarise("Clicks" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      rename("Accordion title" = eventLabel) |>
      select(-publication) |>
      arrange(desc(Clicks)) |>
      dfe_reactable()
  }) |>
    bindCache(pub_accordions_by_date())

  output$pub_accordions_methodology_table <- renderReactable({
    pub_accordions_by_date() |>
      filter(page_type == "Methodology") |>
      select(-page_type) |>
      group_by(publication, eventLabel) |>
      summarise("Clicks" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      rename("Accordion title" = eventLabel) |>
      select(-publication) |>
      arrange(desc(Clicks)) |>
      dfe_reactable()
  }) |>
    bindCache(pub_accordions_by_date())
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Reading time ==============================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  readtime_full <- reactive({
    message("Reading reading reading reading reading time")

    read_delta_lake("ees_avg_readtime", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  output$readtime_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_avg_readtime.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(readtime_full(), file)
    }
  )

  # Value box -----------------------------------------------------------------
  output$readtime_box <- renderText({
    readtime_full() |>
      filter(title == input$pub_name_choice) |>
      pull(avg_read_time) |>
      pretty_time() # TODO: add to dfeR
  }) |>
    bindCache(readtime_full(), input$pub_name_choice)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Search console ============================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  search_console_full <- reactive({
    message("Reading search console queries")

    read_delta_lake("ees_search_console_queries", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  output$search_console_queries_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_analytics_search_console_queries.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(search_console_full(), file)
    }
  )

  service_search_console <- reactive({
    search_console_full() |>
      filter(publication == "Service") |>
      select(-c(publication))
  }) |>
    bindCache(search_console_full())

  publication_search_console <- reactive({
    search_console_full() |>
      filter(publication == input$pub_name_choice) |>
      filter(metric == input$pub_search_console_metric) |>
      select(-c(metric, publication))
  }) |>
    bindCache(search_console_full(), input$pub_name_choice, input$pub_search_console_metric)

  search_console_time_full <- reactive({
    message("Reading search console timeseries")

    read_delta_lake("ees_search_console_timeseries", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  output$search_console_time_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_analytics_search_console_timeseries.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(search_console_time_full(), file)
    }
  )

  search_console_time_by_date <- reactive({
    search_console_time_full() |>
      filter_on_date(input$service_date_choice)
  }) |>
    bindCache(search_console_time_full(), input$service_date_choice)

  # Table outputs -------------------------------------------------------------
  output$service_gsc_q_clicks_table <- renderReactable({
    service_search_console() |>
      filter(metric == "clicks") |>
      rename("clicks" = count) |>
      select(-metric) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$service_gsc_q_impressions_table <- renderReactable({
    service_search_console() |>
      filter(metric == "impressions") |>
      rename("impressions" = count) |>
      select(-metric) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$pub_gsc_table <- renderReactable({
    publication_search_console() |>
      dfe_reactable()
  }) |>
    bindCache(publication_search_console())

  # Plot outputs --------------------------------------------------------------
  output$service_gsc_clicks_plot <- renderGirafe({
    simple_bar_chart(
      data = search_console_time_by_date(),
      x = "date",
      y = "clicks"
    )
  }) |>
    bindCache(search_console_time_by_date())

  output$service_gsc_impressions_plot <- renderGirafe({
    simple_bar_chart(
      data = search_console_time_by_date(),
      x = "date",
      y = "impressions"
    )
  }) |>
    bindCache(search_console_time_by_date())
}
