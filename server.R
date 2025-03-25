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
      paste0(Sys.Date(), "_service_summary.csv")
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

  output$service_pageviews_per_session_box <- renderText({
    paste(
      round(sum(service_summary_by_date()$pageviews, na.rm = TRUE) / sum(service_summary_by_date()$sessions, na.rm = TRUE), 1)
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
      mutate(device = case_when(
        device %in% c("mobile", "desktop", "tablet") ~ device,
        TRUE ~ "Other"
      )) |>
      group_by(page_type, device) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "drop"
      ) |>
      pivot_wider(names_from = device, values_from = Sessions, values_fill = list(Sessions = 0)) |>
      dfe_reactable()
  }) |>
    bindCache(service_device_by_date())


  output$service_browser_table <- renderReactable({
    service_device_by_date() |>
      mutate(browser = case_when(
        browser %in% c("Chrome", "Edge", "Safari") ~ browser,
        TRUE ~ "Other"
      )) |>
      group_by(page_type, browser) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "drop"
      ) |>
      pivot_wider(names_from = browser, values_from = Sessions, values_fill = list(Sessions = 0)) |>
      dfe_reactable()
  }) |>
    bindCache(service_device_by_date())


  # Plots ---------------------------------------------------------------------
  output$service_device_plot <- renderGirafe({
    data_for_chart <- service_device_by_date() |>
      mutate(device = case_when(
        device %in% c("mobile", "desktop", "tablet") ~ device,
        TRUE ~ "Other"
      )) |>
      group_by(page_type, device) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup()

    stacked_bar_chart(
      data = data_for_chart,
      x = "page_type",
      y = "Sessions",
      fill = "device",
      height = 4
    )
  }) |>
    bindCache(service_summary_by_date())

  output$service_browser_plot <- renderGirafe({
    data_for_chart <- service_device_by_date() |>
      mutate(browser = case_when(
        browser %in% c("Chrome", "Edge", "Safari") ~ browser,
        TRUE ~ "Other"
      )) |>
      group_by(page_type, browser) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup()

    stacked_bar_chart(
      data = data_for_chart,
      x = "page_type",
      y = "Sessions",
      fill = "browser",
      height = 4
    )
  }) |>
    bindCache(service_summary_by_date())




  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Page types ================================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  service_time_on_page_full <- reactive({
    message("Reading service time on page")

    read_delta_lake("ees_service_time_on_page", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_time_on_page_by_date <- reactive({
    service_time_on_page_full() |>
      filter_on_date(input$service_date_choice) |>
      collect()
  }) |>
    bindCache(service_time_on_page_full(), input$service_date_choice)

  output$service_time_on_page_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_ees_service_time_on_page.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(service_time_on_page_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  output$service_time_on_page <- renderReactable({
    service_time_on_page_by_date() |>
      group_by(page_type) |>
      summarise(
        "Sessions" = sum(sessions),
        "Pageviews" = sum(pageviews),
        "EngagementDuration" = sum(engagementDuration),
        .groups = "keep"
      ) |>
      ungroup() |>
      mutate("avgTimeOnPage" = EngagementDuration / Pageviews) |>
      select(page_type, Pageviews, avgTimeOnPage) |>
      arrange(desc(avgTimeOnPage)) |>
      dfe_reactable()
  }) |>
    bindCache(service_time_on_page_by_date())

  # Value box -------------------------------------------------------------

  output$service_avg_session_duration_box <- renderText({
    paste(
      round(sum(service_time_on_page_by_date()$engagementDuration, na.rm = TRUE) / sum(service_time_on_page_by_date()$sessions, na.rm = TRUE), 1),
      "seconds"
    )
  }) |>
    bindCache(service_summary_by_date())

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
      paste0(Sys.Date(), "_pub_summary.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_summary_full(), file)
    }
  )

  # Dropdown options =========================================================
  # TODO: Could get this from a separate smaller table to save needing to load
  # the full publication summary table on initial start up
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
      paste0(Sys.Date(), "_pub_accordions.csv")
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
  # Content interactions ======================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  content_interactions_full <- reactive({
    message("Reading publication accordions")

    read_delta_lake("ees_publication_time_on_page", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  content_interactions_by_date <- reactive({
    content_interactions_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(content_interactions_full(), input$pub_date_choice, input$pub_name_choice)

  # Download ------------------------------------------------------------------
  output$content_interactions_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_content_interactions.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(content_interactions_full(), file)
    }
  )

  # Table ---------------------------------------------------------------------
  output$pub_content_interactions_table <- renderReactable({
    content_interactions_by_date() |>
      group_by(page_type) |>
      summarise(
        "Sessions" = sum(sessions),
        "Pageviews" = sum(pageviews),
        "EngagementDuration" = sum(engagementDuration),
        .groups = "keep"
      ) |>
      ungroup() |>
      mutate("avgTimeOnPage" = EngagementDuration / Pageviews) |>
      select(page_type, Pageviews, avgTimeOnPage) |>
      arrange(desc(avgTimeOnPage)) |>
      dfe_reactable()
  }) |>
    bindCache(content_interactions_by_date())

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
      paste0(Sys.Date(), "_readtime.csv")
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

  output$gsc_queries_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_gsc_queries.csv")
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

  output$gsc_time_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_gsc_time.csv")
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

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Publication search events =================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_search_events_full <- reactive({
    message("Reading publication search events")

    read_delta_lake("ees_publication_search_events", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_search_events_by_date <- reactive({
    pub_search_events_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(pub_search_events_full(), input$pub_date_choice, input$pub_name_choice)

  output$pub_search_events_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_search_events.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_search_events_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  output$pub_searches_table <- renderReactable({
    pub_search_events_by_date() |>
      filter(page_type == "Release page") |>
      group_by(publication, eventLabel) |>
      summarise("Count" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      select(-publication) |>
      rename("Search term" = eventLabel) |>
      arrange(desc(Count)) |>
      dfe_reactable()
  }) |>
    bindCache(pub_search_events_by_date())

  output$pub_searches_meth_table <- renderReactable({
    pub_search_events_by_date() |>
      filter(page_type == "Methodology pages") |>
      group_by(publication, eventLabel) |>
      summarise("Count" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      select(-publication) |>
      rename("Search term" = eventLabel) |>
      arrange(desc(Count)) |>
      dfe_reactable()
  }) |>
    bindCache(pub_search_events_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Pub sources and mediums ===================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_source_full <- reactive({
    message("Reading publication sources and mediums")

    read_delta_lake("ees_publication_source_medium", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_source_by_date <- reactive({
    pub_source_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(pub_source_full(), input$pub_date_choice, input$pub_name_choice)

  output$pub_source_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_source.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_source_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  pub_source_summarised <- reactive({
    pub_source_by_date() |>
      group_by(publication, source) |>
      summarise(
        "pageviews" = sum(pageviews),
        "sessions" = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup() |>
      select(-publication) |>
      arrange(desc(pageviews))
  }) |>
    bindCache(pub_source_by_date())

  output$pub_source_table <- renderReactable({
    pub_source_summarised() |>
      dfe_reactable()
  }) |>
    bindCache(pub_source_summarised())

  pub_medium_summarised <- reactive({
    pub_source_by_date() |>
      group_by(publication, medium) |>
      summarise(
        "pageviews" = sum(pageviews),
        "sessions" = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup() |>
      select(-publication) |>
      arrange(desc(pageviews))
  }) |>
    bindCache(pub_source_by_date())

  output$pub_medium_table <- renderReactable({
    pub_medium_summarised() |>
      dfe_reactable()
  }) |>
    bindCache(pub_medium_summarised())

  # Plots ---------------------------------------------------------------------
  output$pub_source_plot <- renderGirafe({
    top_5 <- pub_source_summarised() |>
      filter(pageviews > 0) |>
      arrange(desc(pageviews)) |>
      head(5)

    other <- pub_source_summarised() |>
      arrange(desc(pageviews)) |>
      slice(6:n()) |>
      summarise(
        source = "other",
        pageviews = sum(pageviews, na.rm = TRUE),
        sessions = sum(sessions, na.rm = TRUE)
      )

    data <- bind_rows(top_5, other) |>
      mutate(pageviews_perc = dfeR::round_five_up(pageviews / sum(pageviews) * 100, 1))

    simple_bar_chart(
      data = data,
      x = "source",
      y = "pageviews_perc",
      flip = TRUE,
      suffix = "%",
      reorder = TRUE
    )
  }) |>
    bindCache(pub_source_by_date())

  output$pub_medium_plot <- renderGirafe({
    top_5 <- pub_medium_summarised() |>
      filter(pageviews > 0) |>
      arrange(desc(pageviews)) |>
      head(5)

    other <- pub_medium_summarised() |>
      arrange(desc(pageviews)) |>
      slice(6:n()) |>
      summarise(
        medium = "other",
        pageviews = sum(pageviews, na.rm = TRUE),
        sessions = sum(sessions, na.rm = TRUE)
      )

    data <- bind_rows(top_5, other) |>
      mutate(pageviews_perc = dfeR::round_five_up(pageviews / sum(pageviews) * 100, 1))

    simple_bar_chart(
      data = data,
      x = "medium",
      y = "pageviews_perc",
      flip = TRUE,
      suffix = "%",
      reorder = TRUE
    )
  }) |>
    bindCache(pub_medium_summarised())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Featured tables ===========================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_featured_tables_full <- reactive({
    message("Reading featured tables")

    read_delta_lake("ees_publication_featured_tables", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_featured_tables_by_date <- reactive({
    pub_featured_tables_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(pub_featured_tables_full(), input$pub_date_choice, input$pub_name_choice)

  output$pub_featured_tables_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_featured_tables.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_featured_tables_full(), file)
    }
  )

  output$pub_featured_tables_table <- renderReactable({
    pub_featured_tables_by_date() |>
      group_by(publication, eventLabel) |>
      summarise("Count" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      arrange(desc(Count)) |>
      select(-publication) |>
      rename("Featured table title" = eventLabel) |>
      dfe_reactable()
  }) |>
    bindCache(pub_featured_tables_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Created tables ============================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_created_tables_full <- reactive({
    message("Reading created tables")

    read_delta_lake("ees_publication_tables_created", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_created_tables_by_date <- reactive({
    pub_created_tables_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(pub_created_tables_full(), input$pub_date_choice, input$pub_name_choice)

  output$pub_created_tables_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_created_tables.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_created_tables_full(), file)
    }
  )

  output$pub_created_tables_table <- renderReactable({
    pub_created_tables_by_date() |>
      group_by(publication, eventLabel) |>
      summarise("Count" = sum(eventCount), .groups = "keep") |>
      ungroup() |>
      arrange(desc(Count)) |>
      select(-publication) |>
      rename("Data set title" = eventLabel) |>
      dfe_reactable()
  }) |>
    bindCache(pub_created_tables_by_date())
}
