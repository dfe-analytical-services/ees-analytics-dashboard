downloads_content <- function() {
  shiny::tagList(
    tags$h1("Download data"),
    tags$p(
      "Download the full data used in the app, this is not affected by any filter choices you've made."
    ),
    tags$h2("Service wide"),
    shinyGovstyle::download_link(
      "service_summary_download",
      "Service summary",
      file_size = "< 1 MB" # TODO: Generate automatically
    ),
    tags$p("Sessions, pageviews and rolling 7 day averages by date."),
    shinyGovstyle::download_link(
      "search_console_time_download",
      "Search console time series",
      file_size = "< 1 MB" # TODO: Generate automatically
    ),
    tags$p("Impressions and clicks in Google Search over time for the whole service."),
    tags$h2("Publication level"),
    shinyGovstyle::download_link(
      "pub_summary_download",
      "Publication summary",
      file_size = "< 20 MB" # TODO: Generate automatically
    ),
    tags$p("TBC."),
    shinyGovstyle::download_link(
      "search_console_queries_download",
      "Google Search queries",
      file_size = "< 1 MB" # TODO: Generate automatically
    ),
    tags$p("Top queries leading to the service and publication pages by clicks and impressions over the past year.")
  )
}
