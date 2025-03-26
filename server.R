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
      filter_on_date(input$service_date_choice)
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
  output$service_rolling_plot <- renderGirafe({
    data <- service_summary_by_date() |>
      select(date, pageviews_avg7, sessions_avg7) |>
      filter(!is.na(pageviews_avg7))

    simple_line_chart(
      data = data,
      x = "date",
      lines = c("pageviews_avg7", "sessions_avg7"),
      labels = c("Pageviews", "Sessions")
    )
  }) |>
    bindCache(service_summary_by_date())

  output$service_sessions_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "sessions",
      fontSize = 5
    )
  }) |>
    bindCache(service_summary_by_date())

  output$service_pageviews_plot <- renderGirafe({
    simple_bar_chart(
      data = service_summary_by_date(),
      x = "date",
      y = "pageviews",
      fontSize = 5
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
        TRUE ~ "other"
      )) |>
      group_by(page_type, device) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "drop"
      ) |>
      pivot_wider(names_from = device, values_from = Sessions, values_fill = list(Sessions = 0)) |>
      arrange(desc(desktop)) |>
      select(page_type, desktop, mobile, tablet, other) |>
      mutate(
        "desktop" = dfeR::comma_sep(desktop),
        "mobile" = dfeR::comma_sep(mobile),
        "tablet" = dfeR::comma_sep(tablet),
        "other" = dfeR::comma_sep(other)
      ) |>
      rename(
        "Page type" = page_type,
        "Desktop" = desktop,
        "Mobile" = mobile,
        "Tablet" = tablet,
        "Other" = other
      ) |>
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
      arrange(desc(Chrome)) |>
      select(page_type, Chrome, Edge, Safari, Other) |>
      mutate(
        "Chrome" = dfeR::comma_sep(Chrome),
        "Edge" = dfeR::comma_sep(Edge),
        "Safari" = dfeR::comma_sep(Safari),
        "Other" = dfeR::comma_sep(Other)
      ) |>
      rename(
        "Page type" = page_type
      ) |>
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
        "Sessions" = sum(sessions, na.rm = TRUE),
        "Pageviews" = sum(pageviews, na.rm = TRUE),
        "EngagementDuration" = sum(engagementDuration, na.rm = TRUE),
        "session_starts" = sum(total_session_starts, na.rm = TRUE),
        .groups = "keep"
      ) |>
      ungroup() |>
      mutate("avgTimeOnPage" = round(EngagementDuration / Pageviews, 1)) |>
      select(page_type, Pageviews, avgTimeOnPage, session_starts) |>
      arrange(desc(Pageviews)) |>
      mutate(
        "Pageviews" = dfeR::comma_sep(Pageviews),
        "session_starts" = dfeR::comma_sep(session_starts)
      ) |>
      rename(
        "Average engagement time (seconds)" = avgTimeOnPage,
        "Session start events" = session_starts
      ) |>
      dfe_reactable(default_page_size = 15)
  }) |>
    bindCache(service_time_on_page_by_date())


  # Plots --------------------------------------------------------------------

  output$service_time_on_page_plot <- renderGirafe({
    data_for_chart <- service_time_on_page_by_date() |>
      group_by(page_type) |>
      summarise(
        "sessions" = sum(sessions, na.rm = TRUE),
        "pageviews" = sum(pageviews, na.rm = TRUE),
        "engagementDuration" = sum(engagementDuration, na.rm = TRUE),
        "session_starts" = sum(total_session_starts, na.rm = TRUE),
        .groups = "keep"
      ) |>
      ungroup() |>
      select(page_type, pageviews)

    simple_bar_chart(
      data = data_for_chart,
      x = "page_type",
      y = "pageviews",
      height = 4,
      fontSize = 8,
      flip = TRUE,
      reorder = TRUE
    )
  }) |>
    bindCache(service_time_on_page_by_date())

  # Value box ----------------------------------------------------------------

  output$service_avg_session_duration_box <- renderText({
    paste(
      round(sum(service_time_on_page_by_date()$engagementDuration, na.rm = TRUE) / sum(service_time_on_page_by_date()$sessions, na.rm = TRUE), 1),
      "seconds"
    )
  }) |>
    bindCache(service_summary_by_date())

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Source / medium =====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  service_source_full <- reactive({
    message("Reading service sources and mediums")

    read_delta_lake("ees_service_source_medium", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_source_by_date <- reactive({
    service_source_full() |>
      filter_on_date(input$service_date_choice)
  }) |>
    bindCache(service_source_full(), input$service_date_choice)

  output$service_source_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_service_source.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(service_source_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  service_source_summarised <- reactive({
    service_source_by_date() |>
      group_by(source) |>
      summarise(
        "pageviews" = sum(pageviews),
        "sessions" = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup() |>
      arrange(desc(pageviews))
  }) |>
    bindCache(service_source_by_date())

  output$service_source_table <- renderReactable({
    service_source_summarised() |>
      mutate(
        "pageviews" = dfeR::comma_sep(pageviews),
        "sessions" = dfeR::comma_sep(sessions)
      ) |>
      rename(
        "Source" = source,
        "Views" = pageviews,
        "Sessions" = sessions
      ) |>
      dfe_reactable()
  }) |>
    bindCache(service_source_summarised())

  service_medium_summarised <- reactive({
    service_source_by_date() |>
      group_by(medium) |>
      summarise(
        "pageviews" = sum(pageviews),
        "sessions" = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup() |>
      arrange(desc(pageviews))
  }) |>
    bindCache(service_source_by_date())

  output$service_medium_table <- renderReactable({
    service_medium_summarised() |>
      mutate(
        "pageviews" = dfeR::comma_sep(pageviews),
        "sessions" = dfeR::comma_sep(sessions)
      ) |>
      rename(
        "Medium" = medium,
        "Views" = pageviews,
        "Sessions" = sessions
      ) |>
      dfe_reactable()
  }) |>
    bindCache(service_medium_summarised())

  # Plots ---------------------------------------------------------------------
  output$service_source_plot <- renderGirafe({
    top_5 <- service_source_summarised() |>
      filter(pageviews > 0) |>
      arrange(desc(pageviews)) |>
      head(5)

    other <- service_source_summarised() |>
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
    bindCache(service_source_by_date())

  output$service_medium_plot <- renderGirafe({
    top_5 <- service_medium_summarised() |>
      filter(pageviews > 0) |>
      arrange(desc(pageviews)) |>
      head(5)

    other <- service_medium_summarised() |>
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
    bindCache(service_medium_summarised())



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Download types =====================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  service_downloads_full <- reactive({
    message("Reading service downloadss and mediums")

    read_delta_lake("ees_service_downloads", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  service_downloads_by_date <- reactive({
    service_downloads_full() |>
      filter_on_date(input$service_date_choice)
  }) |>
    bindCache(service_downloads_full(), input$service_date_choice)

  output$service_downloads_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_service_downloads.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(service_downloads_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------
  service_downloads_summarised <- reactive({
    service_downloads_by_date() |>
      group_by(page_type, download_type) |>
      summarise(
        "eventCount" = sum(eventCount),
        .groups = "keep"
      ) |>
      ungroup() |>
      arrange(page_type, download_type)
  }) |>
    bindCache(service_downloads_by_date())

  output$service_downloads_table <- renderReactable({
    service_downloads_summarised() |>
      mutate(
        "eventCount" = dfeR::comma_sep(eventCount)
      ) |>
      rename(
        "Page type" = page_type,
        "Download type" = download_type,
        "Download count" = eventCount
      ) |>
      dfe_reactable()
  }) |>
    bindCache(service_downloads_summarised())


  # Plots ---------------------------------------------------------------------
  output$service_downloads_plot <- renderGirafe({
    data_for_chart <- service_downloads_summarised() |>
      mutate(Download = paste0(page_type, " - ", download_type)) |>
      arrange(desc(eventCount))



    simple_bar_chart(
      data = data_for_chart,
      x = "Download",
      y = "eventCount",
      flip = TRUE,
      reorder = TRUE,
      height = 3
    )
  }) |>
    bindCache(service_downloads_by_date())






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
      mutate(
        "Clicks" = dfeR::comma_sep(Clicks)
      ) |>
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
      mutate(
        "Clicks" = dfeR::comma_sep(Clicks)
      ) |>
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
      mutate("avgTimeOnPage" = round(EngagementDuration / Pageviews, 1)) |>
      select(page_type, Pageviews, avgTimeOnPage) |>
      arrange(desc(avgTimeOnPage)) |>
      mutate(
        "Pageviews" = dfeR::comma_sep(Pageviews)
      ) |>
      rename(
        "Page type" = page_type,
        "Average engagement time (seconds)" = avgTimeOnPage,
        "Views" = Pageviews
      ) |>
      dfe_reactable()
  }) |>
    bindCache(content_interactions_by_date())

  # Plot ---------------------------------------------------------------------

  output$pub_content_interactions_plot <- renderGirafe({
    data_for_chart <- content_interactions_by_date() |>
      group_by(page_type) |>
      summarise(
        Pageviews = sum(pageviews),
        .groups = "keep"
      ) |>
      ungroup()

    simple_bar_chart(
      data = data_for_chart,
      x = "page_type",
      y = "Pageviews",
      flip = TRUE,
      height = 3,
      reorder = TRUE
    )
  }) |>
    bindCache(pub_summary_by_date())

  # Summary of events ---------------------------------------------------------

  content_interactions_summary_full <- reactive({
    message("Reading publication summary")

    read_delta_lake("ees_publication_summary", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  content_interactions_summary_by_date <- reactive({
    content_interactions_summary_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice)
  }) |>
    bindCache(content_interactions_summary_full(), input$pub_date_choice, input$pub_name_choice)

  # Download ------------------------------------------------------------------
  output$content_interactions_summary_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_pub_content_interactions_summary.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(content_interactions_summary_full(), file)
    }
  )

  # Table ---------------------------------------------------------------------

  pub_interactions_summary_metric_labels <- c(
    total_session_starts = "Total sessions starts on release page",
    total_accordion_events = "Total accordion click events on release page",
    total_download_events = "Total data and file downloads",
    total_featured_tables = "Total featured table clicks",
    total_search_events = "Total search events on release page",
    total_tables_created = "Total tables created"
  )

  output$pub_content_interactions_summary_table <- renderReactable({
    content_interactions_summary_by_date() |>
      group_by(publication) |>
      summarise(
        pageviews = sum(pageviews),
        sessions = sum(sessions),
        total_session_starts = sum(total_session_starts),
        total_accordion_events = sum(total_accordion_events),
        total_download_events = sum(total_download_events),
        total_featured_tables = sum(total_featured_tables),
        total_search_events = sum(total_search_events),
        total_tables_created = sum(total_tables_created),
        .groups = "keep"
      ) |>
      ungroup() |>
      select(-publication, -pageviews, -sessions) |>
      tidyr::pivot_longer(
        cols = everything(),
        names_to = "metric",
        values_to = "value"
      ) |>
      mutate(metric = pub_interactions_summary_metric_labels[metric]) |>
      mutate(
        "value" = dfeR::comma_sep(value)
      ) |>
      rename(
        "Count" = value,
        "Event" = metric
      ) |>
      dfe_reactable()
  }) |>
    bindCache(content_interactions_summary_by_date())

  output$pub_content_interactions_summary_plot <- renderGirafe({
    data_for_chart <- content_interactions_summary_by_date() |>
      group_by(publication) |>
      summarise(
        pageviews = sum(pageviews),
        sessions = sum(sessions),
        total_session_starts = sum(total_session_starts),
        total_accordion_events = sum(total_accordion_events),
        total_download_events = sum(total_download_events),
        total_featured_tables = sum(total_featured_tables),
        total_search_events = sum(total_search_events),
        total_tables_created = sum(total_tables_created),
        .groups = "keep"
      ) |>
      ungroup() |>
      select(-publication, -pageviews, -sessions) |>
      tidyr::pivot_longer(
        cols = everything(),
        names_to = "metric",
        values_to = "value"
      ) |>
      mutate(metric = pub_interactions_summary_metric_labels[metric])

    simple_bar_chart(
      data = data_for_chart,
      x = "metric",
      y = "value",
      flip = TRUE,
      height = 2.5,
      fontSize = 7,
      reorder = TRUE
    )
  }) |>
    bindCache(pub_summary_by_date())


  # Value box -----------------------------------------------------------------
  output$table_tool_box <- renderText({
    tables_created <- content_interactions_summary_by_date() |>
      group_by(publication) |>
      summarise(
        total_tables_created = sum(total_tables_created),
        .groups = "keep"
      ) |>
      pull(total_tables_created) |>
      as.numeric()

    table_tool_views <- content_interactions_by_date() |>
      filter(page_type == "Table tool") |>
      group_by(publication) |>
      summarise(
        pageviews = sum(pageviews),
        .groups = "keep"
      ) |>
      pull(pageviews) |>
      as.numeric()

    paste(round(tables_created / table_tool_views, 2))
  }) |>
    bindCache(readtime_full(), input$pub_name_choice)

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
  # Publication devices =======================================================
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pub_device_full <- reactive({
    message("Reading pub by device")

    read_delta_lake("ees_publication_device_browser", Sys.getenv("TESTTHAT"))
  }) |>
    bindCache(last_updated_date())

  pub_device_by_date <- reactive({
    pub_device_full() |>
      filter_on_date(input$pub_date_choice) |>
      filter(publication == input$pub_name_choice) |>
      collect()
  }) |>
    bindCache(pub_device_full(), input$pub_date_choice, input$pub_name_choice)

  output$pub_device_download <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_ees_pub_device.csv")
    },
    content = function(file) {
      duckplyr::compute_csv(pub_device_full(), file)
    }
  )

  # Table outputs -------------------------------------------------------------

  output$pub_device_table <- renderReactable({
    pub_device_by_date() |>
      group_by(device) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "drop"
      ) |>
      mutate(
        "Sessions" = dfeR::comma_sep(Sessions)
      ) |>
      dfe_reactable()
  }) |>
    bindCache(pub_device_by_date())


  # Plots ---------------------------------------------------------------------
  output$pub_device_plot <- renderGirafe({
    data_for_chart <- pub_device_by_date() |>
      group_by(device) |>
      summarise(
        Sessions = sum(sessions),
        .groups = "keep"
      ) |>
      ungroup()

    simple_bar_chart(
      data = data_for_chart,
      x = "device",
      y = "Sessions",
      height = 3
    )
  }) |>
    bindCache(pub_summary_by_date())


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
      rename("Clicks" = count) |>
      select(-metric) |>
      mutate(
        "Clicks" = dfeR::comma_sep(Clicks)
      ) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$service_gsc_q_impressions_table <- renderReactable({
    service_search_console() |>
      filter(metric == "impressions") |>
      rename("impressions" = count) |>
      select(-metric) |>
      mutate(
        "impressions" = dfeR::comma_sep(impressions)
      ) |>
      dfe_reactable()
  }) |>
    bindCache(service_search_console())

  output$pub_gsc_table <- renderReactable({
    publication_search_console() |>
      mutate(
        "count" = dfeR::comma_sep(count)
      ) |>
      rename(
        "Clicks" = count
      ) |>
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
      mutate(
        "pageviews" = dfeR::comma_sep(pageviews),
        "sessions" = dfeR::comma_sep(sessions)
      ) |>
      rename(
        "Source" = source,
        "Views" = pageviews,
        "Sessions" = sessions
      ) |>
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
      mutate(
        "pageviews" = dfeR::comma_sep(pageviews),
        "sessions" = dfeR::comma_sep(sessions)
      ) |>
      rename(
        "Medium" = medium,
        "Views" = pageviews,
        "Sessions" = sessions
      ) |>
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
      mutate(
        "Count" = dfeR::comma_sep(Count)
      ) |>
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
      mutate(
        "Count" = dfeR::comma_sep(Count)
      ) |>
      dfe_reactable()
  }) |>
    bindCache(pub_created_tables_by_date())
}
