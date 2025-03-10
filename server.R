server <- function(input, output, session) {
  # Load in data ==============================================================
  if (Sys.getenv("TESTTHAT") == "") { # check if in test mode
    ## Check for more recent date ---------------------------------------------
    last_updated_table <- reactive({
      message("Checking last updated")

      pool |>
        dplyr::tbl(
          DBI::Id(
            catalog = "catalog_40_copper_statistics_services",
            schema = "analytics_app",
            table = "ees__last_updated"
          )
        ) |>
        dplyr::collect()
    })

    last_updated_date <- reactive({
      message("Last updated date: ", last_updated_table() |> pull(last_updated))

      last_updated_table() |>
        pull(last_updated)
    })

    output$latest_data <- renderText({
      paste0("Latest available data: ", last_updated_table() |> pull(latest_data))
    })

    ## Top level service data -------------------------------------------------
    # Initial load from databricks is slow, so caching the full table as we
    # need it anyway
    service_data <- reactive({
      message("Requesting service data from databricks")
      message(input$date_choice)

      pool |>
        dplyr::tbl(
          DBI::Id(
            catalog = "catalog_40_copper_statistics_services",
            schema = "analytics_app",
            table = "ees_service"
          )
        ) |>
        collect()
    }) |>
      bindCache(last_updated_date())

    ## Publication data -------------------------------------------------------
    # publication_data <- reactive({
    #   message("Requesting data from SQL")
    #
    #   poolWithTransaction(pool_old, function(p) {
    #     tbl(p, "ees_analytics_publication_agg") |>
    #       filter_on_date_pub(input$P_date_choice, input$publication_choice) |>
    #       collect()
    #   })
    # }) |>
    #   bindCache(last_updated_date(), input$P_date_choice, input$publication_choice)

    ## Test data --------------------------------------------------------------
  } else if (Sys.getenv("TESTTHAT")) {
    message("...in test mode...")

    output$latest_data <- renderText({
      # Matches date used in tests/testdata-generator
      paste0("Latest available data: ", "2024-08-08")
    })

    last_updated_date <- reactive({
      "2024-08-08"
    })

    service_data <- reactive({
      arrow::read_parquet("tests/testdata/combined_data_0.parquet")
    })

    # publication_data <- reactive({
    #   arrow::read_parquet("tests/testdata/publication_aggregation_0.parquet")
    # })

    message("...data loaded!")
  } else {
    message(
      "...no data loaded. This is most unexpected. TESTTHAT = ",
      Sys.getenv("TESTTHAT")
    )
  }

  service_by_date <- reactive({
    service_data() |>
      filter_on_date(input$date_choice)
  })

  # # Dropdown options ==========================================================
  # publications <- reactive({
  #   publication_data() |>
  #     distinct(publication) |>
  #     str_sort()
  # }) |>
  #   bindCache(last_updated_date(), publication_data())
  #
  # # Outputs ===================================================================
  #
  # observe({
  #   updateSelectInput(
  #     session,
  #     "publication_choice",
  #     choices = publications()
  #   )
  # })

  output$num_sessions <- renderText({
    paste0(
      dfeR::comma_sep(
        service_by_date() %>%
          as.data.frame() %>%
          summarise(sum(sessions))
      )
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  output$num_pageviews <- renderText({
    paste0(
      dfeR::comma_sep(
        service_by_date() %>%
          as.data.frame() %>%
          summarise(sum(pageviews))
      )
    )
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  output$S <- renderPlot({
    ggplot(
      service_by_date(),
      aes(x = date, y = sessions)
    ) +
      geom_line(color = "steelblue") +
      xlab("") +
      theme_minimal() +
      theme(legend.position = "top")
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  output$PV <- renderPlot({
    ggplot(
      service_by_date(),
      aes(x = date, y = pageviews)
    ) +
      geom_line(color = "steelblue") +
      xlab("") +
      theme_minimal() +
      theme(legend.position = "top")
  }) |>
    bindCache(last_updated_date(), input$date_choice)

  # output$P_num_sessions <- renderText({
  #   paste0(
  #     dfeR::comma_sep(
  #       publication_data() %>%
  #         as.data.frame() %>%
  #         summarise(sum(sessions))
  #     )
  #   )
  # })
  #
  # output$P_num_pageviews <- renderText({
  #   paste0(
  #     dfeR::comma_sep(
  #       publication_data() |>
  #         as.data.frame() |>
  #         summarise(sum(pageviews))
  #     )
  #   )
  # })
  #
  # output$P_S <- renderPlot({
  #   ggplot(
  #     publication_data(),
  #     aes(x = date, y = sessions)
  #   ) +
  #     geom_line(color = "steelblue") +
  #     xlab("") +
  #     theme_minimal() +
  #     theme(legend.position = "top")
  # })
  #
  # output$P_PV <- renderPlot({
  #   ggplot(
  #     publication_data(),
  #     aes(x = date, y = pageviews)
  #   ) +
  #     geom_line(colour = "steelblue") +
  #     xlab("") +
  #     theme_minimal() +
  #     theme(legend.position = "top")
  # })
  #
  # output$pub_pageview_table <- renderTable({
  #   publication_data() |> select(date, pagePath, pageviews)
  # })
  #
  # output$pub_session_table <- renderTable({
  #   publication_data() |> select(date, sessions)
  # })
}
