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
      "gsc_time_download",
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
      "pub_accordions_download",
      "Publication accordion clicks",
      file_size = "< 100 MB" # TODO: Generate automatically
    ),
    tags$p("Accordion clicks on publication and methodology pages."),
    shinyGovstyle::download_link(
      "pub_search_events_download",
      "Publication search events",
      file_size = "< 20 MB" # TODO: Generate automatically
    ),
    tags$p("Searches made on publication and methodology pages."),
    shinyGovstyle::download_link(
      "readtime_download",
      "Reading time",
      file_size = "< 1 MB" # TODO: Generate automatically
    ),
    tags$p("Average reading time for current latest publication pages."),
    shinyGovstyle::download_link(
      "gsc_queries_download",
      "Google Search queries",
      file_size = "< 1 MB" # TODO: Generate automatically
    ),
    tags$p("Top queries leading to the service and publication pages by clicks and impressions over the past year."),
    shinyGovstyle::download_link(
      "pub_source_download",
      "Source and medium",
      file_size = "< 60 MB" # TODO: Generate automatically
    ),
    tags$p("Traffic source and medium information for publication pages."),
    shinyGovstyle::download_link(
      "pub_featured_tables_download",
      "Featured table views",
      file_size = "< 40 MB" # TODO: Generate automatically
    ),
    tags$p("Views of featured tables from within the table tool."),
    shinyGovstyle::download_link(
      "pub_created_tables_download",
      "Created tables by data set",
      file_size = "< 20 MB" # TODO: Generate automatically
    ),
    tags$p("Tables created by users in the table tool broken down by the data set they were made from."),
    tags$br(),
    tags$br()
  )
}
